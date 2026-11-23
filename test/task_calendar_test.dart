import 'package:daily_ddl/app.dart';
import 'package:daily_ddl/db/database.dart';
import 'package:daily_ddl/services/task_calendar.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('从首页进入日历，完成日、截止日和日积分分别显示', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    tester.view.physicalSize = const Size(360, 440);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final created = DateTime(2025, 1, 1).toUtc();
    await db
        .into(db.tasks)
        .insert(
          TasksCompanion.insert(
            id: 'report',
            title: '期末报告',
            taskKind: const Value('ddl'),
            status: const Value('done'),
            deadlineUtc: DateTime(2025, 2, 1, 18, 30).toUtc(),
            completedAtUtc: Value(DateTime(2025, 1, 31, 20).toUtc()),
            createdAtUtc: created,
            updatedAtUtc: created,
          ),
        );
    await db
        .into(db.tasks)
        .insert(
          TasksCompanion.insert(
            id: 'practice',
            title: '复习',
            taskKind: const Value('daily'),
            scheduledDate: const Value('2025-01-31'),
            deadlineUtc: DateTime(2025, 1, 31, 22).toUtc(),
            createdAtUtc: created,
            updatedAtUtc: created,
          ),
        );
    for (final (type, ref, amount) in [
      ('earn', 'task', 12.0),
      ('adjust', 'task', -2.0),
      ('adjust', 'reward', 5.0),
    ]) {
      await db
          .into(db.creditLedger)
          .insert(
            CreditLedgerCompanion.insert(
              type: type,
              refType: Value(ref),
              amount: amount,
              settleDate: '2025-01-31',
              createdAtUtc: created,
            ),
          );
    }
    final january = await loadTaskMonth(db, DateTime(2025, 1));
    final day = january['2025-01-31']!;
    expect(day.completed.single.id, 'report');
    expect(day.daily.single.id, 'practice');
    expect(day.deadlines, isEmpty);
    expect(day.points, 10);
    final february = await loadTaskMonth(db, DateTime(2025, 2));
    expect(february['2025-02-01']!.deadlines.single.id, 'report');
    expect(february['2025-02-01']!.completed, isEmpty);

    final today = DateUtils.dateOnly(DateTime.now());
    final due = today.add(const Duration(hours: 18, minutes: 30));
    await db
        .into(db.tasks)
        .insert(
          TasksCompanion.insert(
            id: 'today',
            title: '今天的报告',
            taskKind: const Value('ddl'),
            deadlineUtc: due.toUtc(),
            createdAtUtc: created,
            updatedAtUtc: created,
          ),
        );
    await tester.pumpWidget(App(db: db));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('任务日历'));
    await tester.pumpAndSettle();
    expect(find.text('任务日历'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('今天的报告'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('18:30'), findsOneWidget);
    final scrollable = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    scrollable.position.jumpTo(0);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('上个月'));
    await tester.pumpAndSettle();
    final previous = DateTime(today.year, today.month - 1, 2);
    await tester.tap(find.byKey(ValueKey(previous)));
    await tester.pumpAndSettle();
    final detail = find.text('${previous.month}月2日');
    await tester.scrollUntilVisible(
      detail,
      150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(detail, findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
