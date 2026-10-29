import '../db/database.dart';
import '../engine/overdue_checker.dart';

/// 首页任务分组（外部审查高优修复）：显式识别四状态，逾期任务不进活跃集合。
///
/// - done → 已完成组
/// - overdue（日结算已置位）→ 逾期组（**不再落入活跃**）
/// - cancelled（阶段一无产生路径，预留）→ 隔离，不参与任何组
/// - todo 且 now >= deadline（时刻级）→ 逾期组
/// - 其余 todo → 活跃组
class TaskGrouping {
  static ({List<Task> overdue, List<Task> active, List<Task> done}) group(
    List<Task> tasks,
    DateTime nowUtc,
  ) {
    final overdue = <Task>[];
    final active = <Task>[];
    final done = <Task>[];
    final today =
        '${nowUtc.toLocal().year.toString().padLeft(4, '0')}-${nowUtc.toLocal().month.toString().padLeft(2, '0')}-${nowUtc.toLocal().day.toString().padLeft(2, '0')}';
    for (final t in tasks) {
      if (t.taskKind == 'daily' && t.scheduledDate != today) continue;
      if (t.status == 'done') {
        done.add(t);
      } else if (t.status == 'overdue') {
        overdue.add(t);
      } else if (t.status == 'cancelled') {
        // 显式隔离，不参与活跃/分数
      } else if (OverdueChecker.isOverdue(
        status: t.status,
        deadlineUtc: t.deadlineUtc,
        nowUtc: nowUtc,
      )) {
        overdue.add(t);
      } else {
        active.add(t);
      }
    }
    return (overdue: overdue, active: active, done: done);
  }
}
