import 'dart:convert';

import 'package:daily_ddl/app.dart';
import 'package:daily_ddl/db/database.dart';
import 'package:daily_ddl/db/task_repository.dart';
import 'package:daily_ddl/services/ai_service.dart';
import 'package:daily_ddl/services/plan_service.dart';
import 'package:daily_ddl/services/task_service.dart';
import 'package:daily_ddl/ui/ai_add_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

String _response(String content) => jsonEncode({
  'choices': [
    {
      'message': {'content': content},
    },
  ],
});

class _PlanExtractor implements TaskExtractor {
  @override
  Future<List<TaskDraft>> extract(
    String text, {
    required DateTime now,
    required String timeZone,
  }) async => ApiTaskExtractor.decode(
    _response('{"tasks":[{"title":"练习跑步","kind":"plan","deadline":null}]}'),
  );
}

void main() {
  test('混合确认把 AI 计划和 DDL 各自入库，重试不会重复写入', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final now = DateTime(2026, 11, 22, 10);
    final service = TaskService(db);
    final decoded = ApiTaskExtractor.decode(
      _response(
        '{"tasks":[{"title":"跑步","kind":"plan","deadline":null},'
        '{"title":"论文","kind":"ddl","deadline":"2026-12-01T18:00:00+08:00"}]}',
      ),
    );
    final dated = ApiTaskExtractor.resolveInputDates(
      [decoded.first],
      '今天完成计划：跑步',
      now,
    );
    expect(dated.single.kind, 'plan');
    expect(dated.single.deadline!.toLocal().day, now.day);
    final approval = service.prepareConfirmation(decoded, now);
    final first = await service.confirm(
      approval,
      requestId: 'mixed-plans',
      now: now,
    );
    expect(
      await service.confirm(approval, requestId: 'mixed-plans', now: now),
      first,
    );
    expect(first.first, startsWith('plan:'));
    expect((await service.allTasks()).single.title, '论文');
    expect((await PlanService(db).all()).single.title, '跑步');
  });

  testWidgets('首页添加计划，完成时勾选动画，积分即到账且可从今日记录撤回', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await tester.pumpWidget(App(db: db));
    await tester.pumpAndSettle();
    await tester.tap(find.text('添加任务'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('计划'));
    await tester.pumpAndSettle();
    expect(find.text('设置截止时间（可选）'), findsOneWidget);
    expect(find.text('重复与提醒'), findsNothing);
    expect(find.text('优先级'), findsNothing);
    await tester.enterText(find.byType(TextField), '自学算法');
    await tester.tap(find.text('保存任务'));
    await tester.pumpAndSettle();

    final pending = find.byTooltip('完成计划');
    await tester.ensureVisible(pending);
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('计划 · 1')).dy,
      greaterThan(tester.getTopLeft(find.text('DDL 任务 · 0')).dy),
    );
    await tester.tap(pending);
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 80)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('自学算法'), findsOneWidget);
    expect(find.byTooltip('撤销计划完成'), findsOneWidget);
    expect(find.text('累计积分 2'), findsOneWidget);
    expect(await TaskRepository(db).earnedToday(DateTime.now()), 0);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    final group = find.text('今日已完成 · 1');
    await tester.ensureVisible(group);
    await tester.pumpAndSettle();
    await tester.tap(group);
    await tester.pumpAndSettle();
    expect(find.text('自学算法'), findsOneWidget);
    final undo = find.byTooltip('撤销计划完成');
    await tester.ensureVisible(undo);
    await tester.pumpAndSettle();
    await tester.tap(undo);
    await tester.pumpAndSettle();
    expect(find.text('累计积分 0'), findsOneWidget);
    expect(group, findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('AI 提取的计划在确认后添加，无截止时间时可保存', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final config = AiConfig.instance;
    config.enabled = true;
    addTearDown(() => config.enabled = false);
    await tester.pumpWidget(
      MaterialApp(
        home: AiAddPage(db: db, extractor: _PlanExtractor()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('提取任务'));
    await tester.pumpAndSettle();
    final selected = find.text('我已核对本条计划的类别和时间');
    await tester.ensureVisible(selected);
    await tester.pumpAndSettle();
    expect(find.text('可不设置'), findsOneWidget);
    expect(find.text('重复与提醒'), findsNothing);
    expect(await PlanService(db).all(), isEmpty);
    await tester.tap(selected);
    await tester.pumpAndSettle();
    final save = find.text('确认添加所选任务');
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();
    final plan = (await PlanService(db).all()).single;
    expect(plan.title, '练习跑步');
    expect(plan.deadlineUtc, isNull);
  });
}
