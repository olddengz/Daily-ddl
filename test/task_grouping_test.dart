import 'package:daily_ddl/db/database.dart';
import 'package:daily_ddl/ui/task_grouping.dart';
import 'package:flutter_test/flutter_test.dart';

/// 首页任务分组（外部审查-高优修复）：overdue 状态任务不得落入活跃集合。
void main() {
  final nowUtc = DateTime.utc(2026, 10, 16, 12, 0);

  Task task({
    required String id,
    String status = 'todo',
    DateTime? deadlineUtc,
  }) => Task(
    taskKind: 'legacy',
    scheduledDate: null,
    seriesId: null,
    id: id,
    title: id,
    course: '',
    note: '',
    type: 'self',
    priority: 'medium',
    status: status,
    source: 'manual',
    deadlineUtc: deadlineUtc ?? nowUtc.add(const Duration(days: 1)),
    remindMinutes: '[]',
    weightOverride: null,
    repeatRule: null,
    repeatEndUtc: null,
    parentTaskId: null,
    deviceId: 'windows',
    createdAtUtc: nowUtc,
    updatedAtUtc: nowUtc,
    completedAtUtc: null,
  );

  test('overdue 状态任务 → 逾期组，绝不出现在活跃组（高优）', () {
    final g = TaskGrouping.group([
      task(
        id: 'a',
        status: 'overdue',
        deadlineUtc: nowUtc.subtract(const Duration(days: 1)),
      ),
    ], nowUtc);
    expect(g.overdue.map((t) => t.id), ['a']);
    expect(g.active, isEmpty);
    expect(g.done, isEmpty);
  });

  test('todo 未到期 → 活跃组', () {
    final g = TaskGrouping.group([task(id: 'a')], nowUtc);
    expect(g.active.map((t) => t.id), ['a']);
    expect(g.overdue, isEmpty);
  });

  test('todo 已到期（now>=deadline）→ 逾期组', () {
    final g = TaskGrouping.group([task(id: 'a', deadlineUtc: nowUtc)], nowUtc);
    expect(g.overdue.map((t) => t.id), ['a']);
    expect(g.active, isEmpty);
  });

  test('done → 已完成组', () {
    final g = TaskGrouping.group([task(id: 'a', status: 'done')], nowUtc);
    expect(g.done.map((t) => t.id), ['a']);
    expect(g.active, isEmpty);
    expect(g.overdue, isEmpty);
  });

  test('cancelled → 隔离，不参与任何组（预留阶段三）', () {
    final g = TaskGrouping.group([task(id: 'a', status: 'cancelled')], nowUtc);
    expect(g.active, isEmpty);
    expect(g.overdue, isEmpty);
    expect(g.done, isEmpty);
  });

  test('混合列表分组正确', () {
    final g = TaskGrouping.group([
      task(id: 'o', status: 'overdue'),
      task(id: 't1'),
      task(id: 'd', status: 'done'),
      task(id: 't2', deadlineUtc: nowUtc), // 到期 todo → 逾期
    ], nowUtc);
    expect(g.overdue.map((t) => t.id).toSet(), {'o', 't2'});
    expect(g.active.map((t) => t.id), ['t1']);
    expect(g.done.map((t) => t.id), ['d']);
  });
}
