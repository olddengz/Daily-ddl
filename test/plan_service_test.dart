import 'package:daily_ddl/db/database.dart';
import 'package:daily_ddl/db/task_repository.dart';
import 'package:daily_ddl/services/plan_service.dart';
import 'package:daily_ddl/services/task_calendar.dart';
import 'package:daily_ddl/ui/calendar_summary_page.dart';
import 'package:daily_ddl/ui/task_history_page.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  final now = DateTime(2026, 11, 22, 10).toUtc();
  late AppDatabase db;
  late PlanService plans;
  late TaskRepository tasks;

  setUp(() {
    db = AppDatabase.memory();
    plans = PlanService(db);
    tasks = TaskRepository(db);
  });
  tearDown(() => db.close());

  Future<Plan> add(String title, {DateTime? due, DateTime? at}) async {
    expect(
      await plans.save(title: title, deadline: due, now: at ?? now),
      PlanResult.ok,
    );
    return (await plans.all()).first;
  }

  test('计划积分直接入账，提前至少 24 小时才加分，撤回冲正', () async {
    await tasks.refreshDailyCredits(now);
    final noDate = await add('运动');
    final early = await add('自学', due: now.add(const Duration(hours: 24)));
    final near = await add(
      '阅读',
      due: now.add(const Duration(hours: 23, minutes: 59)),
    );
    final results = await Future.wait([
      plans.complete(noDate, now),
      plans.complete(noDate, now),
      plans.complete(early, now),
      plans.complete(near, now),
    ]);
    expect(results, [
      PlanResult.ok,
      PlanResult.stale,
      PlanResult.ok,
      PlanResult.ok,
    ]);
    expect(await tasks.balance(now: now), 7);
    expect(await tasks.earnedToday(now.toLocal()), 0);
    await tasks.refreshDailyCredits(now);
    expect(await tasks.dailyCredits(now.toLocal()), (base: 0, bonus: 0));

    final done = (await plans.all()).singleWhere((p) => p.id == early.id);
    final tomorrow = now.add(const Duration(days: 1));
    expect(await plans.undo(done, tomorrow), PlanResult.ok);
    expect(await plans.undo(done, tomorrow), PlanResult.stale);
    expect(await tasks.balance(now: tomorrow), 4);
  });

  test('逾期延期仅用累计积分，按确认时间起算，余额不足或重试不重复收费', () async {
    final deadline = now.subtract(const Duration(days: 1));
    final expired = await add(
      '课程外练习',
      due: deadline,
      at: deadline.subtract(const Duration(hours: 1)),
    );
    await tasks.refreshDailyCredits(now);
    final local = TaskRepository.localDateKey(now.toLocal());
    await db
        .into(db.creditLedger)
        .insert(
          CreditLedgerCompanion.insert(
            type: 'daily_credit_base',
            amount: 10,
            settleDate: local,
            createdAtUtc: now,
          ),
        );
    expect(await plans.complete(expired, now), PlanResult.expired);
    expect(
      await plans.save(
        previous: expired,
        title: expired.title,
        deadline: null,
        now: now,
      ),
      PlanResult.expired,
    );
    expect(PlanService.extensionCosts, {1: 2, 3: 7, 7: 18});
    expect(await plans.extend(expired, 1, now), PlanResult.insufficient);

    final source = await add('短计划');
    expect(await plans.complete(source, now), PlanResult.ok);
    final attempts = await Future.wait([
      plans.extend(expired, 1, now),
      plans.extend(expired, 1, now),
    ]);
    expect(attempts, [PlanResult.ok, PlanResult.stale]);
    final renewed = (await plans.all()).singleWhere((p) => p.id == expired.id);
    expect(renewed.deadlineUtc!.toUtc(), now.add(const Duration(days: 1)));
    expect(await tasks.balance(now: now), 0);
    expect(await tasks.dailyCredits(now.toLocal()), (base: 10, bonus: 0));
    expect(
      (await tasks.ledger())
          .where((row) => row.type == 'plan_extension')
          .single
          .amount,
      -2,
    );
  });

  testWidgets('完成记录内可筛选计划和日期、查看详情并撤回', (tester) async {
    tester.view.physicalSize = const Size(400, 670);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final one = await add('跑步');
    final tomorrow = now.add(const Duration(days: 1));
    final two = await add('学习', at: tomorrow);
    expect(await plans.complete(one, now), PlanResult.ok);
    expect(await plans.complete(two, tomorrow), PlanResult.ok);
    await tester.pumpWidget(MaterialApp(home: TaskHistoryPage(db: db)));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, '计划'));
    await tester.pumpAndSettle();
    expect(find.text('跑步'), findsOneWidget);
    expect(find.text('学习'), findsOneWidget);

    await tester.tap(find.text('按日期筛选'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Switch to input'));
    await tester.pumpAndSettle();
    final dates = find.byType(TextField);
    await tester.enterText(dates.first, '11/22/2026');
    await tester.enterText(dates.last, '11/22/2026');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('2026-11-22'), findsOneWidget);
    expect(find.text('跑步'), findsOneWidget);
    expect(find.text('学习'), findsNothing);

    await tester.tap(find.text('跑步'));
    await tester.pumpAndSettle();
    expect(find.textContaining('类别：计划'), findsOneWidget);
    expect(find.textContaining('截止时间：未设置'), findsOneWidget);
    await tester.tap(find.text('关闭'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('撤销完成'));
    await tester.pumpAndSettle();
    expect((await plans.byId(one.id))!.completedAtUtc, isNull);
    expect(find.text('暂无完成记录'), findsOneWidget);
    expect(
      (await tasks.ledger())
          .where((row) => row.type == 'plan_completion')
          .map((row) => row.amount),
      [2, 2, -2],
    );

    await tester.tap(find.byTooltip('清除日期筛选'));
    await tester.pumpAndSettle();
    expect(find.text('学习'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('日历按截止日与完成日记录计划，周期总结单列计划卡片', (tester) async {
    final local = now.toLocal();
    final start = DateTime(local.year, local.month, local.day);
    final end = DateTime(local.year, local.month, local.day + 7);
    final deadline = now.add(const Duration(days: 2));
    final plan = await add('自学算法', due: deadline);
    expect(await plans.complete(plan, now), PlanResult.ok);
    final days = await loadTaskRange(db, start, end);
    final completion = days[TaskRepository.localDateKey(local)]!;
    expect(completion.completedPlans.single.title, '自学算法');
    expect(completion.completed, isEmpty);
    expect(completion.points, 0);
    expect(
      days[TaskRepository.localDateKey(deadline.toLocal())]!
          .planDeadlines
          .single
          .id,
      plan.id,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: CalendarSummaryPage(
          db: db,
          title: '周总结',
          start: start,
          end: end,
          days: Future.value(days),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('计划完成 1 项'), findsOneWidget);
    await tester.tap(find.byTooltip('展开计划详情'));
    await tester.pumpAndSettle();
    expect(find.text('自学算法'), findsOneWidget);
  });

  test('升级真实 SQLite schema 3 时保留旧任务和流水，计划表可用', () async {
    final raw = sqlite3.openInMemory();
    final original = AppDatabase(
      NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
    );
    await original.customSelect('SELECT 1').get();
    await original.close();
    raw.execute('DROP TABLE plans');
    raw.execute('PRAGMA user_version = 3');
    raw.execute("""
      INSERT INTO tasks(id,title,deadline_utc,created_at_utc,updated_at_utc)
      VALUES('old','旧任务',1790000000,1780000000,1780000000);
      INSERT INTO credit_ledger(type,amount,settle_date,created_at_utc)
      VALUES('earn',42,'2026-10-01',1780000000);
      """);
    final upgraded = AppDatabase(NativeDatabase.opened(raw));
    try {
      expect(await PlanService(upgraded).all(), isEmpty);
      expect((await TaskRepository(upgraded).allTasks()).single.title, '旧任务');
      expect((await TaskRepository(upgraded).ledger()).single.amount, 42);
      expect(
        (await upgraded.customSelect('PRAGMA user_version').getSingle())
            .data
            .values
            .single,
        4,
      );
    } finally {
      await upgraded.close();
    }
  });
}
