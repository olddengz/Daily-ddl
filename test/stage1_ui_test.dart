import 'package:daily_ddl/app.dart';
import 'package:daily_ddl/db/database.dart';
import 'package:daily_ddl/db/task_repository.dart';
import 'package:daily_ddl/ui/home_page.dart';
import 'package:daily_ddl/ui/time_label.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.memory());
  tearDown(() => db.close());
  Future<void> add({String id = 'ddl', String status = 'todo'}) async {
    final now = DateTime.now().toUtc();
    await TaskRepository(db).addTask(
      TasksCompanion.insert(
        id: id,
        title: '课程论文',
        taskKind: const Value('ddl'),
        status: Value(status),
        completedAtUtc: status == 'done'
            ? Value(now.subtract(const Duration(days: 5)))
            : const Value(null),
        deadlineUtc: now.add(const Duration(days: 2)),
        createdAtUtc: now,
        updatedAtUtc: now,
      ),
    );
  }

  test('时间格式本地时分，不含秒和毫秒', () {
    expect(
      formatLocalDateTime(DateTime(2026, 10, 29, 8, 5, 59, 123)),
      '2026-10-29 08:05',
    );
  });
  testWidgets('完成DDL保留可见勾选过程，归档后可从提示撤销且积分恢复', (tester) async {
    await add();
    await tester.pumpWidget(App(db: db));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.radio_button_unchecked));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 80)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('课程论文'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('课程论文'), findsNothing);
    expect(find.textContaining('已完成 · 获得'), findsOneWidget);
    await tester.tap(find.text('撤销'));
    await tester.pumpAndSettle();
    expect(find.text('课程论文'), findsOneWidget);
    expect(await TaskRepository(db).earnedToday(DateTime.now()), 0);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('完成提示约3秒自动消失，无障碍导航下也不常驻', (tester) async {
    await add();
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(accessibleNavigation: true),
          child: HomePage(db: db),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.radio_button_unchecked));
    await tester.pumpAndSettle();
    expect(find.textContaining('已完成 · 获得'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.textContaining('已完成 · 获得'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.textContaining('已完成 · 获得'), findsNothing);
    expect((await TaskRepository(db).taskById('ddl'))!.status, 'done');
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('连续完成替换提示，不排队，撤销针对最新任务', (tester) async {
    await add(id: 'first');
    await add(id: 'second');
    await tester.pumpWidget(App(db: db));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.radio_button_unchecked).first);
    await tester.pumpAndSettle();
    final tasks = await TaskRepository(db).allTasks();
    final latest = tasks.singleWhere((task) => task.status == 'todo');
    await tester.tap(find.byIcon(Icons.radio_button_unchecked));
    await tester.pumpAndSettle();
    await tester.tap(find.text('撤销'));
    await tester.pumpAndSettle();
    expect((await TaskRepository(db).taskById(latest.id))!.status, 'todo');
    expect(
      (await TaskRepository(db).allTasks()).where((t) => t.status == 'done'),
      hasLength(1),
    );
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.textContaining('已完成 · 获得'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('过往DDL完成只在历史中可查，详情只读，历史可撤销', (tester) async {
    await add(status: 'done');
    await tester.pumpWidget(App(db: db));
    await tester.pumpAndSettle();
    expect(find.text('课程论文'), findsNothing);
    await tester.tap(find.byTooltip('完成记录'));
    await tester.pumpAndSettle();
    expect(find.text('课程论文'), findsOneWidget);
    await tester.tap(find.text('课程论文'));
    await tester.pumpAndSettle();
    expect(find.textContaining('截止时间：'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.text('关闭'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('撤销完成'));
    await tester.pumpAndSettle();
    // Fixture has no earn ledger, so undo fails safely and the record stays.
    expect((await TaskRepository(db).taskById('ddl'))!.status, 'done');
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('动画中刷新及连点不重复记分，页面离开无回调异常', (tester) async {
    await add();
    await tester.pumpWidget(App(db: db));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.radio_button_unchecked));
    await tester.tap(
      find.byIcon(Icons.radio_button_unchecked),
      warnIfMissed: false,
    );
    await tester.tap(find.byTooltip('刷新'));
    await tester.pumpAndSettle();
    expect((await TaskRepository(db).ledger()).length, 1);
    expect(find.text('课程论文'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });
  testWidgets('任务收起之前立即撤销可取消归档', (tester) async {
    await add();
    await tester.pumpWidget(App(db: db));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.radio_button_unchecked));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 60)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('撤销'));
    await tester.pumpAndSettle();
    expect(find.text('课程论文'), findsOneWidget);
    expect((await TaskRepository(db).taskById('ddl'))!.status, 'todo');
    expect(await TaskRepository(db).earnedToday(DateTime.now()), 0);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('提交后立即销毁页面不会更新已销毁状态', (tester) async {
    await add();
    await tester.pumpWidget(App(db: db));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.radio_button_unchecked));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('减少动画下仍正确归档，窄屏标题及历史入口无溢出', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await add();
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            disableAnimations: true,
            textScaler: TextScaler.linear(1.5),
          ),
          child: HomePage(db: db),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.radio_button_unchecked));
    await tester.pumpAndSettle();
    expect(find.text('课程论文'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
