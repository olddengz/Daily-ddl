import 'package:daily_ddl/db/database.dart';
import 'package:daily_ddl/services/ai_service.dart';
import 'package:drift/drift.dart' show Value;
import 'package:daily_ddl/ui/task_calendar_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  for (final size in [const Size(900, 760), const Size(360, 440)]) {
    testWidgets('折叠总结、月年直跳和回到今天在 $size 可用', (tester) async {
      final db = AppDatabase.memory();
      addTearDown(db.close);
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final today = DateTime.now();
      final done = DateTime(today.year - 1, today.month, 11, 15).toUtc();
      await db
          .into(db.tasks)
          .insert(
            TasksCompanion.insert(
              id: 'study',
              title: '整理学期项目',
              taskKind: const Value('ddl'),
              status: const Value('done'),
              completedAtUtc: Value(done),
              deadlineUtc: done.add(const Duration(days: 1)),
              createdAtUtc: done,
              updatedAtUtc: done,
            ),
          );
      await db
          .into(db.tasks)
          .insert(
            TasksCompanion.insert(
              id: 'practice',
              title: '复习数据库',
              taskKind: const Value('daily'),
              status: const Value('done'),
              completedAtUtc: Value(done),
              deadlineUtc: done.add(const Duration(hours: 1)),
              createdAtUtc: done,
              updatedAtUtc: done,
            ),
          );
      AiConfig.instance
        ..endpoint = 'https://api.example.com'
        ..model = 'test'
        ..key = 'test-key'
        ..enabled = true;
      addTearDown(() {
        AiConfig.instance.enabled = false;
        AiConfig.instance.key = '';
      });
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh', 'CN'),
          supportedLocales: const [Locale('zh', 'CN')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(size.width == 360 ? 1.5 : 1),
            ),
            child: child!,
          ),
          home: TaskCalendarPage(db: db),
        ),
      );
      await tester.pumpAndSettle();
      final month = find.text('${today.month}月 ▾');
      await tester.tap(month);
      await tester.pumpAndSettle();
      expect(find.text('选择月份'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('1月'),
        -100,
        scrollable: find.descendant(
          of: find.byType(SimpleDialog),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.tap(find.text('1月'));
      await tester.pumpAndSettle();
      expect(find.text('1月 ▾'), findsOneWidget);
      await tester.tap(find.text('${today.year}年 ▾'));
      await tester.pumpAndSettle();
      expect(find.byType(YearPicker), findsOneWidget);
      final picker = find.byType(YearPicker);
      final previous = MaterialLocalizations.of(tester.element(picker))
          .formatYear(DateTime(today.year - 1));
      final yearScroll = tester.state<ScrollableState>(
        find.descendant(of: picker, matching: find.byType(Scrollable)),
      );
      final targetYear = find.text(previous).hitTestable();
      final initial = yearScroll.position.pixels;
      for (final delta in [0.0, 48.0, 96.0, -48.0, -96.0, 144.0]) {
        if (targetYear.evaluate().isNotEmpty) break;
        final pos = yearScroll.position;
        pos.jumpTo(
          (initial + delta).clamp(pos.minScrollExtent, pos.maxScrollExtent),
        );
        await tester.pumpAndSettle();
      }
      expect(targetYear, findsOneWidget);
      await tester.tap(targetYear);
      await tester.pumpAndSettle();
      expect(find.text('${today.year - 1}年 ▾'), findsOneWidget);
      final outer = find.byType(Scrollable).first;
      for (final label in ['周总结', '月总结', '年总结']) {
        await tester.scrollUntilVisible(
          find.text(label),
          140,
          scrollable: outer,
        );
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        expect(find.text(label), findsOneWidget);
        expect(find.text('整理学期项目'), findsNothing);
        expect(find.text('复习数据库'), findsNothing);
        expect(find.text('生成 AI 总结'), findsOneWidget);
        if (label == '年总结') {
          expect(find.text('每日任务完成 1 项'), findsOneWidget);
          expect(find.text('DDL完成 1 项'), findsOneWidget);
          // The AI entry works with both lists collapsed.
          await tester.tap(find.text('生成 AI 总结'));
          await tester.pumpAndSettle();
          expect(find.textContaining('api.example.com'), findsOneWidget);
          await tester.tap(find.text('取消'));
          await tester.pumpAndSettle();
          final ddl = find.byTooltip('展开DDL详情');
          await tester.ensureVisible(ddl);
          await tester.tap(ddl);
          await tester.pumpAndSettle();
          expect(find.text('整理学期项目'), findsOneWidget);
          expect(find.text('复习数据库'), findsNothing);
          final daily = find.byTooltip('展开每日任务详情');
          await tester.ensureVisible(daily);
          await tester.tap(daily);
          await tester.pumpAndSettle();
          expect(find.text('复习数据库'), findsOneWidget);
          expect(find.text('整理学期项目'), findsOneWidget);
          final closeDaily = find.byTooltip('收起每日任务详情');
          await tester.ensureVisible(closeDaily);
          await tester.tap(closeDaily);
          await tester.pumpAndSettle();
          expect(find.text('复习数据库'), findsNothing);
          expect(find.text('整理学期项目'), findsOneWidget);
          final closeDdl = find.byTooltip('收起DDL详情');
          await tester.ensureVisible(closeDdl);
          await tester.tap(closeDdl);
          await tester.pumpAndSettle();
          expect(find.text('整理学期项目'), findsNothing);
          expect(find.text('生成 AI 总结'), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('今天'));
      await tester.pumpAndSettle();
      expect(month, findsOneWidget);
      expect(find.text('${today.year}年 ▾'), findsOneWidget);
      expect(find.byTooltip('查看示例'), findsNothing);
      expect(await db.select(db.tasks).get(), hasLength(2));
      expect(await db.select(db.creditLedger).get(), isEmpty);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
