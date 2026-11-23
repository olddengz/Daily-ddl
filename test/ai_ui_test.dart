import 'package:daily_ddl/ui/ai_add_page.dart';
import 'package:daily_ddl/ui/task_edit_page.dart';
import 'package:daily_ddl/db/database.dart';
import 'package:daily_ddl/services/ai_service.dart';
import 'package:daily_ddl/services/task_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeExtractor implements TaskExtractor {
  @override
  Future<List<TaskDraft>> extract(
    String text, {
    required DateTime now,
    required String timeZone,
  }) async => [
    TaskDraft(
      draftId: 'one',
      title: '测试论文',
      kind: 'ddl',
      deadline: DateTime(2099, 1, 1, 18),
    ),
  ];
}

void main() {
  testWidgets('从添加任务进入 AI 提取，独立设置保存后提取可用', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final c = AiConfig.instance;
    c.enabled = false;
    c.key = '';
    await tester.pumpWidget(MaterialApp(home: TaskEditPage(db: db)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('AI 文字添加'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await tester.tap(find.byTooltip('AI设置'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).at(0),
      'https://api.deepseek.com',
    );
    await tester.enterText(find.byType(TextField).at(1), 'demo');
    await tester.enterText(find.byType(TextField).at(2), 'SECRET');
    await tester.tap(find.text('保存并启用'));
    await tester.pumpAndSettle();
    expect(c.enabled, isTrue);
    expect(c.uri.host, 'api.deepseek.com');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, '提取任务'))
          .onPressed,
      isNotNull,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    c.enabled = false;
    c.key = '';
  });

  testWidgets('AI默认禁用，启用提取后不写库，核对确认才入库', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    AiConfig.instance.enabled = false;
    await tester.pumpWidget(
      MaterialApp(
        home: AiAddPage(db: db, extractor: FakeExtractor()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('提取任务'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, '提取任务'))
          .onPressed,
      isNull,
    );
    await tester.tap(find.byTooltip('AI设置'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(Switch));
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('提取任务'));
    await tester.pumpAndSettle();
    expect(await TaskService(db).allTasks(), isEmpty);
    await tester.scrollUntilVisible(
      find.byTooltip('选择截止日期'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.byTooltip('选择截止日期'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('选择截止日期'));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    Navigator.of(tester.element(find.byType(DatePickerDialog))).pop();
    await tester.pumpAndSettle();
    expect(find.textContaining('YYYY-MM-DD'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('确认添加所选任务'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('确认添加所选任务'));
    await tester.pumpAndSettle();
    expect(await TaskService(db).allTasks(), isEmpty);
    await tester.ensureVisible(find.text('我已核对本条日期、类别与重复规则'));
    await tester.tap(find.text('我已核对本条日期、类别与重复规则'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('确认添加所选任务'));
    await tester.tap(find.text('确认添加所选任务'));
    await tester.pumpAndSettle();
    expect(await TaskService(db).allTasks(), hasLength(1));
    expect((await TaskService(db).allTasks()).single.remindMinutes, '[10]');
    await tester.pumpWidget(const SizedBox.shrink());
    AiConfig.instance.enabled = false;
  });
}
