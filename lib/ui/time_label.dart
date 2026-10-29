/// Round upward so a future deadline never reads "0 days" or "0 minutes".
String timeRemaining(DateTime deadline, DateTime now) {
  final seconds = deadline.difference(now).inSeconds;
  final overdue = !deadline.isAfter(now);
  final n = seconds.abs();
  if (n < 60) return overdue ? '已到截止时间' : '不足 1 分钟';
  final prefix = overdue ? '已逾期' : '剩余';
  if (n < 3600) return '$prefix ${(n / 60).ceil()} 分钟';
  if (n < 86400) return '$prefix ${(n / 3600).ceil()} 小时';
  return '$prefix ${(n / 86400).ceil()} 天';
}

String formatLocalDateTime(DateTime value) {
  final d = value.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
}
