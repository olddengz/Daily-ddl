import 'package:drift/drift.dart';

import '../db/database.dart';
import '../db/task_repository.dart';

enum PlanResult { ok, stale, expired, insufficient }

class PlanService {
  PlanService(this.db) : _tasks = TaskRepository(db);
  final AppDatabase db;
  final TaskRepository _tasks;

  static const extensionCosts = {1: 2, 3: 7, 7: 18};
  static const _award = 'plan_completion';
  static const _extension = 'plan_extension';

  static bool isOverdue(Plan plan, DateTime now) {
    final deadline = plan.deadlineUtc;
    return plan.completedAtUtc == null &&
        deadline != null &&
        !now.isBefore(deadline);
  }

  Future<List<Plan>> all() => (db.select(
    db.plans,
  )..orderBy([(plan) => OrderingTerm.desc(plan.id)])).get();

  Future<Plan?> byId(int id) => (db.select(
    db.plans,
  )..where((plan) => plan.id.equals(id))).getSingleOrNull();

  Future<int> create(String title, DateTime? deadline, DateTime now) => db
      .into(db.plans)
      .insert(
        PlansCompanion.insert(
          title: title.trim(),
          deadlineUtc: Value(deadline?.toUtc()),
          createdAtUtc: now.toUtc(),
        ),
      );

  static int completionReward(Plan plan, DateTime now) {
    final deadline = plan.deadlineUtc;
    return deadline != null &&
            deadline.difference(now) >= const Duration(hours: 24)
        ? 3
        : 2;
  }

  Future<PlanResult> save({
    Plan? previous,
    required String title,
    required DateTime? deadline,
    required DateTime now,
  }) => db.transaction(() async {
    final name = title.trim();
    if (name.isEmpty) return PlanResult.stale;
    if (deadline != null && !deadline.isAfter(now)) return PlanResult.expired;
    if (previous == null) {
      await create(name, deadline, now);
    } else {
      if (await byId(previous.id) != previous ||
          previous.completedAtUtc != null) {
        return PlanResult.stale;
      }
      if (isOverdue(previous, now)) return PlanResult.expired;
      await _update(
        previous.id,
        PlansCompanion(
          title: Value(name),
          deadlineUtc: Value(deadline?.toUtc()),
        ),
      );
    }
    return PlanResult.ok;
  });

  Future<PlanResult> complete(Plan expected, DateTime now) =>
      db.transaction(() async {
        if (await byId(expected.id) != expected ||
            expected.completedAtUtc != null) {
          return PlanResult.stale;
        }
        if (isOverdue(expected, now)) return PlanResult.expired;

        await _update(
          expected.id,
          PlansCompanion(completedAtUtc: Value(now.toUtc())),
        );
        await _post(expected.id, now, _award, completionReward(expected, now));
        return PlanResult.ok;
      });

  Future<PlanResult> undo(Plan expected, DateTime now) =>
      db.transaction(() async {
        if (await byId(expected.id) != expected ||
            expected.completedAtUtc == null) {
          return PlanResult.stale;
        }
        final award =
            await (db.select(db.creditLedger)
                  ..where(
                    (row) =>
                        row.type.equals(_award) &
                        row.refType.equals('plan') &
                        row.refId.equals(expected.id.toString()) &
                        row.amount.isBiggerThanValue(0),
                  )
                  ..orderBy([(row) => OrderingTerm.desc(row.id)])
                  ..limit(1))
                .getSingleOrNull();
        if (award == null) return PlanResult.stale;
        await _update(
          expected.id,
          const PlansCompanion(completedAtUtc: Value(null)),
        );
        await _post(expected.id, now, _award, -award.amount.toInt());
        return PlanResult.ok;
      });

  Future<PlanResult> extend(Plan expected, int days, DateTime now) =>
      db.transaction(() async {
        final price = extensionCosts[days];
        if (price == null ||
            await byId(expected.id) != expected ||
            !isOverdue(expected, now)) {
          return PlanResult.stale;
        }
        if (await _tasks.balance(now: now) < price) {
          return PlanResult.insufficient;
        }
        final deadline = now.toUtc().add(Duration(days: days));
        await _update(
          expected.id,
          PlansCompanion(deadlineUtc: Value(deadline)),
        );
        await _post(expected.id, now, _extension, -price);
        return PlanResult.ok;
      });

  Future<PlanResult> delete(Plan expected) => db.transaction(() async {
    if (await byId(expected.id) != expected ||
        expected.completedAtUtc != null) {
      return PlanResult.stale;
    }
    await (db.delete(
      db.plans,
    )..where((plan) => plan.id.equals(expected.id))).go();
    return PlanResult.ok;
  });

  Future<void> _update(int id, PlansCompanion changes) async {
    await (db.update(
      db.plans,
    )..where((plan) => plan.id.equals(id))).write(changes);
  }

  Future<void> _post(int id, DateTime now, String type, int amount) async {
    await db
        .into(db.creditLedger)
        .insert(
          CreditLedgerCompanion.insert(
            type: type,
            amount: amount.toDouble(),
            refType: const Value('plan'),
            refId: Value('$id'),
            settleDate: TaskRepository.localDateKey(now.toLocal()),
            createdAtUtc: now.toUtc(),
          ),
        );
  }
}
