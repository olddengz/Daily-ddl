import 'package:drift/drift.dart';

import '../db/database.dart';
import '../db/task_repository.dart';

class CalendarDay {
  final daily = <Task>[];
  final deadlines = <Task>[];
  final completed = <Task>[];
  final planDeadlines = <Plan>[];
  final completedPlans = <Plan>[];
  double points = 0;
}

Future<Map<String, CalendarDay>> loadTaskMonth(
  AppDatabase db,
  DateTime month,
) => loadTaskRange(
  db,
  DateTime(month.year, month.month),
  DateTime(month.year, month.month + 1),
);

Future<Map<String, CalendarDay>> loadTaskRange(
  AppDatabase db,
  DateTime start,
  DateTime end,
) async {
  String key(DateTime date) => TaskRepository.localDateKey(date.toLocal());
  final first = key(start);
  final after = key(end);
  final days = <String, CalendarDay>{};
  CalendarDay day(String date) => days.putIfAbsent(date, CalendarDay.new);

  return db.transaction(() async {
    final tasks =
        await (db.select(db.tasks)
              ..where((t) {
                final scheduled =
                    t.scheduledDate.isBiggerOrEqualValue(first) &
                    t.scheduledDate.isSmallerThanValue(after);
                final due =
                    t.deadlineUtc.isBiggerOrEqualValue(start.toUtc()) &
                    t.deadlineUtc.isSmallerThanValue(end.toUtc());
                final done =
                    t.status.equals('done') &
                    t.completedAtUtc.isBiggerOrEqualValue(start.toUtc()) &
                    t.completedAtUtc.isSmallerThanValue(end.toUtc());
                return t.status.equals('cancelled').not() &
                    ((t.taskKind.equals('daily') & scheduled) |
                        ((t.taskKind.equals('ddl') | t.status.equals('archived')) & due) |
                        done);
              })
              ..orderBy([
                (t) => OrderingTerm.asc(t.deadlineUtc),
                (t) => OrderingTerm.asc(t.id),
              ]))
            .get();
    bool inRange(String date) =>
        date.compareTo(first) >= 0 && date.compareTo(after) < 0;
    for (final task in tasks) {
      final scheduled = task.scheduledDate;
      if (task.taskKind == 'daily' && scheduled != null && inRange(scheduled)) {
        day(scheduled).daily.add(task);
      }
      final due = key(task.deadlineUtc);
      if ((task.taskKind == 'ddl' || task.status == 'archived') && inRange(due)) {
        day(due).deadlines.add(task);
      }
      final completed = task.completedAtUtc;
      if (task.status == 'done' &&
          completed != null &&
          inRange(key(completed))) {
        day(key(completed)).completed.add(task);
      }
    }
    final plans = await (db.select(db.plans)..where((plan) {
          final due = plan.deadlineUtc.isBiggerOrEqualValue(start.toUtc()) &
              plan.deadlineUtc.isSmallerThanValue(end.toUtc());
          final done = plan.completedAtUtc.isBiggerOrEqualValue(start.toUtc()) &
              plan.completedAtUtc.isSmallerThanValue(end.toUtc());
          return due | done;
        })).get();
    for (final plan in plans) {
      final deadline = plan.deadlineUtc;
      final completed = plan.completedAtUtc;
      if (deadline != null && inRange(key(deadline))) {
        day(key(deadline)).planDeadlines.add(plan);
      }
      if (completed != null && inRange(key(completed))) {
        day(key(completed)).completedPlans.add(plan);
      }
    }
    for (final entry in days.values) {
      entry.planDeadlines.sort((a, b) => a.deadlineUtc!.compareTo(b.deadlineUtc!));
      entry.completedPlans.sort(
        (a, b) => b.completedAtUtc!.compareTo(a.completedAtUtc!),
      );
      entry.completed.sort(
        (a, b) => b.completedAtUtc!.compareTo(a.completedAtUtc!),
      );
    }
    final ledger =
        await (db.select(db.creditLedger)..where(
              (l) =>
                  l.settleDate.isBiggerOrEqualValue(first) &
                  l.settleDate.isSmallerThanValue(after) &
                  (l.type.equals('earn') | l.type.equals('adjust')) &
                  (l.refType.isNull() | l.refType.equals('task')),
            ))
            .get();
    for (final entry in ledger) {
      day(entry.settleDate).points += entry.amount;
    }
    return days;
  });
}
