// 定期代办（F13）：重复规则解析与下一实例截止时间计算（纯 Dart）
//
// 规则（v3.2 §3.3 / §6，锁定）：
// - repeat_rule 格式 `every:N:unit`，N≥1，unit ∈ day/week/month；NULL 表示不重复
// - 下一实例 deadline = 原 deadline + N 单位（保留原时刻）
// - 月顺延：目标月无该日 → 取该月最后一天（如 1-31 → 2-28/29）
// - repeat_end_utc：到点（下一实例截止 > end）不再生成；为 NULL 永不结束
// - 逾期不生成（调用方在完成校验失败时不调用本函数）

class RepeatRule {
  const RepeatRule({required this.interval, required this.unit});

  final int interval;

  /// day / week / month
  final String unit;

  static RepeatRule? parse(String? rule) {
    if (rule == null || rule.isEmpty) return null;
    final parts = rule.split(':');
    if (parts.length != 3 || parts[0] != 'every') return null;
    final n = int.tryParse(parts[1]);
    final unit = parts[2];
    if (n == null || n < 1) return null;
    if (unit != 'day' && unit != 'week' && unit != 'month') return null;
    return RepeatRule(interval: n, unit: unit);
  }
}

/// 月顺延并钳制到月末（外部审查修复：按本地日历月份计算，再转回 UTC 存储）。
///
/// "每月"以用户本地日历为准（如北京 1-31 07:00 的下一实例是本地 2 月末，
/// 而不是按 UTC 月份跳进 3 月）。Dart DateTime 对溢出日会向后滚动
/// （如 2 月 31 日 → 3 月 3 日），因此构造后校验「实际月份 == 目标月份」，
/// 不符则取目标月最后一天。
DateTime addMonthsClamped(DateTime dt, int months) {
  final local = dt.toLocal();
  final targetMonth = ((local.month - 1 + months) % 12) + 1;
  final targetYear = local.year + ((local.month - 1 + months) ~/ 12);
  var candidate = DateTime(
    local.year,
    local.month + months,
    local.day,
    local.hour,
    local.minute,
    local.second,
    local.millisecond,
    local.microsecond,
  );
  if (candidate.month != targetMonth) {
    // 目标月无该日 → 取目标月最后一天（下个月的第 0 天）
    candidate = DateTime(
      targetYear,
      targetMonth + 1,
      0,
      local.hour,
      local.minute,
      local.second,
      local.millisecond,
      local.microsecond,
    );
  }
  return candidate.toUtc();
}

/// 计算下一实例截止时间。
///
/// [originalDeadlineUtc]：当前实例截止（UTC）。
/// [rule]：repeat_rule；为 null/无法解析 → 返回 null（不重复）。
/// [repeatEndUtc]：结束日期；null 表示永不结束。
/// 返回 null 表示不应生成下一实例（不重复 / 已过结束日期）。
DateTime? nextDeadline(DateTime originalDeadlineUtc, String? rule, DateTime? repeatEndUtc) {
  // drift 读回的时间是本地时区表示（isUtc=false），必须先统一到 UTC 再做算术，
  // 否则加天数会产生时区偏移（2026-10-16 实测：UTC+8 环境偏差 8 小时）。
  final base = originalDeadlineUtc.toUtc();
  final end = repeatEndUtc?.toUtc();
  final r = RepeatRule.parse(rule);
  if (r == null) return null;
  if (end != null && !base.isBefore(end)) {
    return null; // 当前实例截止已不在结束日期之前 → 不再生成
  }
  final next = switch (r.unit) {
    'day' => base.add(Duration(days: r.interval)),
    'week' => base.add(Duration(days: 7 * r.interval)),
    'month' => addMonthsClamped(base, r.interval),
    _ => base,
  };
  if (end != null && next.isAfter(end)) {
    return null; // 下一实例超过结束日期 → 停止
  }
  return next;
}
