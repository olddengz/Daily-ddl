import 'dart:async';

import 'package:flutter/material.dart';

import '../db/database.dart';
import '../db/task_repository.dart';
import '../engine/daily_settlement.dart';
import '../engine/score_engine.dart';
import '../services/desktop_service.dart';
import '../services/task_service.dart';
import 'task_history_page.dart';
import '../services/reminder_service.dart';
import 'task_edit_page.dart';
import 'task_grouping.dart';
import 'time_label.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.db});
  final AppDatabase db;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TaskService _tasksService;
  late final ReminderService _reminders;
  final _desktop = DesktopService.instance;
  List<Task> _tasks = [];
  double _earned = 0;
  bool _loading = true, _refreshing = false, _again = false;
  String? _error, _reminderError;
  final Set<String> _busyIds = {};
  final Map<String, Task> _leaving = {};
  final Set<String> _shrinking = {};
  Timer? _timer;
  AppLifecycleListener? _lifecycle;
  bool _hadTrayFailure = false;
  @override
  void initState() {
    super.initState();
    _tasksService = TaskService(widget.db);
    _desktop.status.addListener(_desktopStatusChanged);
    _reminders = ReminderService(
      widget.db,
      (title, body, id) => _desktop.notify(title, body, taskId: id),
    );
    _desktop.onOpenTask = (id) async {
      if (!mounted) return;
      if (id != null) {
        final task = await _tasksService.taskById(id);
        if (mounted && task != null) _edit(task);
      } else {
        await _reload();
      }
    };
    _reload();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _reload());
    _lifecycle = AppLifecycleListener(onResume: () => _reload());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _lifecycle?.dispose();
    _desktop.onOpenTask = null;
    _desktop.status.removeListener(_desktopStatusChanged);
    super.dispose();
  }

  void _desktopStatusChanged() {
    if (!mounted) return;
    final state = _desktop.status.value.state;
    if (state == TrayState.unavailable) _hadTrayFailure = true;
    final recovered = state == TrayState.ready && _hadTrayFailure;
    setState(() {
      if (state == TrayState.ready) _reminderError = null;
    });
    if (recovered) {
      _hadTrayFailure = false;
      unawaited(_reload());
    }
  }

  Future<void> _reload() async {
    if (_refreshing) {
      _again = true;
      return;
    }
    _refreshing = true;
    try {
      do {
        _again = false;
        final now = DateTime.now().toUtc();
        await DailySettlement(widget.db).run(now);
        final tasks = await _tasksService.allTasks();
        final earned = await _tasksService.earnedToday(now.toLocal());
        if (!mounted) return;
        setState(() {
          _tasks = tasks;
          _earned = earned;
          _loading = false;
          _error = null;
        });
        if (_desktop.windowReady || _desktop.ready) {
          try {
            await _reminders.check(tasks, now);
            if (mounted && _reminderError != null) {
              setState(() => _reminderError = null);
            }
          } catch (_) {
            if (mounted) {
              setState(() => _reminderError = '系统提醒暂未发出，请重试恢复通知');
            }
          }
        }
      } while (_again && mounted);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = '刷新失败：$e';
        });
      }
    } finally {
      _refreshing = false;
    }
  }

  void _message(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _toggle(Task t) async {
    if (_busyIds.contains(t.id)) return;
    setState(() => _busyIds.add(t.id));
    try {
      if (t.status == 'done') {
        if (!await _tasksService.undo(t, DateTime.now().toUtc())) {
          _message('撤销失败：任务状态或流水已变化');
        }
      } else {
        final r = await _tasksService.complete(t, DateTime.now().toUtc());
        if (!r.ok) {
          _message(r.reason == 'overdue' ? '任务已逾期，请先延期' : '任务状态已变化，请刷新后重试');
        } else {
          if (!mounted) return;
          final reduced = MediaQuery.of(context).disableAnimations;
          setState(() => _leaving[t.id] = t);
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  '已完成 · 获得 ${(r.score ?? 0).toStringAsFixed(1)} 分',
                ),
                duration: const Duration(seconds: 3),
                persist: false,
                action: SnackBarAction(
                  label: '撤销',
                  onPressed: () async {
                    await _undoRecent(t.id);
                  },
                ),
              ),
            );
          await _reload();
          if (!reduced) {
            await Future<void>.delayed(const Duration(milliseconds: 550));
          }
          if (!mounted || !_leaving.containsKey(t.id)) return;
          setState(() => _shrinking.add(t.id));
          if (!reduced) {
            await Future<void>.delayed(const Duration(milliseconds: 230));
          }
          if (!mounted) return;
          setState(() {
            _leaving.remove(t.id);
            _shrinking.remove(t.id);
          });
        }
      }
      await _reload();
    } catch (e) {
      _message('操作失败，请重试');
    } finally {
      if (mounted) {
        setState(() {
          _busyIds.remove(t.id);
          _leaving.remove(t.id);
          _shrinking.remove(t.id);
        });
      }
    }
  }

  final Set<String> _undoing = {};
  Future<void> _undoRecent(String id) async {
    if (_undoing.contains(id)) return;
    _undoing.add(id);
    try {
      final current = await _tasksService.taskById(id);
      if (!mounted || current == null) return;
      if (_leaving.containsKey(id)) {
        final ok = await _tasksService.undo(current, DateTime.now().toUtc());
        if (!mounted) return;
        if (ok) {
          setState(() {
            _leaving.remove(id);
            _shrinking.remove(id);
          });
        } else {
          _message('任务状态已变化，请刷新');
        }
        await _reload();
      } else {
        await _toggle(current);
      }
    } catch (e) {
      _message('撤销失败，请重试');
    } finally {
      _undoing.remove(id);
    }
  }

  Future<void> _edit([Task? t]) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TaskEditPage(db: widget.db, task: t),
      ),
    );
    if (mounted) await _reload();
  }

  Future<void> _desktopAction(String value) async {
    try {
      switch (value) {
        case 'compact':
          await _desktop.toggleCompact();
        case 'pin':
          await _desktop.togglePin();
        case 'test':
          final result = await _desktop.requestTestNotification();
          _message(result.message);
        case 'recover':
          final status = await _desktop.recoverTray();
          _message(status.ready ? '系统通知已恢复，可以重新测试' : '系统通知暂不可用，窗口将保持可访问');
        case 'startup':
          final enabled = await _desktop.startupEnabled();
          await _desktop.setStartup(!enabled);
          _message(enabled ? '已关闭开机启动' : '已开启开机启动');
        case 'exit':
          await _desktop.exit();
      }
    } catch (_) {
      _message('桌面操作未成功，请稍后重试');
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().toUtc();
    final displayed = [for (final t in _tasks) _leaving[t.id] ?? t];
    final g = TaskGrouping.group(displayed, now);
    final today = TaskRepository.localDateKey(now.toLocal());
    final todayDone = g.done
        .where(
          (t) =>
              t.taskKind == 'daily' &&
              t.scheduledDate == today &&
              !_leaving.containsKey(t.id),
        )
        .toList();
    final scores = distributeScores(
      [
        for (final t in TaskGrouping.group(_tasks, now).active)
          ScoreTask(
            id: t.id,
            deadlineUtc: t.deadlineUtc,
            priority: t.priority,
            weightOverride: t.weightOverride,
            taskKind: t.taskKind,
          ),
      ],
      _earned,
      nowUtc: now,
    ).scores;
    final daily = g.active.where((t) => t.taskKind == 'daily').toList();
    final ddl = g.active.where((t) => t.taskKind != 'daily').toList();
    daily.sort((a, b) => (scores[b.id] ?? 0).compareTo(scores[a.id] ?? 0));
    ddl.sort((a, b) => a.deadlineUtc.compareTo(b.deadlineUtc));
    final legacy = _tasks
        .where(
          (t) =>
              t.taskKind == 'legacy' &&
              t.status != 'cancelled' &&
              t.status != 'done',
        )
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('今日任务'),
        actions: [
          IconButton(
            tooltip: '完成记录',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => TaskHistoryPage(db: widget.db),
                ),
              );
              if (mounted) await _reload();
            },
            icon: const Icon(Icons.history),
          ),
          IconButton(
            tooltip: '刷新',
            onPressed: () => _reload(),
            icon: const Icon(Icons.refresh),
          ),
          PopupMenuButton<String>(
            tooltip: '桌面与提醒',
            onSelected: _desktopAction,
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'compact',
                enabled: _desktop.windowReady,
                child: Text(_desktop.compact ? '恢复完整窗口' : '桌面精简窗口'),
              ),
              PopupMenuItem(
                value: 'pin',
                enabled: _desktop.windowReady,
                child: const Text('切换窗口置顶'),
              ),
              PopupMenuItem(
                value: 'test',
                enabled: _desktop.supported,
                child: const Text('测试系统提醒'),
              ),
              PopupMenuItem(
                value: 'recover',
                enabled: _desktop.supported,
                child: const Text('重试恢复通知'),
              ),
              PopupMenuItem(
                value: 'startup',
                enabled: _desktop.supported,
                child: const Text('切换开机启动'),
              ),
              PopupMenuItem(
                value: 'exit',
                enabled: _desktop.supported,
                child: const Text('退出应用'),
              ),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    children: [
                      if (_error != null)
                        ListTile(
                          title: Text(_error!),
                          trailing: TextButton(
                            onPressed: _reload,
                            child: const Text('重试'),
                          ),
                        ),
                      if (_reminderError != null ||
                          _desktop.status.value.state == TrayState.unavailable)
                        ListTile(
                          title: Text(_reminderError ?? '系统通知暂不可用，关闭窗口将保持可访问'),
                          trailing: TextButton(
                            onPressed: () => _desktopAction('recover'),
                            child: const Text('重试恢复'),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '今日积分',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                ),
                                Text('${_earned.toStringAsFixed(1)} / 100'),
                              ],
                            ),
                            const SizedBox(height: 10),
                            LinearProgressIndicator(
                              value: (_earned / 100).clamp(0, 1),
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ],
                        ),
                      ),
                      if (legacy.isNotEmpty)
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.info_outline),
                            title: Text('${legacy.length} 项旧任务待确认类别'),
                            subtitle: const Text('历史积分不变；点此逐项确认每日或 DDL'),
                            onTap: () => _classify(legacy),
                          ),
                        ),
                      _section('每日任务', daily, scores, now, empty: '暂无待完成的每日任务'),
                      _section('DDL 任务', ddl, scores, now, empty: '暂无待完成的 DDL'),
                      if (todayDone.isNotEmpty)
                        ExpansionTile(
                          title: Text('今日已完成 · ${todayDone.length}'),
                          children: [
                            for (final t in todayDone) _tile(t, 0, now),
                          ],
                        ),
                      if (g.overdue.isNotEmpty)
                        ExpansionTile(
                          title: Text(
                            '逾期 · ${g.overdue.length}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          children: [
                            for (final t in g.overdue) _tile(t, 0, now),
                          ],
                        ),
                      if (_desktop.ready && !_desktop.compact)
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            '关闭窗口后保留托盘运行 · 完全退出后停止提醒',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(),
        icon: const Icon(Icons.add),
        label: const Text('添加任务'),
      ),
    );
  }

  Future<void> _classify(List<Task> tasks) async {
    final chosen = await showDialog<Task>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('选择旧任务并确认类别'),
        children: [
          for (final t in tasks)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, t),
              child: Text(t.title),
            ),
        ],
      ),
    );
    if (chosen != null && mounted) await _edit(chosen);
  }

  Widget _section(
    String title,
    List<Task> tasks,
    Map<String, double> scores,
    DateTime now, {
    required String empty,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
        child: Text(
          '$title · ${tasks.length}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      if (tasks.isEmpty)
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(empty, style: const TextStyle(color: Colors.grey)),
        ),
      for (final t in tasks)
        TweenAnimationBuilder<double>(
          key: ValueKey(t.id),
          tween: Tween(begin: 1.0, end: _shrinking.contains(t.id) ? 0.0 : 1.0),
          duration: MediaQuery.of(context).disableAnimations
              ? Duration.zero
              : const Duration(milliseconds: 220),
          child: _tile(t, scores[t.id] ?? 0, now),
          builder: (context, value, child) => ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: value,
              child: Opacity(opacity: value, child: child),
            ),
          ),
        ),
    ],
  );
  Widget _tile(Task t, double score, DateTime now) {
    final done = t.status == 'done' || _leaving.containsKey(t.id);
    final overdue = !done && !now.isBefore(t.deadlineUtc);
    final priorityColor = switch (t.priority) {
      'high' => Colors.orange.shade800,
      'low' => Colors.grey,
      _ => Colors.indigo.shade400,
    };
    final priorityLabel = switch (t.priority) {
      'high' => '高',
      'low' => '低',
      _ => '中',
    };
    final subtitle = [
      if (t.taskKind == 'legacy') '待分类',
      if (t.course.isNotEmpty) t.course,
      if (!done) timeRemaining(t.deadlineUtc, now),
      if (t.repeatRule != null) '重复',
    ].join(' · ');
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 6),
      color: done ? const Color(0xffeff0f4) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Tooltip(
              message: done
                  ? '撤销完成'
                  : overdue
                  ? '已逾期，请编辑延期'
                  : '标记完成',
              child: IconButton(
                onPressed: _busyIds.contains(t.id) || overdue
                    ? null
                    : () => _toggle(t),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    done ? Icons.check_circle : Icons.radio_button_unchecked,
                    key: ValueKey(done),
                    color: done ? Colors.grey : null,
                  ),
                ),
              ),
            ),
            Tooltip(
              message: '优先级：$priorityLabel',
              child: Container(
                width: 3,
                height: 30,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: _busyIds.contains(t.id) ? null : () => _edit(t),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.title,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        decoration: done ? TextDecoration.lineThrough : null,
                        color: done ? Colors.grey : null,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Tooltip(
                        message: '截止时间：${formatLocalDateTime(t.deadlineUtc)}',
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.6,
                            color: overdue
                                ? Colors.red.shade700
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (!done)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  '${score.toStringAsFixed(1)}分',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            IconButton(
              tooltip: '编辑与更多',
              onPressed: _busyIds.contains(t.id) ? null : () => _edit(t),
              icon: const Icon(Icons.more_horiz, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
