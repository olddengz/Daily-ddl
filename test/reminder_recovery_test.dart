import 'dart:async';

import 'package:daily_ddl/db/database.dart';
import 'package:daily_ddl/db/task_repository.dart';
import 'package:daily_ddl/services/reminder_service.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late TaskRepository repo;
  final now = DateTime(2026, 10, 29, 10).toUtc();
  setUp(() {
    db = AppDatabase.memory();
    repo = TaskRepository(db);
  });
  tearDown(() => db.close());
  Future<void> add(String id, {String status = 'todo'}) => repo.addTask(
    TasksCompanion.insert(
      id: id,
      title: id,
      status: Value(status),
      taskKind: const Value('ddl'),
      deadlineUtc: now.add(const Duration(minutes: 5)),
      remindMinutes: const Value('[60,30,10]'),
      createdAtUtc: now,
      updatedAtUtc: now,
    ),
  );

  test('恢复后合并多任务和错过阈值，失败零标记，成功后不重复', () async {
    await add('a');
    await add('b');
    var failing = true;
    final bodies = <String>[];
    final reminders = ReminderService(db, (title, body, taskId) async {
      if (failing) throw StateError('notification unavailable');
      expect(title, '2 项任务需要关注');
      expect(taskId, isNull);
      bodies.add(body);
    });
    await expectLater(
      reminders.check(await repo.allTasks(), now),
      throwsStateError,
    );
    expect(await db.select(db.settings).get(), isEmpty);
    failing = false;
    await reminders.check(await repo.allTasks(), now);
    await reminders.check(await repo.allTasks(), now);
    expect(bodies, ['a、b']);
    expect(await db.select(db.settings).get(), hasLength(6));
  });

  test('恢复发送过程中重入不重复提醒', () async {
    await add('a');
    final entered = Completer<void>();
    final release = Completer<void>();
    var count = 0;
    final reminders = ReminderService(db, (_, _, _) async {
      count++;
      entered.complete();
      await release.future;
    });
    final tasks = await repo.allTasks();
    final first = reminders.check(tasks, now);
    await entered.future;
    await reminders.check(tasks, now);
    release.complete();
    await first;
    await reminders.check(tasks, now);
    expect(count, 1);
  });

  test('完成和取消任务在恢复后不补发通知', () async {
    await add('done', status: 'done');
    await add('cancelled', status: 'cancelled');
    var count = 0;
    await ReminderService(db, (_, _, _) async {
      count++;
    }).check(await repo.allTasks(), now);
    expect(count, 0);
    expect(await db.select(db.settings).get(), isEmpty);
  });
}
