import 'package:daily_ddl/db/database.dart';
import 'package:daily_ddl/db/task_repository.dart';
import 'package:daily_ddl/services/plan_service.dart';
import 'package:daily_ddl/services/task_service.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('合并完成记录按本地日期过滤，分页跨任务和计划保持排序', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final plans = PlanService(db);
    final tasks = TaskRepository(db);
    final history = TaskService(db);
    final from = DateTime(2026, 11, 22);
    final until = DateTime(2026, 11, 23);
    final late = until.subtract(const Duration(seconds: 1));

    Future<void> plan(String title, DateTime completed) async {
      final id = await plans.create(title, null, completed);
      expect(
        await plans.complete((await plans.byId(id))!, completed),
        PlanResult.ok,
      );
    }

    Future<void> task(String id, String kind, DateTime completed) async {
      await tasks.addTask(
        TasksCompanion.insert(
          id: id,
          title: id,
          taskKind: Value(kind),
          status: const Value('done'),
          completedAtUtc: Value(completed.toUtc()),
          deadlineUtc: completed.add(const Duration(days: 3)).toUtc(),
          createdAtUtc: completed.toUtc(),
          updatedAtUtc: completed.toUtc(),
        ),
      );
    }

    await task('DDL', 'ddl', late);
    await task('每日', 'daily', from);
    await plan('范围内，截止边界前', late);
    await plan('下个本地日', until);
    await plan('上个本地日', from.subtract(const Duration(seconds: 1)));

    final first = await history.completionHistory(
      from: from,
      until: until,
      limit: 2,
    );
    final next = await history.completionHistory(
      from: from,
      until: until,
      offset: 2,
    );
    expect(first.map((r) => r.title), ['DDL', '范围内，截止边界前']);
    expect(next.map((r) => r.title), ['每日']);
    expect(
      (await history.completionHistory(
        kind: 'plan',
        from: from,
        until: until,
      )).map((r) => r.title),
      ['范围内，截止边界前'],
    );
    expect((await history.completionHistory()).length, 5);
  });
}
