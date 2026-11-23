import 'package:daily_ddl/app.dart';
import 'package:daily_ddl/db/database.dart';
import 'package:daily_ddl/db/task_repository.dart';
import 'package:daily_ddl/services/ai_service.dart';
import 'package:daily_ddl/services/task_service.dart';
import 'package:daily_ddl/ui/ai_add_page.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class LayoutExtractor implements TaskExtractor {
  @override
  Future<List<TaskDraft>> extract(
    String text, {
    required DateTime now,
    required String timeZone,
  }) async => [
    for (final title in ['测试论文', '测试阅读'])
      TaskDraft(
        draftId: title,
        title: title,
        kind: 'ddl',
        deadline: now.add(const Duration(days: 2)),
      ),
  ];
}

void main() {
  for (final size in [
    const Size(900, 760),
    const Size(400, 620),
    const Size(360, 440),
  ]) {
    testWidgets('主窗口 $size 保留全部任务与操作且无溢出', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = AppDatabase.memory();
      addTearDown(db.close);
      final now = DateTime.now().toUtc();
      for (var i = 0; i < 12; i++) {
        await TaskRepository(db).addTask(
          TasksCompanion.insert(
            id: '$i',
            title: '任务 $i：需要完整显示并可编辑的长标题',
            taskKind: const Value('ddl'),
            deadlineUtc: now.add(Duration(days: i + 1)),
            createdAtUtc: now,
            updatedAtUtc: now,
          ),
        );
      }
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(size.width == 360 ? 1.5 : 1),
            ),
            child: child!,
          ),
          home: App(db: db),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('添加任务'), findsOneWidget);
      expect(find.byTooltip('AI 设置'), findsOneWidget);
      expect(find.text('AI 添加'), findsNothing);
      expect(find.byTooltip('完成记录'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('任务 11：需要完整显示并可编辑的长标题'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('AI $size 折叠设置与逐条确认保留正确入库行为', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = AppDatabase.memory();
      addTearDown(db.close);
      final config = AiConfig.instance;
      config.enabled = true;
      config.key = 'layout-test';
      addTearDown(() {
        config.enabled = false;
        config.key = '';
      });
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(size.width == 360 ? 1.5 : 1),
            ),
            child: child!,
          ),
          home: AiAddPage(db: db, extractor: LayoutExtractor()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('提取任务'));
      await tester.pumpAndSettle();
      expect(await TaskService(db).allTasks(), isEmpty);
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, '确认添加所选任务'))
            .onPressed,
        isNull,
      );
      final schedule = find.text('重复与提醒').first;
      await tester.ensureVisible(schedule);
      await tester.tap(schedule);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('提前10分钟').first);
      await tester.tap(find.text('提前10分钟').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('提前20分钟').last);
      await tester.pumpAndSettle();
      if (size.width == 900) {
        tester.view.physicalSize = const Size(400, 620);
        await tester.pumpAndSettle();
        expect(find.text('无重复 · 提前20分钟'), findsOneWidget);
        tester.view.physicalSize = size;
        await tester.pumpAndSettle();
        expect(find.text('无重复 · 提前20分钟'), findsOneWidget);
      }
      final reviewed = find.text('我已核对本条日期、类别与重复规则').first;
      await tester.ensureVisible(reviewed);
      await tester.tap(reviewed);
      await tester.pumpAndSettle();
      final second = find.widgetWithText(CheckboxListTile, '测试阅读');
      await tester.ensureVisible(second);
      await tester.tap(second);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('确认添加所选任务'));
      await tester.tap(find.text('确认添加所选任务'));
      await tester.pumpAndSettle();
      final saved = await TaskService(db).allTasks();
      expect(saved, hasLength(1));
      expect(saved.single.title, '测试论文');
      expect(saved.single.remindMinutes, '[20]');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
