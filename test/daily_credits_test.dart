import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:daily_ddl/db/database.dart';
import 'package:daily_ddl/db/task_repository.dart';
import 'package:daily_ddl/engine/daily_settlement.dart';

void main() {
  late AppDatabase db;
  late TaskRepository repo;
  final today = DateTime(2026, 11, 22, 10).toUtc();
  final tomorrow = DateTime(2026, 11, 23, 10).toUtc();
  final later = DateTime(2026, 12, 5, 18).toUtc();

  String day(DateTime at) => TaskRepository.localDateKey(at.toLocal());

  Future<void> task(String id, DateTime deadline, {String kind = 'ddl'}) =>
      repo.addTask(
        TasksCompanion.insert(
          id: id,
          title: id,
          taskKind: Value(kind),
          scheduledDate: Value(kind == 'daily' ? day(deadline) : null),
          deadlineUtc: deadline,
          createdAtUtc: today,
          updatedAtUtc: today,
        ),
      );

  Future<void> score(double amount, DateTime at) async {
    await db
        .into(db.creditLedger)
        .insert(
          CreditLedgerCompanion.insert(
            type: 'earn',
            amount: amount,
            settleDate: day(at),
            createdAtUtc: at,
          ),
        );
  }

  setUp(() {
    db = AppDatabase.memory();
    repo = TaskRepository(db);
  });
  tearDown(() => db.close());

  test('按整日净得分舍入，只在变化时记积分差额', () async {
    await repo.refreshDailyCredits(today);
    await score(58, today);
    await repo.refreshDailyCredits(today);
    expect(await repo.dailyCredits(today.toLocal()), (base: 6, bonus: 0));
    expect(await repo.balance(now: today), 0);

    await score(6, today);
    await repo.refreshDailyCredits(today);
    expect(await repo.balance(now: today), 0);

    await score(1, today);
    await Future.wait([
      repo.refreshDailyCredits(today),
      repo.refreshDailyCredits(today),
    ]);
    expect(await repo.earnedToday(today.toLocal()), 65);
    final midnight = DateTime(2026, 11, 23).toUtc();
    expect(
      await repo.balance(now: midnight.subtract(const Duration(seconds: 1))),
      0,
    );
    final first = await DailySettlement(db).run(midnight);
    final repeat = await DailySettlement(db).run(midnight);
    expect(first.balanceBeforeRollover, 0);
    expect(repeat.balanceBeforeRollover, isNull);
    expect(await repo.balance(now: midnight), 7);
    expect(await repo.dailyCredits(midnight.toLocal()), (base: 0, bonus: 0));
    final converted = (await repo.ledger()).where(
      (row) => row.type == 'daily_credit_base',
    );
    expect(converted.map((row) => row.amount), [6, 1]);
  });

  test('未来 DDL 参与得分，只有每日任务和当天截止 DDL 决定奖励', () async {
    await task('daily', DateTime(2026, 11, 22, 23).toUtc(), kind: 'daily');
    await task('due', DateTime(2026, 11, 22, 18).toUtc());
    await task('future', later);
    await DailySettlement(db).run(today);

    expect((await repo.completeTask('daily', today)).ok, isTrue);
    expect((await repo.dailyCredits(today.toLocal())).bonus, 0);
    expect((await repo.completeTask('due', today)).ok, isTrue);
    final earned = await repo.earnedToday(today.toLocal());
    expect(earned, lessThan(100));
    expect(await repo.dailyCredits(today.toLocal()), (
      base: (earned / 10).round(),
      bonus: 3,
    ));

    expect((await repo.completeTask('future', today)).ok, isTrue);
    expect(await repo.dailyCredits(today.toLocal()), (base: 10, bonus: 3));
    expect(await repo.balance(now: today), 0);
    expect(await repo.balance(now: tomorrow), 13);
    expect(await repo.undoComplete('future', today), isTrue);
    expect((await repo.dailyCredits(today.toLocal())).bonus, 3);
    expect(await repo.undoComplete('due', today), isTrue);
    expect((await repo.dailyCredits(today.toLocal())).bonus, 0);
    expect((await repo.completeTask('due', today)).ok, isTrue);
    expect((await repo.dailyCredits(today.toLocal())).bonus, 3);
  });

  test('跨日撤回冲减原完成日的基础积分与到期日的奖励', () async {
    await task('due-tomorrow', tomorrow.add(const Duration(hours: 5)));
    await repo.refreshDailyCredits(today);
    expect((await repo.completeTask('due-tomorrow', today)).ok, isTrue);
    expect(await repo.dailyCredits(today.toLocal()), (base: 10, bonus: 0));
    await repo.refreshDailyCredits(tomorrow);
    expect(await repo.dailyCredits(tomorrow.toLocal()), (base: 0, bonus: 3));

    final next = DateTime(2026, 11, 24, 10).toUtc();
    expect(await repo.balance(now: tomorrow), 10);
    expect(await repo.balance(now: next), 13);
    expect(await repo.undoComplete('due-tomorrow', next), isTrue);
    expect(await repo.undoComplete('due-tomorrow', next), isFalse);
    expect(await repo.balance(now: next), 0);
    expect(await repo.dailyCredits(today.toLocal()), (base: 0, bonus: 0));
    expect(await repo.dailyCredits(tomorrow.toLocal()), (base: 0, bonus: 0));
  });

  test('逾期的当天 DDL 阻止奖励，补查关闭期间的已完成到期日', () async {
    await task('overdue-today', DateTime(2026, 11, 22, 8).toUtc());
    await task('early', tomorrow.add(const Duration(hours: 5)));
    await DailySettlement(db).run(today);
    expect((await repo.completeTask('early', today)).ok, isTrue);
    expect((await repo.dailyCredits(today.toLocal())).bonus, 0);

    final next = DateTime(2026, 11, 24, 10).toUtc();
    await DailySettlement(db).run(next);
    expect(await repo.dailyCredits(tomorrow.toLocal()), (base: 0, bonus: 3));
    expect(await repo.dailyCredits(next.toLocal()), (base: 0, bonus: 0));
  });

  test('关机时漏做的重复每日任务也会阻止对应日期的奖励', () async {
    final dailyDeadline = DateTime(2026, 11, 22, 23).toUtc();
    await repo.addTask(
      TasksCompanion.insert(
        id: 'daily-repeat',
        title: 'daily-repeat',
        taskKind: const Value('daily'),
        scheduledDate: Value(day(today)),
        seriesId: const Value('daily-repeat'),
        repeatRule: const Value('every:1:day'),
        deadlineUtc: dailyDeadline,
        createdAtUtc: today,
        updatedAtUtc: today,
      ),
    );
    await task('early', tomorrow.add(const Duration(hours: 5)));
    await DailySettlement(db).run(today);
    expect((await repo.completeTask('early', today)).ok, isTrue);
    expect((await repo.completeTask('daily-repeat', today)).ok, isTrue);

    final next = DateTime(2026, 11, 24, 10).toUtc();
    await DailySettlement(db).run(next);
    expect(await repo.dailyCredits(tomorrow.toLocal()), (base: 0, bonus: 0));
  });

  test('保留启用前历日余额，启用当天已有得分只按新规则计算一次', () async {
    final previous = DateTime(2026, 11, 21, 10).toUtc();
    await score(80, previous);
    await score(58, today);
    await repo.refreshDailyCredits(today);
    await repo.refreshDailyCredits(today);
    expect(await repo.balance(now: today), 80);
    expect(await repo.balance(now: tomorrow), 86);
    expect(await repo.earnedToday(previous.toLocal()), 80);
    expect(await repo.earnedToday(today.toLocal()), 58);
  });
}
