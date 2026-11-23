import 'package:daily_ddl/db/database.dart';
import 'package:daily_ddl/db/task_repository.dart';
import 'package:daily_ddl/engine/daily_settlement.dart';
import 'package:daily_ddl/ui/home_page.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final midnight = DateTime(2026, 11, 23).toUtc();
  final lastNight = midnight.subtract(const Duration(seconds: 5));
  late AppDatabase db;
  late DateTime now;

  setUp(() async {
    db = AppDatabase.memory();
    now = lastNight;
    final repo = TaskRepository(db);
    await repo.addTask(
      TasksCompanion.insert(
        id: 'daily',
        title: '每日练习',
        taskKind: const Value('daily'),
        scheduledDate: Value(TaskRepository.localDateKey(lastNight.toLocal())),
        seriesId: const Value('daily'),
        repeatRule: const Value('every:1:day'),
        deadlineUtc: midnight.subtract(const Duration(seconds: 1)),
        createdAtUtc: now,
        updatedAtUtc: now,
      ),
    );
    await DailySettlement(db).run(now);
    expect((await repo.completeTask('daily', now)).ok, isTrue);
  });

  tearDown(() => db.close());

  Widget app() => MaterialApp(
    home: HomePage(db: db, now: () => now),
  );

  Future<void> expectRollover(WidgetTester tester) async {
    // Wait for the database to refresh without advancing the animation clock.
    final newDay = find.text('今日积分 0');
    for (var i = 0; i < 30 && newDay.evaluate().isEmpty; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
    }
    expect(newDay, findsOneWidget);
    expect(find.text('今日已完成 · 1'), findsNothing);
    expect(find.text('每日练习'), findsOneWidget);

    final appBar = find.byType(AppBar);
    final total = find.descendant(
      of: appBar,
      matching: find.textContaining('累计积分'),
    );
    expect(total, findsOneWidget);
    double shown() =>
        double.parse(tester.widget<Text>(total).data!.split(' ').last);
    expect(shown(), 0);
    expect(find.text('Daily DDL'), findsNothing);
    await tester.pump(const Duration(milliseconds: 280));
    expect(shown(), inExclusiveRange(0, 13));
    await tester.pumpAndSettle();
    expect(shown(), 13);

    await tester.tap(find.byTooltip('刷新'));
    await tester.pumpAndSettle();
    expect(shown(), 13);
    await tester.pumpWidget(const SizedBox.shrink());
  }

  testWidgets('应用持续打开时，在本地午夜刷新每日任务并滚动累计积分', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.text('今日积分 13（含全完成奖励 +3）'), findsOneWidget);
    expect(find.text('累计积分 0'), findsOneWidget);

    now = midnight;
    await tester.pump(const Duration(seconds: 5));
    await expectRollover(tester);
  });

  testWidgets('跨日后首次打开时，补做结算并播放累计积分增长', (tester) async {
    now = midnight.add(const Duration(hours: 8));
    await tester.pumpWidget(app());
    await expectRollover(tester);
  });
}
