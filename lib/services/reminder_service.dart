import 'dart:convert';

import '../db/database.dart';
import '../db/settings_dao.dart';
import '../db/task_repository.dart';

class DueReminder {
  const DueReminder(this.task, this.keys);
  final Task task;
  final List<String> keys;
}

/// Collapse missed thresholds into one reminder per task. Keys include deadline
/// and occurrence ID so postponing a task creates a new reminder schedule.
List<DueReminder> dueReminders(List<Task> tasks, DateTime now) {
  final result = <DueReminder>[];
  for (final t in tasks) {
    if (t.status == 'done' || t.status == 'cancelled') continue;
    if (t.taskKind == 'daily' &&
        t.scheduledDate != TaskRepository.localDateKey(now.toLocal())) {
      continue;
    }
    final offsets = (jsonDecode(t.remindMinutes) as List).cast<int>();
    final eligible = offsets.where(
      (m) => !now.isBefore(t.deadlineUtc.subtract(Duration(minutes: m))),
    );
    final keys = [
      for (final m in eligible)
        'reminder:${t.id}:${t.deadlineUtc.millisecondsSinceEpoch}:$m',
    ];
    if (keys.isNotEmpty) result.add(DueReminder(t, keys));
  }
  return result;
}

class ReminderService {
  ReminderService(this.db, this.send);
  final AppDatabase db;
  final Future<void> Function(String title, String body, String? taskId) send;
  bool _running = false;
  Future<void> check(List<Task> tasks, DateTime now) async {
    if (_running) return;
    _running = true;
    try {
      final settings = SettingsDao(db);
      final pending = <DueReminder>[];
      for (final due in dueReminders(tasks, now)) {
        var unseen = false;
        for (final key in due.keys) {
          if (await settings.get(key) == null) unseen = true;
        }
        if (unseen) pending.add(due);
      }
      if (pending.isEmpty) return;
      await send(
        pending.length == 1 ? '任务提醒' : '${pending.length} 项任务需要关注',
        pending.take(3).map((r) => r.task.title).join('、'),
        pending.length == 1 ? pending.single.task.id : null,
      );
      await db.transaction(() async {
        for (final due in pending) {
          for (final key in due.keys) {
            await settings.set(key, 'sent');
          }
        }
      });
    } finally {
      _running = false;
    }
  }
}
