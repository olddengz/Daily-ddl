import 'package:daily_ddl/services/desktop_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('daily_ddl/desktop');
  const windowChannel = MethodChannel('window_manager');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late DesktopService desktop;
  late List<MethodCall> calls;
  String state = 'ready';
  bool failSend = false;

  setUp(() {
    desktop = DesktopService();
    calls = [];
    state = 'ready';
    failSend = false;
    messenger.setMockMethodCallHandler(windowChannel, (call) async => null);
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      switch (call.method) {
        case 'getReminderStatus':
        case 'recoverTray':
          return {'state': state, 'errorCode': state == 'ready' ? 0 : 31};
        case 'notify':
          if (failSend) {
            throw PlatformException(code: 'tray', message: 'PRIVATE_DETAIL');
          }
          return null;
        default:
          return null;
      }
    });
  });
  tearDown(() {
    channel.setMethodCallHandler(null);
    messenger.setMockMethodCallHandler(channel, null);
    messenger.setMockMethodCallHandler(windowChannel, null);
    desktop.status.dispose();
  });

  test('初始化查询真实状态，托盘不可用不阻塞窗口功能', () async {
    state = 'unavailable';
    await desktop.initialize();
    expect(desktop.ready, isFalse);
    expect(desktop.windowReady, isTrue);
    expect(desktop.status.value.errorCode, 31);
    await desktop.exit();
    expect(calls.last.method, 'exit');
  });

  test('原生运行时状态推送同步，无需重启，通知点击保持可达', () async {
    await desktop.initialize();
    expect(desktop.ready, isTrue);
    String? opened;
    desktop.onOpenTask = (id) async => opened = id;
    Future<void> push(String method, Object? args) async {
      await messenger.handlePlatformMessage(
        channel.name,
        const StandardMethodCodec().encodeMethodCall(MethodCall(method, args)),
        (_) {},
      );
    }

    await push('trayStateChanged', {'state': 'unavailable', 'errorCode': 31});
    expect(desktop.ready, isFalse);
    await push('trayStateChanged', {'state': 'ready', 'errorCode': 0});
    expect(desktop.ready, isTrue);
    await push('openTask', 'task-id');
    expect(opened, 'task-id');
  });

  test('测试通知只报告系统接受请求，不承诺弹窗可见', () async {
    final result = await desktop.requestTestNotification();
    expect(result.accepted, isTrue);
    expect(result.message, contains('已请求系统通知'));
    expect(calls.where((call) => call.method == 'notify'), hasLength(1));
  });

  test('发送失败返回中文和稳定错误码，不暴露平台异常且不在Dart重复发送', () async {
    state = 'unavailable';
    failSend = true;
    final result = await desktop.requestTestNotification();
    expect(result.accepted, isFalse);
    expect(result.code, 'notification_unavailable');
    expect(result.message, isNot(contains('PRIVATE_DETAIL')));
    expect(result.message, isNot(contains('PlatformException')));
    expect(desktop.ready, isFalse);
    expect(calls.where((call) => call.method == 'notify'), hasLength(1));
    state = 'ready';
    expect((await desktop.recoverTray()).ready, isTrue);
  });

  test('原生插件暂不可用返回unavailable而非中断启动', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => throw PlatformException(code: 'missing'),
    );
    expect((await desktop.getReminderStatus()).state, TrayState.unavailable);
    expect((await desktop.recoverTray()).ready, isFalse);
    messenger.setMockMethodCallHandler(channel, null);
    expect((await desktop.requestTestNotification()).accepted, isFalse);
  });
}
