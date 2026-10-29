import 'package:drift/drift.dart';

import '../engine/recurrence.dart';
import '../engine/score_engine.dart';
import 'database.dart';

/// 任务仓储：CRUD + 结算事务（v3.2 §3.3，全部同事务）
///
/// 锁定的结算规则：
/// - 完成：校验未逾期 → 冻结 S_i（动态剩余池）→ done + earn 流水同事务
///   → 循环任务生成下一实例（同一事务）
/// - 撤销完成：adjust 冲正（settle_date 挂回原完成日，同日撤销退回当日已得、
///   跨天只改余额与历史净得分）+ 状态回滚 + 删除已自动生成的下一实例（同一事务）
/// - 删除：仅 todo/overdue；done 不可删只能撤销；删除循环实例 = 跳过本次
/// - 逾期：置 overdue、移出活跃集合、无流水

/// 完成操作结果
class CompleteResult {
  const CompleteResult({required this.ok, this.score, this.reason});

  final bool ok;
  final double? score;

  /// 失败原因：already_done / overdue / not_found
  final String? reason;
}

class TaskRepository {
  TaskRepository(this.db);

  final AppDatabase db;

  // ---------- 查询 ----------

  /// 活跃任务：todo 且 deadline > now（未逾期）
  Future<List<Task>> activeTasks(DateTime nowUtc) async {
    final now = nowUtc;
    final rows =
        await (db.select(db.tasks)..where(
              (t) =>
                  t.status.equals('todo') &
                  t.deadlineUtc.isBiggerThanValue(now),
            ))
            .get();
    return rows
        .where(
          (t) =>
              t.taskKind != 'daily' ||
              t.scheduledDate == localDateKey(nowUtc.toLocal()),
        )
        .toList();
  }

  Future<List<Task>> allTasks() => db.select(db.tasks).get();

