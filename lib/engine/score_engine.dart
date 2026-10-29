import 'dart:math' as math;

/// 分数引擎：动态剩余池分配（阶段一核心，纯 Dart 无 UI 依赖）
///
/// 规则（v3.2 §3，锁定）：
/// - 紧迫度权重 W_urgency(d)：d≤1→×4；2~3→×3；4~7→×2；8~14→×1.5；>14→×1
/// - 优先级乘数：高×1.5 / 中×1 / 低×0.7
/// - 总权重 W_i = weightOverride ?? (W_urgency × 优先级乘数)
/// - 当日已得分 E（earn + adjust 当日净得分；2026-10-17 撤销语义变更：
///   同日撤销退回当日已得，冲正挂回原完成日；跨天撤销不影响撤销当日）
/// - 剩余池 P = max(0, 100 − E)
/// - S_i = P × W_i / ΣW（1 位小数，末位吸收：最大余数法保证显示合计恰为 P）
///
/// 性质：任意完成顺序下，当日累计恰为 100（全部完成时）；有任务未完成则 < 100。

/// 引擎输入的最小任务视图（与存储解耦，便于纯函数测试）
class ScoreTask {
  const ScoreTask({
    required this.id,
    required this.deadlineUtc,
    required this.priority,
    this.weightOverride,
    this.taskKind = 'legacy',
  });

  final String id;
  final DateTime deadlineUtc;

  /// high / medium / low
  final String priority;
  final double? weightOverride;
  final String taskKind;
}

/// 分配结果
class ScoreAllocation {
  const ScoreAllocation({
    required this.scores,
    required this.pool,
    required this.earned,
  });

  /// taskId → 当前显示分数（1 位小数，合计 == pool）
  final Map<String, double> scores;
  final double pool;
  final double earned;
}

const double kDefaultPoolSize = 100;

/// 剩余天数 d = floor((deadline − now) / 1 天)；deadline 早于 now 返回负数（调用方应先过滤逾期）
int remainingDays(DateTime deadlineUtc, DateTime nowUtc) {
  final ms = deadlineUtc.difference(nowUtc).inMilliseconds;
  return (ms / Duration.millisecondsPerDay).floor();
}

double urgencyWeight(int d) {
  if (d <= 1) return 4;
  if (d <= 3) return 3;
  if (d <= 7) return 2;
  if (d <= 14) return 1.5;
  return 1;
}

double priorityMultiplier(String priority) {
  switch (priority) {
    case 'high':
      return 1.5;
    case 'low':
      return 0.7;
    case 'medium':
    default:
      return 1;
  }
}

double taskWeight(ScoreTask t, DateTime nowUtc) {
  final override = t.weightOverride;
  if (override != null) return override;
  return urgencyWeight(remainingDays(t.deadlineUtc, nowUtc)) *
      priorityMultiplier(t.priority);
}

/// 动态剩余池分配。
///
/// [activeTasks]：未完成且未逾期的活跃任务（调用方保证已过滤）。
/// [earned]：当日净得分（earn + adjust，2026-10-17 撤销语义变更）。
/// [nowUtc]：判定紧迫度所用的当前时刻（测试可注入固定时间）。
/// 返回每个活跃任务的显示分数；活跃为空或 ΣW==0 时全为 0。
ScoreAllocation distributeScores(
  List<ScoreTask> activeTasks,
  double earned, {
  required DateTime nowUtc,
  double poolSize = kDefaultPoolSize,
}) {
  final pool = math.max(0.0, poolSize - earned);
  final totalWeight = activeTasks.fold<double>(
    0,
    (s, t) => s + taskWeight(t, nowUtc),
  );

  if (activeTasks.isEmpty || totalWeight <= 0) {
    return ScoreAllocation(
      scores: {for (final t in activeTasks) t.id: 0.0},
      pool: pool,
      earned: earned,
    );
  }

  // Existing unclassified tasks retain the old formula. Explicit daily/DDL groups
  // share the remaining pool; their completed points are never redistributed.
  final daily = activeTasks.where((t) => t.taskKind == 'daily').toList();
  final ddl = activeTasks.where((t) => t.taskKind != 'daily').toList();
  var dailyShare = 1.0;
  if (daily.isNotEmpty && ddl.isNotEmpty) {
    final hours = ddl
        .map((t) => t.deadlineUtc.difference(nowUtc).inMinutes / 60)
        .reduce(math.min);
    dailyShare = hours < 24
        ? 0.30
        : hours < 72
        ? 0.40
        : hours <= 168
        ? 0.55
        : 0.70;
  }
  final dailyWeight = daily.fold<double>(
    0,
    (s, t) => s + taskWeight(t, nowUtc),
  );
  final ddlWeight = ddl.fold<double>(0, (s, t) => s + taskWeight(t, nowUtc));
  final raw = <String, double>{};
  for (final t in activeTasks) {
    if (daily.isEmpty || ddl.isEmpty) {
      raw[t.id] = pool * taskWeight(t, nowUtc) / totalWeight;
    } else {
      final isDaily = t.taskKind == 'daily';
      raw[t.id] =
          pool *
          (isDaily ? dailyShare : 1 - dailyShare) *
          taskWeight(t, nowUtc) /
          (isDaily ? dailyWeight : ddlWeight);
    }
  }

  // 最大余数法：按 0.1 单位向下取整，剩余单位按小数余数从大到小补 0.1，保证 Σ == pool
  const scale = 10;
  final floors = <String, int>{};
  final remainders = <String, double>{};
  var floorSum = 0;
  for (final e in raw.entries) {
    final scaled = e.value * scale;
    final f = scaled.floor();
    floors[e.key] = f;
    remainders[e.key] = scaled - f;
    floorSum += f;
  }
  var leftover = (pool * scale).round() - floorSum;
  final order = remainders.keys.toList()
    ..sort((a, b) => remainders[b]!.compareTo(remainders[a]!));
  for (final id in order) {
    if (leftover <= 0) break;
    floors[id] = floors[id]! + 1;
    leftover--;
  }

  return ScoreAllocation(
    scores: {for (final e in floors.entries) e.key: e.value / scale},
    pool: pool,
    earned: earned,
  );
}

/// 完成序列模拟：给定初始活跃任务与完成顺序，返回累计得分。
/// 用于验收 A（任意完成顺序累计 == 100）。
double simulateCompletionSequence(
  List<ScoreTask> initialActive,
  List<String> completionOrder, {
  required DateTime nowUtc,
}) {
  var earned = 0.0;
  final remaining = List<ScoreTask>.from(initialActive);
  for (final id in completionOrder) {
    final alloc = distributeScores(
      remaining,
      earned,
      nowUtc: nowUtc,
      poolSize: kDefaultPoolSize,
    );
    final score = alloc.scores[id];
    if (score == null) continue; // 防御：id 不在活跃集合则跳过
    earned += score;
    remaining.removeWhere((t) => t.id == id);
  }
  return earned;
}
