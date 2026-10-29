import 'package:daily_ddl/app.dart';
import 'package:daily_ddl/db/database.dart';
import 'package:daily_ddl/db/task_repository.dart';
import 'package:daily_ddl/ui/task_edit_page.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.memory());
  tearDown(() => db.close());
  testWidgets('不选截止时间保存为当日临时任务，不重复', (tester) async {
    await tester.pumpWidget(App(db: db));
    await tester.pumpAndSettle();
    await tester.tap(find.text('添加任务'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '临时整理');
    await tester.ensureVisible(find.text('保存任务'));
    await tester.tap(find.text('保存任务'));
    await tester.pumpAndSettle();
    final tasks = await TaskRepository(db).allTasks();
    expect(tasks.length, 1);
    final task = tasks.single;
    expect(task.taskKind, 'daily');
    expect(task.repeatRule, isNull);
    expect(task.scheduledDate, TaskRepository.localDateKey(DateTime.now()));
    expect(task.deadlineUtc.toLocal().hour, 23);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('左侧圆圈完成，已完成组可撤销，不生成明日任务', (tester) async {
    final now = DateTime.now();
    await TaskRepository(db).addTask(
      TasksCompanion.insert(
        id: 'a',
        title: '阅读重复',
        taskKind: const Value('daily'),
        scheduledDate: Value(TaskRepository.localDateKey(now)),
        seriesId: const Value('a'),
        deadlineUtc: DateTime(now.year, now.month, now.day, 23, 59, 59).toUtc(),
        repeatRule: const Value('every:1:day'),
        createdAtUtc: now.toUtc(),
        updatedAtUtc: now.toUtc(),
      ),
    );
    await tester.pumpWidget(App(db: db));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.radio_button_unchecked));
    await tester.pumpAndSettle();
    expect((await TaskRepository(db).taskById('a'))!.status, 'done');
    expect((await TaskRepository(db).allTasks()).length, 1);
    await tester.ensureVisible(find.text('今日已完成 · 1'));
    await tester.tap(find.text('今日已完成 · 1'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byIcon(Icons.check_circle));
    await tester.tap(find.byIcon(Icons.check_circle));
    await tester.pumpAndSettle();
    expect((await TaskRepository(db).taskById('a'))!.status, 'todo');
    expect(await TaskRepository(db).earnedToday(now), 0);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('360宽度150%文字缩放中文不产生布局溢出', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: TaskEditPage(db: db),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('每日任务'), findsOneWidget);
    expect(find.text('DDL 任务'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
