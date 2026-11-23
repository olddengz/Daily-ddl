import 'dart:async';

import 'ai_settings_page.dart';

import 'package:flutter/material.dart';

import '../db/database.dart';
import '../db/task_repository.dart';
import '../engine/daily_settlement.dart';
import '../engine/score_engine.dart';
import '../services/desktop_service.dart';
import '../services/task_service.dart';
import '../services/plan_service.dart';
import 'task_history_page.dart';
import 'task_calendar_page.dart';
import '../services/reminder_service.dart';
import 'task_edit_page.dart';
import 'plan_extension_dialog.dart';
import 'task_grouping.dart';
import 'time_label.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.db, this.now});
  final AppDatabase db;
  final DateTime Function()? now;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TaskService _tasksService;
  late final ReminderService _reminders;
  final _desktop = DesktopService.instance;
  List<Task> _tasks = [];
  late final _planService = PlanService(widget.db);
  List<Plan> _plans = [];
  final Map<int, Plan> _leavingPlans = {};
  double _earned = 0;
  double _creditBalance = 0;
  double? _creditBeforeRollover;
  ({int base, int bonus}) _todayCredits = (base: 0, bonus: 0);
  bool _loading = true, _refreshing = false, _again = false;
  String? _error, _reminderError;
  final Set<String> _busyIds = {};
  final Map<String, Task> _leaving = {};
  final Set<String> _shrinking = {};
  Timer? _timer, _midnightTimer;
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
    _scheduleMidnight();
    _lifecycle = AppLifecycleListener(
      onResume: () {
        _scheduleMidnight();
        _reload();
      },
    );
  }

  DateTime _now() => (widget.now?.call() ?? DateTime.now()).toUtc();

  void _scheduleMidnight() {
    _midnightTimer?.cancel();
    final now = _now().toLocal();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    _midnightTimer = Timer(midnight.difference(now), () {
      _scheduleMidnight();
      _reload();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _midnightTimer?.cancel();
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
        final now = _now();
        final settlement = await DailySettlement(widget.db).run(now);
        final tasks = await _tasksService.allTasks();
        final plans = await _planService.all();
        final earned = await _tasksService.earnedToday(now);
        final todayCredits = await _tasksService.dailyCredits(now);
        final creditBalance = await _tasksService.creditBalance(now);
        if (!mounted) return;
        setState(() {
          _tasks = tasks;
          _plans = plans;
          _earned = earned;
          _todayCredits = todayCredits;
          if (_loading || _creditBalance != creditBalance) {
            final previous = settlement.balanceBeforeRollover;
            _creditBeforeRollover = previous != null && previous < creditBalance
                ? previous
                : null;
            _creditBalance = creditBalance;
          }
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
        if (!await _tasksService.undo(t, _now())) {
          _message('撤销失败：任务状态或流水已变化');
        }
      } else {
        final r = await _tasksService.complete(t, _now());
        if (!r.ok) {
          _message(r.reason == 'overdue' ? '任务已逾期，请先延期' : '任务状态已变化，请刷新后重试');
        } else {
          if (!mounted) return;
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
          await _animateCompletion(t.id, () => _leaving.containsKey(t.id));
          if (!mounted || !_leaving.containsKey(t.id)) return;
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
        final ok = await _tasksService.undo(current, _now());
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

  Future<void> _animateCompletion(String id, bool Function() isLeaving) async {
    if (!mounted) return;
    final reduced = MediaQuery.of(context).disableAnimations;
    if (!reduced) await Future<void>.delayed(const Duration(milliseconds: 550));
    if (!mounted || !isLeaving()) return;
    setState(() => _shrinking.add(id));
    if (!reduced) await Future<void>.delayed(const Duration(milliseconds: 230));
  }

  Future<void> _togglePlan(Plan plan) async {
    final key = 'plan:${plan.id}';
    if (_busyIds.contains(key)) return;
    setState(() => _busyIds.add(key));
    try {
      if (plan.completedAtUtc != null) {
        await _undoPlan(plan.id);
        return;
      }
      final now = _now();
      final result = await _planService.complete(plan, now);
      if (!mounted) return;
      if (result != PlanResult.ok) {
        _message(result == PlanResult.expired ? '计划已逾期，请先延期' : '计划已变化，请刷新后重试');
        await _reload();
        return;
      }
      final reward = PlanService.completionReward(plan, now);
      setState(() => _leavingPlans[plan.id] = plan);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text('计划已完成 · 累计积分 +$reward'),
            duration: const Duration(seconds: 3),
            persist: false,
            action: SnackBarAction(
              label: '撤销',
              onPressed: () => _undoPlan(plan.id),
            ),
          ),
        );
      await _reload();
      await _animateCompletion(key, () => _leavingPlans.containsKey(plan.id));
    } catch (_) {
      _message('操作失败，请重试');
    } finally {
      if (mounted) {
        setState(() {
          _leavingPlans.remove(plan.id);
          _shrinking.remove(key);
          _busyIds.remove(key);
        });
      }
    }
  }

  Future<void> _undoPlan(int id) async {
    final key = 'plan:$id';
    if (!_undoing.add(key)) return;
    try {
      final current = await _planService.byId(id);
      if (!mounted) return;
      if (current == null ||
          await _planService.undo(current, _now()) != PlanResult.ok) {
        _message('撤销失败：计划已变化');
      } else if (mounted) {
        setState(() {
          _leavingPlans.remove(id);
          _shrinking.remove(key);
        });
      }
      if (mounted) await _reload();
    } catch (_) {
      _message('撤销失败，请重试');
    } finally {
      _undoing.remove(key);
    }
  }

  Future<void> _editPlan(Plan plan) async {
    await Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => TaskEditPage(db: widget.db, plan: plan),
      ),
    );
    if (mounted) await _reload();
  }

  Future<void> _extendPlan(Plan plan) async {
    final key = 'plan:${plan.id}';
    if (_busyIds.contains(key)) return;
    setState(() => _busyIds.add(key));
    try {
      final days = await choosePlanExtension(context, _creditBalance);
      if (!mounted || days == null) return;
      final result = await _planService.extend(plan, days, _now());
      _message(switch (result) {
        PlanResult.ok => '计划已延期',
        PlanResult.insufficient => '累计积分不足',
        _ => '计划已变化，请刷新后重试',
      });
      if (mounted) await _reload();
    } catch (_) {
      _message('延期失败，请重试');
    } finally {
      if (mounted) setState(() => _busyIds.remove(key));
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

  Future<void> _archive(Task task) async {
    if (_busyIds.contains(task.id)) return;
    final cost = TaskRepository.archiveCost(task, _now());
    if (cost == null) return;
    setState(() => _busyIds.add(task.id));
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('归档逾期 DDL？'),
          content: Text(
            '「${task.title}」归档需要扣除 $cost 积分。'
            '累计积分可以扣为负数。原截止时间会保留在日历中。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text('扣 $cost 积分并归档'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      final result = await _tasksService.archiveOverdue(
        task,
        quotedCost: cost,
        now: _now(),
      );
      if (!mounted) return;
      await _reload();
      _message(switch (result) {
        ArchiveResult.archived => '已归档 · 扣除 $cost 积分',
        ArchiveResult.priceChanged => '逾期已进入下一档，请重新确认费用',
        ArchiveResult.unavailable => '任务状态已变化，请刷新后重试',
      });
    } catch (_) {
      _message('归档失败，请重试');
    } finally {
      if (mounted) setState(() => _busyIds.remove(task.id));
    }
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
    final now = _now();
    final localNow = now.toLocal();
    final narrow =
        MediaQuery.sizeOf(context).width <
        600 * MediaQuery.textScalerOf(context).scale(1);
    final colors = Theme.of(context).colorScheme;
    final displayed = [for (final t in _tasks) _leaving[t.id] ?? t];
    final g = TaskGrouping.group(displayed, now);
    final today = TaskRepository.localDateKey(now.toLocal());
    final todayDone = g.done.where((task) {
      final completed = task.completedAtUtc;
      return completed != null &&
          TaskRepository.localDateKey(completed.toLocal()) == today &&
          !_leaving.containsKey(task.id);
    }).toList()..sort((a, b) => b.completedAtUtc!.compareTo(a.completedAtUtc!));
    final openPlans = [
      for (final plan in _plans)
        if (plan.completedAtUtc == null || _leavingPlans.containsKey(plan.id))
          _leavingPlans[plan.id] ?? plan,
    ];
    final completedRows = <(DateTime, Widget)>[
      for (final t in todayDone) (t.completedAtUtc!, _tile(t, 0, now)),
      for (final plan in _plans)
        if (plan.completedAtUtc case final completed?
            when TaskRepository.localDateKey(completed.toLocal()) == today &&
                !_leavingPlans.containsKey(plan.id))
          (completed, _planTile(plan, now)),
    ]..sort((a, b) => b.$1.compareTo(a.$1));
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
              t.status != 'done' &&
              t.status != 'archived',
        )
        .toList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: narrow ? 8 : 16,
        title: TweenAnimationBuilder<double>(
          key: ValueKey(_creditBalance),
          tween: Tween<double>(
            begin: _creditBeforeRollover ?? _creditBalance,
            end: _creditBalance,
          ),
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 850),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) {
            final begin = _creditBeforeRollover ?? _creditBalance;
            final digits =
                begin == begin.truncateToDouble() &&
                    _creditBalance == _creditBalance.truncateToDouble()
                ? 0
                : 1;
            return FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                '累计积分 ${value.toStringAsFixed(digits)}',
                style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
              ),
            );
          },
        ),
        toolbarHeight: 48,
        shape: Border(bottom: BorderSide(color: colors.outlineVariant)),
        actions: [
          IconButton(
            tooltip: 'AI 设置',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => AiSettingsPage(db: widget.db),
              ),
            ),
          ),
          IconButton(
            tooltip: '任务日历',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => TaskCalendarPage(db: widget.db),
              ),
            ),
            icon: const Icon(Icons.calendar_month_outlined),
          ),
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
                    padding: EdgeInsets.fromLTRB(
                      narrow ? 24 : 28,
                      24,
                      narrow ? 24 : 28,
                      32,
                    ),
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '今日任务',
                                  style: TextStyle(
                                    fontSize: narrow ? 24 : 28,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${localNow.month} 月 ${localNow.day} 日 · 星期${const ['一', '二', '三', '四', '五', '六', '日'][localNow.weekday - 1]}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!narrow) ...[
                            FilledButton.icon(
                              onPressed: () => _edit(),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('添加任务'),
                            ),
                          ],
                        ],
                      ),
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
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          children: [
                            Text(
                              '今日得分',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 180,
                                ),
                                child: LinearProgressIndicator(
                                  value: (_earned / 100).clamp(0, 1),
                                  minHeight: 4,
                                  backgroundColor: colors.outlineVariant,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${_earned.toStringAsFixed(1)} / 100',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '今日积分 ${_todayCredits.base + _todayCredits.bonus}'
                        '${_todayCredits.bonus > 0 ? '（含全完成奖励 +3）' : ''}',
                      ),
                      const Divider(),
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
                      _planSection(openPlans, now),
                      if (completedRows.isNotEmpty)
                        ExpansionTile(
                          title: Text('今日已完成 · ${completedRows.length}'),
                          children: [for (final (_, row) in completedRows) row],
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
      bottomNavigationBar: narrow
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: colors.outlineVariant)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => _edit(),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('添加任务'),
                    ),
                  ],
                ),
              ),
            )
          : null,
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
        padding: const EdgeInsets.fromLTRB(0, 24, 0, 10),
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
        _collapseRow(t.id, _tile(t, scores[t.id] ?? 0, now)),
    ],
  );

  Widget _collapseRow(String id, Widget row) => TweenAnimationBuilder<double>(
    key: ValueKey(id),
    tween: Tween(begin: 1.0, end: _shrinking.contains(id) ? 0.0 : 1.0),
    duration: MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 220),
    child: row,
    builder: (context, value, child) => ClipRect(
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: value,
        child: Opacity(opacity: value, child: child),
      ),
    ),
  );

  Widget _planSection(List<Plan> plans, DateTime now) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text(
          '计划 · ${plans.length}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      for (final plan in plans)
        _collapseRow('plan:${plan.id}', _planTile(plan, now)),
    ],
  );

  Widget _planTile(Plan plan, DateTime now) {
    final done =
        plan.completedAtUtc != null || _leavingPlans.containsKey(plan.id);
    final overdue = !done && PlanService.isOverdue(plan, now);
    final busy = _busyIds.contains('plan:${plan.id}');
    final deadline = plan.deadlineUtc;
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: done ? const Color(0xfff6f7fb) : Colors.white,
      shape: Border(bottom: BorderSide(color: colors.outlineVariant)),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: IconButton(
          tooltip: done ? '撤销计划完成' : '完成计划',
          onPressed: busy || overdue ? null : () => _togglePlan(plan),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Icon(
              done ? Icons.check_circle : Icons.radio_button_unchecked,
              key: ValueKey(done),
              color: done ? colors.onSurfaceVariant : colors.primary,
            ),
          ),
        ),
        title: Text(
          plan.title,
          style: TextStyle(
            decoration: done ? TextDecoration.lineThrough : null,
            color: done ? colors.onSurfaceVariant : null,
          ),
        ),
        onTap: done || busy ? null : () => _editPlan(plan),
        subtitle: Text(
          deadline == null
              ? '无截止时间'
              : overdue
              ? '已逾期 · ${formatLocalDateTime(deadline)}'
              : done
              ? '截止 ${formatLocalDateTime(deadline)}'
              : timeRemaining(deadline, now),
        ),
        trailing: done
            ? null
            : overdue
            ? TextButton(
                onPressed: busy ? null : () => _extendPlan(plan),
                child: const Text('延期'),
              )
            : IconButton(
                tooltip: '编辑计划',
                onPressed: busy ? null : () => _editPlan(plan),
                icon: const Icon(Icons.more_horiz, size: 20),
              ),
      ),
    );
  }

  Widget _tile(Task t, double score, DateTime now) {
    final done = t.status == 'done' || _leaving.containsKey(t.id);
    final overdue = !done && !now.isBefore(t.deadlineUtc);
    final soon =
        !done &&
        !overdue &&
        t.deadlineUtc.difference(now) <= const Duration(hours: 3);
    final colors = Theme.of(context).colorScheme;
    final deadline = formatLocalDateTime(t.deadlineUtc);
    final today = TaskRepository.localDateKey(now.toLocal());
    final deadlineLabel = deadline.startsWith(today)
        ? '今天 ${deadline.substring(11)}'
        : deadline.substring(5);
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
      deadlineLabel,
      if (!done) timeRemaining(t.deadlineUtc, now),
      if (t.repeatRule != null) '重复',
    ].join(' · ');
    return DecoratedBox(
      decoration: BoxDecoration(
        color: done ? const Color(0xfff6f7fb) : Colors.white,
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
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
                    color: done ? colors.onSurfaceVariant : colors.primary,
                  ),
                ),
              ),
            ),
            Tooltip(
              message: '优先级：$priorityLabel',
              child: Container(
                width: 5,
                height: 5,
                margin: const EdgeInsets.only(right: 10),
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
                        fontWeight: FontWeight.w500,
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
                                : soon
                                ? const Color(0xffa65d25)
                                : colors.onSurfaceVariant,
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
                  style: TextStyle(fontSize: 12, color: colors.primary),
                ),
              ),
            if (TaskRepository.archiveCost(t, now) != null)
              TextButton(
                onPressed: _busyIds.contains(t.id) ? null : () => _archive(t),
                child: const Text('归档'),
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
