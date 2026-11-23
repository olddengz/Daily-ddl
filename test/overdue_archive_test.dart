import 'package:daily_ddl/db/database.dart';
import 'package:daily_ddl/db/task_repository.dart';
import 'package:daily_ddl/services/reminder_service.dart';
import 'package:daily_ddl/services/task_calendar.dart';
import 'package:daily_ddl/ui/home_page.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final deadline = DateTime(2026, 11, 22, 8).toUtc();
  final now = deadline.add(const Duration(hours: 2));
  late AppDatabase db;
  late TaskRepository repo;

  setUp(() {
    db = AppDatabase.memory();
    repo = TaskRepository(db);
  });
  tearDown(() => db.close());

  Future<Task> add({
    String id = 'ddl',
    String kind = 'ddl',
    String status = 'todo',
  }) async {
    await repo.addTask(
      TasksCompanion.insert(
        id: id,
        title: '课程作业',
        taskKind: Value(kind),
        status: Value(status),
        deadlineUtc: deadline,
        remindMinutes: const Value('[10]'),
        createdAtUtc: deadline.subtract(const Duration(days: 1)),
        updatedAtUtc: deadline,
      ),
    );
    return (await repo.taskById(id))!;
  }

  test('归档分档以截止后的实际时长为准', () async {
    final task = await add();
    expect(
      TaskRepository.archiveCost(
        task,
        deadline.subtract(const Duration(seconds: 1)),
      ),
      isNull,
    );
    const cases = {
      0: 1,
      1439: 1,
      1440: 3,
      4319: 3,
      4320: 5,
      10079: 5,
      10080: 8,
      20159: 8,
      20160: 12,
      60000: 12,
    };
    for (final entry in cases.entries) {
      expect(
        TaskRepository.archiveCost(
          task,
          deadline.add(Duration(minutes: entry.key)),
        ),
        entry.value,
        reason: '逾期 ${entry.key} 分钟',
      );
    }
  });

  test('并发归档只扣一次，扣累计积分，保留日历原截止且不算完成', () async {
    final task = await add();
    await repo.refreshDailyCredits(now);

    final results = await Future.wait([
      repo.archiveOverdue(task, quotedCost: 1, nowUtc: now),
      repo.archiveOverdue(task, quotedCost: 1, nowUtc: now),
    ]);
    expect(
      results,
      unorderedEquals([ArchiveResult.archived, ArchiveResult.unavailable]),
    );
    final ledger = await repo.ledger();
    expect(ledger.single.amount, -1);
    expect(ledger.single.refId, task.id);
    expect(await repo.balance(now: now), -1);
    expect(await repo.dailyCredits(now.toLocal()), (base: 0, bonus: 0));

    final archived = (await repo.taskById(task.id))!;
    expect(archived.status, 'archived');
    expect(archived.deadlineUtc, task.deadlineUtc);
    expect(archived.completedAtUtc, isNull);
    expect(await repo.activeTasks(now), isEmpty);
    expect(dueReminders([archived], now), isEmpty);
    expect(await repo.markOverdueAll(now), 0);
    expect((await repo.completeTask(task.id, now)).ok, isFalse);
    expect(await repo.deleteTask(task.id, nowUtc: now), isFalse);

    final local = deadline.toLocal();
    final days = await loadTaskRange(
      db,
      DateTime(local.year, local.month, local.day),
      DateTime(local.year, local.month, local.day + 1),
    );
    final detail = days[TaskRepository.localDateKey(local)]!;
    expect(detail.deadlines.single.status, 'archived');
    expect(detail.completed, isEmpty);
    expect(detail.points, 0);
  });

  test('报价跨档后需重新确认，非逾期或每日任务无法归档', () async {
    final task = await add();
    final bumped = deadline.add(const Duration(days: 1));
    expect(await repo.deleteTask(task.id, nowUtc: now), isFalse);
    expect(
      await repo.archiveOverdue(task, quotedCost: 1, nowUtc: bumped),
      ArchiveResult.priceChanged,
    );
    final daily = await add(id: 'daily', kind: 'daily');
    final done = await add(id: 'done', status: 'done');
    for (final item in [daily, done]) {
      expect(
        await repo.archiveOverdue(item, quotedCost: 1, nowUtc: now),
        ArchiveResult.unavailable,
      );
    }
    expect(
      await repo.archiveOverdue(
        task,
        quotedCost: 1,
        nowUtc: deadline.subtract(const Duration(seconds: 1)),
      ),
      ArchiveResult.unavailable,
    );
    expect(await repo.ledger(), isEmpty);
    expect(
      await repo.archiveOverdue(task, quotedCost: 3, nowUtc: bumped),
      ArchiveResult.archived,
    );
  });

  test('扣分写入失败时保留逾期待办状态', () async {
    final task = await add(status: 'overdue');
    await db.customStatement('''
      CREATE TRIGGER reject_archive BEFORE INSERT ON credit_ledger
      WHEN NEW.type = 'archive'
      BEGIN SELECT RAISE(ABORT, 'test rejection'); END;
      ''');
    await expectLater(
      repo.archiveOverdue(task, quotedCost: 1, nowUtc: now),
      throwsA(isA<Exception>()),
    );
    expect((await repo.taskById(task.id))!.status, 'overdue');
    expect(await repo.ledger(), isEmpty);
  });

  testWidgets('首页预览可取消，确认后显示扣款并收起逾期列表', (tester) async {
    await add();
    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(db: db, now: () => now),
      ),
    );
    await tester.pumpAndSettle();

    final group = find.text('逾期 · 1');
    await tester.ensureVisible(group);
    await tester.tap(group);
    await tester.pumpAndSettle();
    final archive = find.text('归档');
    await tester.ensureVisible(archive);
    await tester.pumpAndSettle();
    await tester.tap(archive);
    await tester.pumpAndSettle();
    expect(find.text('扣 1 积分并归档'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(await repo.ledger(), isEmpty);

    await tester.tap(archive);
    await tester.pumpAndSettle();
    await tester.tap(find.text('扣 1 积分并归档'));
    await tester.pumpAndSettle();
    expect(find.text('已归档 · 扣除 1 积分'), findsOneWidget);
    expect(group, findsNothing);
    expect(find.text('累计积分 -1'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
