import 'package:daily_ddl/db/database.dart';
import 'package:daily_ddl/db/task_repository.dart';
import 'package:daily_ddl/services/task_service.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';

class FakeExtractor implements TaskExtractor {
  @override
  Future<List<TaskDraft>> extract(
    String text, {
    required DateTime now,
    required String timeZone,
  }) async => [
    TaskDraft(
      draftId: 'one',
      title: text,
      kind: 'ddl',
      deadline: now.add(const Duration(days: 2)),
    ),
  ];
}

void main() {
  late AppDatabase db;
  late TaskService service;
  final now = DateTime(2026, 10, 29, 10).toUtc();
  TaskDraft draft(
    String id, {
    DateTime? deadline,
    List<String> unresolved = const [],
  }) => TaskDraft(
    draftId: id,
    title: id,
    kind: 'ddl',
    deadline: deadline ?? now.add(const Duration(days: 1)),
    unresolved: unresolved,
  );
  setUp(() {
    db = AppDatabase.memory();
    service = TaskService(db);
  });
  tearDown(() => db.close());
  test('模拟提取、验证、预览、取消均不写任务或流水', () async {
    final rows = await FakeExtractor().extract(
      '作业',
      now: now,
      timeZone: 'Asia/Shanghai',
    );
    expect(service.validate(rows.single, now), isEmpty);
    service.prepareConfirmation(rows, now);
    expect(await service.allTasks(), isEmpty);
    expect(await TaskRepository(db).ledger(), isEmpty);
  });
  test('缺失与含糊日期禁止批准，明确临时每日任务才可默认今天', () {
    expect(
      service.validate(
        const TaskDraft(draftId: 'a', title: 'a', kind: 'ddl'),
        now,
      ),
      contains('deadline_required'),
    );
    expect(
      () => service.prepareConfirmation([
        draft('a', unresolved: ['deadline']),
      ], now),
      throwsA(isA<TaskCommandException>()),
    );
    expect(
      service.validate(
        const TaskDraft(
          draftId: 'a',
          title: 'a',
          kind: 'daily',
          explicitTemporary: true,
        ),
        now,
      ),
      isEmpty,
    );
    expect(
      service.validate(
        TaskDraft(
          draftId: 'a',
          title: 'a',
          kind: 'daily',
          deadline: now.add(const Duration(days: 1)),
        ),
        now,
      ),
      contains('daily_date'),
    );
  });
  test('批量确认、重试与并发同request只保存一次，参数冲突被拒', () async {
    final approval = service.prepareConfirmation([draft('a'), draft('b')], now);
    final results = await Future.wait([
      service.confirm(approval, requestId: 'req', now: now),
      service.confirm(approval, requestId: 'req', now: now),
    ]);
    expect(results[0], results[1]);
    expect((await service.allTasks()).length, 2);
    final changed = service.prepareConfirmation([draft('different')], now);
    await expectLater(
      service.confirm(changed, requestId: 'req', now: now),
      throwsA(
        isA<TaskCommandException>().having(
          (e) => e.code,
          'code',
          'request_conflict',
        ),
      ),
    );
    final settings = await db.select(db.settings).get();
    expect(settings.single.value, isNot(contains('title')));
  });
  test('批量后一条过期导致整批回滚，去重标记也不保存', () async {
    final approval = service.prepareConfirmation([
      draft('a'),
      draft('b', deadline: now.add(const Duration(minutes: 1))),
    ], now);
    await expectLater(
      service.confirm(
        approval,
        requestId: 'rollback',
        now: now.add(const Duration(minutes: 2)),
      ),
      throwsA(isA<TaskCommandException>()),
    );
    expect(await service.allTasks(), isEmpty);
    expect(await db.select(db.settings).get(), isEmpty);
  });
  test('确认绑定不可变快照，跨日确认拒绝；已成功命令跨日重试仍返回原结果', () async {
    final reminders = <int>[180];
    final approval = service.prepareConfirmation([
      TaskDraft(
        draftId: 'a',
        title: 'a',
        kind: 'ddl',
        deadline: now.add(const Duration(days: 3)),
        reminders: reminders,
      ),
    ], now);
    reminders.add(-1);
    await expectLater(
      service.confirm(
        approval,
        requestId: 'expired',
        now: now.add(const Duration(days: 1)),
      ),
      throwsA(
        isA<TaskCommandException>().having(
          (e) => e.code,
          'code',
          'stale_confirmation',
        ),
      ),
    );
    final ids = await service.confirm(approval, requestId: 'ok', now: now);
    expect((await service.taskById(ids.single))!.remindMinutes, '[180]');
    expect(
      await service.confirm(
        approval,
        requestId: 'ok',
        now: now.add(const Duration(days: 1)),
      ),
      ids,
    );
  });
  test('草稿提醒、重复与权重验证，权重与新任务原子保存', () async {
    final d = TaskDraft(
      draftId: 'a',
      title: 'a',
      kind: 'ddl',
      deadline: now.add(const Duration(days: 1)),
      weight: 2.5,
    );
    final ids = await service.confirm(
      service.prepareConfirmation([d], now),
      requestId: 'weight',
      now: now,
    );
    expect((await service.taskById(ids.single))!.weightOverride, 2.5);
    expect(
      service.validate(
        TaskDraft(
          draftId: 'b',
          title: 'b',
          kind: 'ddl',
          deadline: now.add(const Duration(days: 1)),
          repeatRule: 'bad',
          weight: -1,
          reminders: [-1],
        ),
        now,
      ),
      containsAll(['repeat_rule', 'weight', 'reminders']),
    );
  });
  test('历史过滤分页稳定，旧未分类完成可查，每日跨天可查', () async {
    for (var i = 0; i < 4; i++) {
      await TaskRepository(db).addTask(
        TasksCompanion.insert(
          id: 't$i',
          title: 't$i',
          taskKind: Value(
            i == 0
                ? 'daily'
                : i == 1
                ? 'legacy'
                : 'ddl',
          ),
          status: const Value('done'),
          deadlineUtc: now,
          completedAtUtc: Value(now.subtract(Duration(days: i))),
          createdAtUtc: now,
          updatedAtUtc: now,
        ),
      );
    }
    final one = await service.history(limit: 2);
    final two = await service.history(offset: 2, limit: 2);
    expect([...one, ...two].map((t) => t.id), ['t0', 't1', 't2', 't3']);
    expect((await service.history(kind: 'ddl')).length, 3);
    expect((await service.history(kind: 'daily')).length, 1);
    expect(
      () => service.history(limit: 1000),
      throwsA(isA<TaskCommandException>()),
    );
  });
  test('完整快照拦截同秒编辑后的过期操作；完成重试不再赚分', () async {
    final ids = await service.confirm(
      service.prepareConfirmation([draft('a')], now),
      requestId: 'a',
      now: now,
    );
    final old = (await service.taskById(ids.single))!;
    await TaskRepository(db).updateTask(
      old.id,
      const TasksCompanion(title: Value('changed')),
    );
    expect((await service.complete(old, now)).reason, 'stale_state');
    final current = (await service.taskById(old.id))!;
    expect((await service.complete(current, now)).ok, isTrue);
    expect((await service.complete(current, now)).ok, isFalse);
    expect((await TaskRepository(db).ledger()).length, 1);
  });
  test('历史跨日撤销只修正原完成日，过期任务恢复逾期', () async {
    final ids = await service.confirm(
      service.prepareConfirmation([
        draft('a', deadline: now.add(const Duration(hours: 2))),
      ], now),
      requestId: 'a',
      now: now,
    );
    await service.complete((await service.taskById(ids.single))!, now);
    expect(
      await service.undo(
        (await service.history()).single,
        now.add(const Duration(days: 1)),
      ),
      isTrue,
    );
    expect((await service.taskById(ids.single))!.status, 'overdue');
    expect(await service.earnedToday(now), 0);
    expect(await service.earnedToday(now.add(const Duration(days: 1))), 0);
  });
}