  Future<Task?> taskById(String id) =>
      (db.select(db.tasks)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// 当日净得分（earn + adjust，按本地日期 settle_date）。
  /// 试用修复（2026-10-17）：撤销完成的冲正记录挂回原完成日 settle_date，
  /// 因此同日撤销会退回当日已得（池恢复可重拿完整份额）；
  /// 跨天撤销只影响原完成日的历史净得分与余额，撤销当天不会出现负数。
  Future<double> earnedToday(DateTime nowLocal) async {
    final settleDate = _localDateKey(nowLocal);
    final rows =
        await (db.select(db.creditLedger)..where(
              (l) =>
                  (l.type.equals('earn') | l.type.equals('adjust')) &
                  l.settleDate.equals(settleDate),
            ))
            .get();
    return rows.fold<double>(0, (s, r) => s + r.amount);
  }

  Future<double> balance() async {
    final rows = await db.select(db.creditLedger).get();
    return rows.fold<double>(0, (s, r) => s + r.amount);
  }

  Future<List<CreditLedgerData>> ledger() => db.select(db.creditLedger).get();

  // ---------- 增删改 ----------

  Future<void> addTask(TasksCompanion c) => db.into(db.tasks).insert(c);

  /// 更新：仅更新伴生对象中显式提供的列（write 语义），
  /// 避免 replace() 把 status/source/deviceId 等未编辑列重置为默认值（审查 P1-2）。
  ///
  /// 延期恢复（外部审查-高）：若任务当前为 overdue 且 deadline 被更新到未来
  /// （nowUtc 之前），自动恢复为 todo，避免"逾期任务 0 分完成"。
  Future<void> updateTask(
    String id,
    TasksCompanion c, {
    DateTime? nowUtc,
  }) async {
    final now = nowUtc ?? DateTime.now().toUtc();
    final t = await taskById(id);
    if (t == null) return;
    // Converting out of a daily series must stop older occurrences from reviving it.
    if (t.taskKind == 'daily' &&
        t.seriesId != null &&
        c.taskKind.present &&
        c.taskKind.value != 'daily') {
      await (db.update(
        db.tasks,
      )..where((r) => r.seriesId.equals(t.seriesId!))).write(
        const TasksCompanion(
          repeatRule: Value(null),
          repeatEndUtc: Value(null),
        ),
      );
    }
    var effective = c;
    final newDeadline = c.deadlineUtc.present ? c.deadlineUtc.value : null;
    if (t.status == 'overdue' &&
        newDeadline != null &&
        newDeadline.isAfter(now)) {
      effective = c.copyWith(status: const Value('todo'));
    }
    await (db.update(
      db.tasks,
    )..where((tbl) => tbl.id.equals(id))).write(effective);
  }

  /// 删除：仅 todo/overdue；done 不可删（返回 false）
  Future<bool> deleteTask(String id) async {
    final t = await taskById(id);
    if (t == null) return false;
    if (t.status == 'done') return false;
    if (t.taskKind == 'daily') {
      await (db.update(db.tasks)..where((r) => r.id.equals(id))).write(
        const TasksCompanion(status: Value('cancelled')),
      );
    } else {
      await (db.delete(db.tasks)..where((tbl) => tbl.id.equals(id))).go();
    }
    return true;
  }

  // ---------- 完成（同事务） ----------

  Future<CompleteResult> completeTask(String id, DateTime nowUtc) async {
    return db.transaction(() async {
      final t = await taskById(id);
      if (t == null) {
        return const CompleteResult(ok: false, reason: 'not_found');
      }
      if (t.status == 'done') {
        return const CompleteResult(ok: false, reason: 'already_done');
      }
      if (t.status == 'cancelled' ||
          (t.taskKind == 'daily' &&
              t.scheduledDate != localDateKey(nowUtc.toLocal()))) {
        return const CompleteResult(ok: false, reason: 'not_today');
      }

      // 完成前复检：now >= deadline → 拒绝并置 overdue（验收 B）
      if (!nowUtc.isBefore(t.deadlineUtc)) {
        await _markOverdue(id, nowUtc);
        return const CompleteResult(ok: false, reason: 'overdue');
      }

      final active = await activeTasks(nowUtc);
      final nowLocal = nowUtc.toLocal();
      final earned = await earnedToday(nowLocal);
      final alloc = distributeScores(
        [
          for (final a in active)
            ScoreTask(
              id: a.id,
              deadlineUtc: a.deadlineUtc,
              priority: a.priority,
              weightOverride: a.weightOverride,
              taskKind: a.taskKind,
            ),
        ],
        earned,
        nowUtc: nowUtc,
      );
      final score = alloc.scores[id] ?? 0.0;

      // 1) earn 流水
      await db
          .into(db.creditLedger)
          .insert(
            CreditLedgerCompanion.insert(
              type: 'earn',
              amount: score,
              refType: const Value('task'),
              refId: Value(id),
              settleDate: _localDateKey(nowLocal),
              note: const Value('complete'),
              createdAtUtc: nowUtc,
            ),
          );

      // 2) 任务置 done
      await (db.update(db.tasks)..where((t) => t.id.equals(id))).write(
        TasksCompanion(
          status: const Value('done'),
          completedAtUtc: Value(nowUtc),
          updatedAtUtc: Value(nowUtc),
        ),
      );

      // 3) 循环任务 → 生成下一实例（同一事务）
      final next = nextDeadline(t.deadlineUtc, t.repeatRule, t.repeatEndUtc);
      if (next != null && t.taskKind != 'daily') {
        final childId = '${id}_r${nowUtc.millisecondsSinceEpoch}';
        await db
            .into(db.tasks)
            .insert(
              TasksCompanion.insert(
                id: childId,
                taskKind: Value(t.taskKind),
                title: t.title,
                course: Value(t.course),
                note: Value(t.note),
                type: Value(t.type),
                priority: Value(t.priority),
                deadlineUtc: next,
                remindMinutes: Value(t.remindMinutes),
                weightOverride: Value(t.weightOverride),
                status: const Value('todo'),
                source: const Value('recurring'),
                deviceId: const Value('windows'),
                createdAtUtc: nowUtc,
                updatedAtUtc: nowUtc,
                repeatRule: Value(t.repeatRule),
                repeatEndUtc: Value(t.repeatEndUtc),
                parentTaskId: Value(id),
              ),
            );
      }

      return CompleteResult(ok: true, score: score);
    });
  }

  // ---------- 撤销完成（同事务） ----------

  Future<bool> undoComplete(String id, DateTime nowUtc) async {
    return db.transaction(() async {
      final t = await taskById(id);
      if (t == null || t.status != 'done') return false;

      // 找到该任务最近一条 earn 流水
      final earns =
          await (db.select(db.creditLedger)
                ..where(
                  (l) =>
                      l.type.equals('earn') &
                      l.refType.equals('task') &
                      l.refId.equals(id),
                )
                ..orderBy([(l) => OrderingTerm.desc(l.id)])
                ..limit(1))
              .get();
      if (earns.isEmpty) return false;
      final earn = earns.first;

      // 1) adjust 冲正：settle_date 挂回原 earn 的完成日（试用修复 2026-10-17），
      //    使同日撤销退回当日已得、跨天撤销只影响原日与余额（不污染撤销当日）
      await db
          .into(db.creditLedger)
          .insert(
            CreditLedgerCompanion.insert(
              type: 'adjust',
              amount: -earn.amount,
              refType: const Value('task'),
              refId: Value(id),
              settleDate: earn.settleDate,
              note: Value('undo:${earn.id}'),
              createdAtUtc: nowUtc,
            ),
          );

      // 2) 状态回滚：deadline 已过 → overdue，否则 todo
      final revertStatus = nowUtc.isBefore(t.deadlineUtc) ? 'todo' : 'overdue';
      await (db.update(db.tasks)..where((tbl) => tbl.id.equals(id))).write(
        TasksCompanion(
          status: Value(revertStatus),
          completedAtUtc: const Value(null),
          updatedAtUtc: Value(nowUtc),
        ),
      );

      // 3) 删除完成时自动生成的下一实例（parent_task_id == id 且未完成；done 子实例保留——第三轮审查 P3-1 修复：overdue 子实例一并删除，避免孤儿残留）
      await (db.delete(db.tasks)..where(
            (tbl) =>
                tbl.parentTaskId.equals(id) &
                (tbl.status.equals('todo') | tbl.status.equals('overdue')),
          ))
          .go();

      return true;
    });
  }

  /// Materialize only the current scheduled occurrence, regardless of prior completion.
  /// Unique (series,date) plus transaction makes startup/resume/timer calls idempotent.
  Future<void> ensureDailyInstances(DateTime nowUtc) =>
      db.transaction(() async {
        final today = localDateKey(nowUtc.toLocal());
        final rows = await (db.select(
          db.tasks,
        )..where((t) => t.taskKind.equals('daily'))).get();
        final latest = <String, Task>{};
        for (final t in rows) {
          final series = t.seriesId;
          if (series == null || t.scheduledDate == null) continue;
          if (!latest.containsKey(series) ||
              t.scheduledDate!.compareTo(latest[series]!.scheduledDate!) > 0) {
            latest[series] = t;
          }
        }
        for (final entry in latest.entries) {
          final t = entry.value;
          if (t.scheduledDate!.compareTo(today) >= 0 || t.repeatRule == null) {
            continue;
          }
          var next = nextDeadline(t.deadlineUtc, t.repeatRule, t.repeatEndUtc);
          while (next != null &&
              localDateKey(next.toLocal()).compareTo(today) < 0) {
            next = nextDeadline(next, t.repeatRule, t.repeatEndUtc);
          }
          if (next == null || localDateKey(next.toLocal()) != today) continue;
          await db
              .into(db.tasks)
              .insert(
                TasksCompanion.insert(
                  id: 'daily_${entry.key}_$today',
                  title: t.title,
                  taskKind: const Value('daily'),
                  scheduledDate: Value(today),
                  seriesId: Value(entry.key),
                  course: Value(t.course),
                  note: Value(t.note),
                  type: Value(t.type),
                  priority: Value(t.priority),
                  deadlineUtc: next,
                  remindMinutes: Value(t.remindMinutes),
                  weightOverride: Value(t.weightOverride),
                  repeatRule: Value(t.repeatRule),
                  repeatEndUtc: Value(t.repeatEndUtc),
                  source: const Value('recurring'),
                  createdAtUtc: nowUtc,
                  updatedAtUtc: nowUtc,
                ),
              );
        }
      });

  // ---------- 逾期（v3.2 §4） ----------

  /// 将 now >= deadline 的 todo 置 overdue；返回置位数。
  Future<int> markOverdueAll(DateTime nowUtc) => db.transaction(() async {
    final toMark =
        await (db.select(db.tasks)..where(
              (t) =>
                  t.status.equals('todo') &
                  t.deadlineUtc.isSmallerOrEqualValue(nowUtc),
            ))
            .get();
    for (final t in toMark) {
      await _markOverdue(t.id, nowUtc);
    }
    return toMark.length;
  });

  Future<void> _markOverdue(String id, DateTime nowUtc) =>
      (db.update(db.tasks)..where((t) => t.id.equals(id))).write(
        TasksCompanion(
          status: const Value('overdue'),
          completedAtUtc: const Value(null),
          updatedAtUtc: Value(nowUtc),
        ),
      );

  // ---------- 工具 ----------

  static String _localDateKey(DateTime local) =>
      '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';

  /// 本地日期键（YYYY-MM-DD），供外部使用
  static String localDateKey(DateTime local) => _localDateKey(local);
}
