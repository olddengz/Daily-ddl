/// 逾期判定辅助（v3.2 §4，精确到时刻）
class OverdueChecker {
  /// now >= deadline 即逾期；只有 todo 状态才判定
  static bool isOverdue({required String status, required DateTime deadlineUtc, required DateTime nowUtc}) {
    if (status != 'todo') return false;
    return !nowUtc.isBefore(deadlineUtc);
  }
}
