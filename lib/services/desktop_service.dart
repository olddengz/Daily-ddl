import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

/// Windows tray lives in the native runner. No background worker survives Exit.
enum TrayState { initializing, ready, recovering, unavailable }

class ReminderStatus {
  const ReminderStatus(this.state, {this.errorCode = 0});
  final TrayState state;
  final int errorCode;
  bool get ready => state == TrayState.ready;

  factory ReminderStatus.fromMap(Map<Object?, Object?>? value) {
    final state = TrayState.values.firstWhere(
      (state) => state.name == value?['state'],
      orElse: () => TrayState.unavailable,
    );
    return ReminderStatus(state, errorCode: value?['errorCode'] as int? ?? 0);
  }
}

class DesktopFailure implements Exception {
  const DesktopFailure(this.code, this.message);
  final String code;
  final String message;
  @override
  String toString() => message;
}

class NotificationRequestResult {
  const NotificationRequestResult(this.accepted, this.message, {this.code});
  final bool accepted;
  final String message;
  final String? code;
}

class DesktopService {
  DesktopService();
  static final instance = DesktopService();
  static const _channel = MethodChannel('daily_ddl/desktop');
  final status = ValueNotifier(const ReminderStatus(TrayState.initializing));
  bool get ready => status.value.ready;
  bool windowReady = false;
  bool get supported => Platform.isWindows;
  bool compact = false;
  Future<void> Function(String?)? onOpenTask;
  Future<void> initialize() async {
    if (!Platform.isWindows) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'openTask') {
        await onOpenTask?.call(call.arguments as String?);
      } else if (call.method == 'trayStateChanged') {
        status.value = ReminderStatus.fromMap(
          (call.arguments as Map).cast<Object?, Object?>(),
        );
      }
    });
    // Tray failure must not prevent the task UI from starting.
    try {
      await windowManager.ensureInitialized();
      await windowManager.setMinimumSize(const Size(360, 440));
      await windowManager.setTitle('Daily DDL 1.2');
      windowReady = true;
    } on PlatformException {
      windowReady = false;
    } on MissingPluginException {
      windowReady = false;
    }
    await getReminderStatus();
  }

  Future<ReminderStatus> getReminderStatus() async {
    try {
      status.value = ReminderStatus.fromMap(
        await _channel.invokeMapMethod<Object?, Object?>('getReminderStatus'),
      );
    } on PlatformException {
      status.value = const ReminderStatus(TrayState.unavailable);
    } on MissingPluginException {
      status.value = const ReminderStatus(TrayState.unavailable);
    }
    return status.value;
  }

  Future<ReminderStatus> recoverTray() async {
    try {
      status.value = ReminderStatus.fromMap(
        await _channel.invokeMapMethod<Object?, Object?>('recoverTray'),
      );
    } on PlatformException {
      status.value = const ReminderStatus(TrayState.unavailable);
    } on MissingPluginException {
      status.value = const ReminderStatus(TrayState.unavailable);
    }
    return status.value;
  }

  Future<NotificationRequestResult> requestTestNotification() async {
    try {
      await notify('每日 DDL', '这是一条测试提醒。');
      return const NotificationRequestResult(true, '已请求系统通知，请检查通知区及免打扰设置');
    } on DesktopFailure catch (error) {
      return NotificationRequestResult(false, error.message, code: error.code);
    }
  }

  Future<void> toggleCompact() async {
    compact = !compact;
    await windowManager.setSize(
      compact ? const Size(400, 620) : const Size(900, 760),
    );
  }

  Future<void> togglePin() async =>
      windowManager.setAlwaysOnTop(!await windowManager.isAlwaysOnTop());
  Future<bool> startupEnabled() async =>
      await _channel.invokeMethod<bool>('getStartup') ?? false;
  Future<void> setStartup(bool value) =>
      _channel.invokeMethod<void>('setStartup', value);
  Future<void> notify(String title, String body, {String? taskId}) async {
    try {
      // Recovery and the single retry live in the native sender, not in callers.
      await _channel.invokeMethod<void>('notify', {
        'title': title,
        'body': body,
        'taskId': taskId,
      });
    } on PlatformException {
      await getReminderStatus();
      throw const DesktopFailure(
        'notification_unavailable',
        '系统通知暂不可用，请在菜单中重试恢复通知',
      );
    } on MissingPluginException {
      throw const DesktopFailure('notification_unavailable', '当前环境不支持系统通知');
    }
  }

  Future<void> exit() => _channel.invokeMethod<void>('exit');
}
