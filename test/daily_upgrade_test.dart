import 'dart:convert';

import 'package:daily_ddl/db/database.dart';
import 'package:daily_ddl/db/migrations.dart';
import 'package:daily_ddl/db/task_repository.dart';
import 'package:daily_ddl/engine/daily_settlement.dart';
import 'package:daily_ddl/engine/score_engine.dart';
import 'package:daily_ddl/services/reminder_service.dart';
import 'package:daily_ddl/ui/task_grouping.dart';
import 'package:daily_ddl/ui/time_label.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late AppDatabase db;
  late TaskRepository repo;
  final today = DateTime(2026, 10, 17, 10).toUtc();
  String date(DateTime d) => TaskRepository.localDateKey(d.toLocal());
  Future<void> add(
    String id,
    DateTime deadline, {
    String kind = 'daily',
    String? rule = 'every:1:day',
    DateTime? end,
  }) => repo.addTask(
    TasksCompanion.insert(
      id: id,
      title: id,
      deadlineUtc: deadline,
      taskKind: Value(kind),
      scheduledDate: Value(kind == 'daily' ? date(deadline) : null),
      seriesId: Value(kind == 'daily' ? id : null),
      repeatRule: Value(rule),
      repeatEndUtc: Value(end),
      remindMinutes: Value(jsonEncode([1440, 180])),
      createdAtUtc: today,
      updatedAtUtc: today,
    ),
  );
  setUp(() {
    db = AppDatabase.memory();
    repo = TaskRepository(db);
  });
  tearDown(() => db.close());

  test('完成今日每日任务不会生成或显示明日实例；撤销后恢复原实例和积分', () async {
    await add('a', today.add(const Duration(hours: 10)));
    expect((await repo.completeTask('a', today)).score, 100);
    expect((await repo.allTasks()).length, 1);
    expect(await repo.undoComplete('a', today), isTrue);
    expect(await repo.earnedToday(today.toLocal()), 0);
    expect((await repo.allTasks()).length, 1);
  });
  test('明天的每日任务不参与首页、分配或提前完成', () async {
    await add('tomorrow', today.add(const Duration(days: 1)));
    await add(
      'ddl',
      today.add(const Duration(days: 8)),
      kind: 'ddl',
      rule: null,
    );
    expect((await repo.activeTasks(today)).map((t) => t.id), ['ddl']);
    final g = TaskGrouping.group(await repo.allTasks(), today);
    expect(g.active.map((t) => t.id), ['ddl']);
    expect((await repo.completeTask('tomorrow', today)).reason, 'not_today');
    expect(await repo.ledger(), isEmpty);
  });
  test('昨日漏做也生成今日实例；并发结算不重复生成；跨多日不补造历史待办', () async {
    await add('a', today.subtract(const Duration(days: 5)));
    await Future.wait([
      DailySettlement(db).run(today),
      DailySettlement(db).run(today),
    ]);
    final rows = await repo.allTasks();
    expect(rows.length, 2);
    final current = rows.singleWhere((t) => t.scheduledDate == date(today));
    expect(current.status, 'overdue'); // inherited 10:00, now exactly 10:00
    expect(current.seriesId, 'a');
  });
  test('昨天已完成同样生成今日实例，且今日恢复完整分数池', () async {
    final yesterday = today.subtract(const Duration(days: 1));
    await add('a', yesterday.add(const Duration(hours: 10)));
    await repo.completeTask('a', yesterday);
    await DailySettlement(db).run(today);
    final current = (await repo.activeTasks(today)).single;
    expect(current.seriesId, 'a');
    expect((await repo.completeTask(current.id, today)).score, 100);
  });
  test('重复结束后不再生成；每3天在非计划日不出现', () async {
    await add(
      'ended',
      today.subtract(const Duration(days: 2)),
      end: today.subtract(const Duration(days: 1)),
    );
    await add(
      'every3',
      today.subtract(const Duration(days: 1)),
      rule: 'every:3:day',
    );
    await repo.ensureDailyInstances(today);
    expect((await repo.allTasks()).length, 2);
    expect(await repo.activeTasks(today), isEmpty);
  });
  test('跳过每日本次不阻断下次；关闭重复停止生成', () async {
    await add('a', today.add(const Duration(hours: 10)));
    expect(await repo.deleteTask('a'), isTrue);
    await repo.ensureDailyInstances(today.add(const Duration(days: 1)));
    final next = (await repo.allTasks()).singleWhere((t) => t.id != 'a');
    await repo.updateTask(
      next.id,
      const TasksCompanion(repeatRule: Value(null)),
    );
    await repo.ensureDailyInstances(today.add(const Duration(days: 2)));
    expect((await repo.allTasks()).length, 2);
  });
  test('旧结束日期无需打开编辑页即可迁移，且迁移可重复运行', () async {
    final midnight = DateTime(2026, 10, 20).toUtc();
    await add('a', today.add(const Duration(hours: 1)), end: midnight);
    await DataMigrations.run(db);
    await DataMigrations.run(db);
    final end = (await repo.taskById('a'))!.repeatEndUtc!.toLocal();
    expect([end.day, end.hour, end.minute, end.second], [20, 23, 59, 59]);
  });
  test('真实 schema2 升 schema3 保留旧任务和流水，默认待分类', () async {
    final raw = sqlite3.openInMemory();
    final fresh = AppDatabase(
      NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
    );
    await fresh.customSelect('SELECT 1').get();
    await fresh.close();
    raw.execute('DROP INDEX ux_daily_instance');
    for (final c in ['task_kind', 'scheduled_date', 'series_id']) {
      raw.execute('ALTER TABLE tasks DROP COLUMN $c');
    }
    raw.execute('PRAGMA user_version=2');
    raw.execute(
      "INSERT INTO tasks(id,title,deadline_utc,created_at_utc,updated_at_utc) VALUES('old','old',1770000000,1760000000,1760000000)",
    );
    final upgraded = AppDatabase(NativeDatabase.opened(raw));
    try {
      final task = await TaskRepository(upgraded).taskById('old');
      expect(task!.taskKind, 'legacy');
      expect(task.scheduledDate, isNull);
      expect(
        (await upgraded.customSelect('PRAGMA user_version').getSingle())
            .data
            .values
            .single,
        3,
      );
    } finally {
      await upgraded.close();
    }
  });

  test('停止重复后删除最新实例不会让历史规则复活', () async {
    await add(
      'a',
      today.subtract(const Duration(days: 1)).add(const Duration(hours: 5)),
    );
    await repo.ensureDailyInstances(today);
    final latest = (await repo.allTasks()).singleWhere((t) => t.id != 'a');
    await repo.updateTask(
      latest.id,
      const TasksCompanion(repeatRule: Value(null)),
    );
    await repo.deleteTask(latest.id);
    await repo.ensureDailyInstances(today.add(const Duration(days: 1)));
    expect((await repo.allTasks()).length, 2);
  });
  test('每日任务转换为DDL后不会从旧实例恢复重复', () async {
    await add(
      'a',
      today.subtract(const Duration(days: 1)).add(const Duration(hours: 5)),
    );
    await repo.ensureDailyInstances(today);
    final latest = (await repo.allTasks()).singleWhere((t) => t.id != 'a');
    await repo.updateTask(
      latest.id,
      const TasksCompanion(
        taskKind: Value('ddl'),
        seriesId: Value(null),
        scheduledDate: Value(null),
        repeatRule: Value(null),
      ),
    );
    await repo.ensureDailyInstances(today.add(const Duration(days: 1)));
    expect((await repo.allTasks()).length, 2);
    expect((await repo.taskById('a'))!.repeatRule, isNull);
  });

  ScoreTask scoreTask(String id, String kind, int hours) => ScoreTask(
    id: id,
    taskKind: kind,
    deadlineUtc: today.add(Duration(hours: hours)),
    priority: 'medium',
  );
  for (final sample in [(240, 70.0), (168, 55.0), (48, 40.0), (12, 30.0)]) {
    test('两类并存，DDL剩余${sample.$1}小时每日份额${sample.$2}', () {
      final a = distributeScores(
        [scoreTask('daily', 'daily', 10), scoreTask('ddl', 'ddl', sample.$1)],
        0,
        nowUtc: today,
      );
      expect(a.scores['daily'], sample.$2);
      expect(a.scores.values.reduce((a, b) => a + b), 100);
    });
  }
  test('同组越近DDL占比越高，完成任意顺序不会超过100', () {
    final tasks = [
      scoreTask('daily', 'daily', 10),
      scoreTask('near', 'ddl', 12),
      scoreTask('far', 'ddl', 240),
    ];
    final a = distributeScores(tasks, 0, nowUtc: today);
    expect(a.scores['near']!, greaterThan(a.scores['far']!));
    for (final order in [
      ['daily', 'near', 'far'],
      ['far', 'daily', 'near'],
      ['near', 'far', 'daily'],
    ]) {
      expect(
        simulateCompletionSequence(tasks, order, nowUtc: today),
        closeTo(100, 0.01),
      );
    }
  });
  test('倒计时跨天不足24小时显示小时，正数不出现0，边界精确', () {
    expect(
      timeRemaining(today.add(const Duration(days: 2, hours: 1)), today),
      '剩余 3 天',
    );
    expect(
      timeRemaining(today.add(const Duration(hours: 23)), today),
      '剩余 23 小时',
    );
    expect(
      timeRemaining(today.add(const Duration(minutes: 25)), today),
      '剩余 25 分钟',
    );
    expect(
      timeRemaining(today.add(const Duration(seconds: 1)), today),
      '不足 1 分钟',
    );
    expect(timeRemaining(today, today), '已到截止时间');
    expect(
      timeRemaining(today.subtract(const Duration(hours: 2)), today),
      '已逾期 2 小时',
    );
  });
  test('提醒错过阈值合并、重复检查不重复发、延期重新计时、完成不发', () async {
    await add('a', today.add(const Duration(hours: 1)));
    final sent = <String>[];
    final reminders = ReminderService(db, (title, body, id) async {
      sent.add(body);
    });
    await reminders.check(await repo.allTasks(), today);
    await reminders.check(await repo.allTasks(), today);
    expect(sent.length, 1);
    await repo.updateTask(
      'a',
      TasksCompanion(deadlineUtc: Value(today.add(const Duration(hours: 2)))),
    );
    await reminders.check(await repo.allTasks(), today);
    expect(sent.length, 2);
    await repo.completeTask('a', today);
    await reminders.check(await repo.allTasks(), today);
    expect(sent.length, 2);
  });
  test('提醒发送失败不标记，可重试；明日每日任务不提醒', () async {
    await add('a', today.add(const Duration(hours: 1)));
    await add('future', today.add(const Duration(days: 1)));
    final reminders = ReminderService(db, (title, body, id) async {
      throw StateError('failed');
    });
    await expectLater(
      reminders.check(await repo.allTasks(), today),
      throwsStateError,
    );
    final sent = <String>[];
    await ReminderService(db, (title, body, id) async {
      sent.add(body);
    }).check(await repo.allTasks(), today);
    expect(sent, ['a']);
  });
}
