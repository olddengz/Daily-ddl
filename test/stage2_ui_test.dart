import 'package:daily_ddl/app.dart';
import 'package:daily_ddl/db/database.dart';
import 'package:daily_ddl/db/task_repository.dart';
import 'package:daily_ddl/services/desktop_service.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const channel = MethodChannel('daily_ddl/desktop');
  final desktop = DesktopService.instance;
  late AppDatabase db;
  var available = false;
  var sends = 0;
  setUp(() {
    db = AppDatabase.memory();
    available = false;
    sends = 0;
    desktop.windowReady = true;
    desktop.status.value = const ReminderStatus(TrayState.unavailable);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'recoverTray') available = true;
          if (call.method == 'notify') {
            sends++;
            if (!available) {
              throw PlatformException(code: 'tray', message: 'PRIVATE_DETAIL');
            }
          }
          if (call.method == 'getReminderStatus' ||
              call.method == 'recoverTray') {
            return {
              'state': available ? 'ready' : 'unavailable',
              'errorCode': 0,
            };
          }
          return null;
        });
  });
  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    desktop.windowReady = false;
    desktop.status.value = const ReminderStatus(TrayState.initializing);
    await db.close();
  });

  testWidgets('托盘不可用仍可操作窗口、退出、恢复和测试入口', (tester) async {
    await tester.pumpWidget(App(db: db));
    await tester.pumpAndSettle();
    expect(find.textContaining('系统通知暂不可用'), findsOneWidget);
    await tester.tap(find.byTooltip('桌面与提醒'));
    await tester.pumpAndSettle();
    for (final label in ['桌面精简窗口', '切换窗口置顶', '退出应用', '重试恢复通知', '测试系统提醒']) {
      final item = tester.widget<PopupMenuItem<String>>(
        find.widgetWithText(PopupMenuItem<String>, label),
      );
      expect(item.enabled, isTrue, reason: label);
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('测试失败显示中文，不向界面暴露PlatformException', (tester) async {
    await tester.pumpWidget(App(db: db));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('桌面与提醒'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('测试系统提醒'));
    await tester.pumpAndSettle();
    expect(find.textContaining('系统通知暂不可用，请在菜单中重试恢复通知'), findsOneWidget);
    expect(find.textContaining('PlatformException'), findsNothing);
    expect(find.textContaining('PRIVATE_DETAIL'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('恢复后自动补发未成功提醒，刷新不重复，失败不写标记', (tester) async {
    final now = DateTime.now().toUtc();
    await TaskRepository(db).addTask(
      TasksCompanion.insert(
        id: 'due',
        title: '课程论文',
        taskKind: const Value('ddl'),
        deadlineUtc: now.add(const Duration(minutes: 5)),
        remindMinutes: const Value('[60,30,10]'),
        createdAtUtc: now,
        updatedAtUtc: now,
      ),
    );
    await tester.pumpWidget(App(db: db));
    await tester.pumpAndSettle();
    expect(sends, 1);
    expect(await db.select(db.settings).get(), isEmpty);
    await tester.tap(find.text('重试恢复'));
    await tester.pumpAndSettle();
    expect(desktop.ready, isTrue);
    expect(sends, 2);
    expect(await db.select(db.settings).get(), hasLength(3));
    await tester.tap(find.byTooltip('刷新'));
    await tester.pumpAndSettle();
    expect(sends, 2);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
