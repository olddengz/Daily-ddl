import 'package:flutter/material.dart';

import '../db/database.dart';
import '../db/task_repository.dart';
import '../services/task_calendar.dart';
import 'calendar_summary_page.dart';
import 'time_label.dart';

class TaskCalendarPage extends StatefulWidget {
  const TaskCalendarPage({super.key, required this.db});
  final AppDatabase db;

  @override
  State<TaskCalendarPage> createState() => _TaskCalendarPageState();
}

class _TaskCalendarPageState extends State<TaskCalendarPage> {
  DateTime _selected = DateUtils.dateOnly(DateTime.now());
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _backToToday(DateTime today) {
    _selectMonth(today);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  late Future<Map<String, CalendarDay>> _days = _loadMonth(_selected);

  Future<Map<String, CalendarDay>> _read(DateTime start, DateTime end) async {
    return loadTaskRange(widget.db, start, end);
  }

  Future<Map<String, CalendarDay>> _loadMonth(DateTime date) => _read(
    DateTime(date.year, date.month),
    DateTime(date.year, date.month + 1),
  );

  void _selectMonth(DateTime date) {
    setState(() {
      _selected = date;
      _days = _loadMonth(date);
    });
  }

  Future<void> _chooseYear() async {
    final selected = _selected;
    final year = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择年份'),
        content: SizedBox(
          width: 280,
          height: 260,
          child: YearPicker(
            firstDate: DateTime(selected.year < 1900 ? selected.year : 1900),
            lastDate: DateTime(
              selected.year > 2200 ? selected.year : 2200,
              12,
              31,
            ),
            selectedDate: selected,
            onChanged: (date) => Navigator.pop(context, date.year),
          ),
        ),
      ),
    );
    if (year == null || !mounted) return;
    final lastDay = DateUtils.getDaysInMonth(year, selected.month);
    _selectMonth(
      DateTime(year, selected.month, selected.day.clamp(1, lastDay)),
    );
  }

  Future<void> _chooseMonth() async {
    final selected = _selected;
    final month = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('选择月份'),
        children: [
          for (var month = 1; month <= 12; month++)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, month),
              child: Text('$month月'),
            ),
        ],
      ),
    );
    if (month == null || !mounted) return;
    final lastDay = DateUtils.getDaysInMonth(selected.year, month);
    _selectMonth(
      DateTime(selected.year, month, selected.day.clamp(1, lastDay)),
    );
  }

  void _showSummary(String period) {
    final date = _selected;
    final (start, end) = switch (period) {
      '周' => (
        DateTime(date.year, date.month, date.day - date.weekday + 1),
        DateTime(date.year, date.month, date.day - date.weekday + 8),
      ),
      '月' => (
        DateTime(date.year, date.month),
        DateTime(date.year, date.month + 1),
      ),
      _ => (DateTime(date.year), DateTime(date.year + 1)),
    };
    final days = _read(start, end);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CalendarSummaryPage(
          title: '$period总结',
          start: start,
          end: end,
          days: days,
          db: widget.db,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    final first = DateTime(selected.year, selected.month);
    final count = DateUtils.getDaysInMonth(first.year, first.month);
    final offset = first.weekday - 1;
    final today = DateUtils.dateOnly(DateTime.now());
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('任务日历'),
        actions: [
          TextButton(
            onPressed: () => _backToToday(today),
            child: const Text('今天'),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _days,
        builder: (context, snapshot) {
          final ready =
              snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData;
          final days = ready ? snapshot.data! : const <String, CalendarDay>{};
          final detail =
              days[TaskRepository.localDateKey(selected)] ?? CalendarDay();
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                controller: _scroll,
                padding: const EdgeInsets.all(12),
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      for (final period in ['周', '月', '年'])
                        OutlinedButton(
                          onPressed: () => _showSummary(period),
                          child: Text('$period总结'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                tooltip: '上个月',
                                onPressed: () => _selectMonth(
                                  DateTime(first.year, first.month - 1),
                                ),
                                icon: const Icon(Icons.chevron_left),
                              ),
                              Flexible(
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: _chooseYear,
                                      child: Text('${first.year}年 ▾'),
                                    ),
                                    TextButton(
                                      onPressed: _chooseMonth,
                                      child: Text('${first.month}月 ▾'),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: '下个月',
                                onPressed: () => _selectMonth(
                                  DateTime(first.year, first.month + 1),
                                ),
                                icon: const Icon(Icons.chevron_right),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              for (final weekday in [
                                '一',
                                '二',
                                '三',
                                '四',
                                '五',
                                '六',
                                '日',
                              ])
                                Expanded(child: Center(child: Text(weekday))),
                            ],
                          ),
                          GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 7,
                                  mainAxisExtent: 50,
                                ),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: ((offset + count + 6) ~/ 7) * 7,
                            itemBuilder: (context, index) {
                              final n = index - offset + 1;
                              if (n < 1 || n > count) {
                                return const SizedBox.shrink();
                              }
                              final date = DateTime(first.year, first.month, n);
                              final data =
                                  days[TaskRepository.localDateKey(date)];
                              final chosen = DateUtils.isSameDay(
                                date,
                                selected,
                              );
                              final done = data?.completed.length ?? 0;
                              final due = data?.deadlines.length ?? 0;
                              final planned = data?.planDeadlines.length ?? 0;
                              final completedPlans = data?.completedPlans.length ?? 0;
                              return Semantics(
                                selected: chosen,
                                button: true,
                                child: Tooltip(
                                  message:
                                      '${TaskRepository.localDateKey(date)} · 完成 $done 项 · DDL $due 项'
                                      '${planned + completedPlans == 0 ? '' : ' · 计划 $planned 项到期，$completedPlans 项完成'}',
                                  child: InkWell(
                                    key: ValueKey(date),
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () =>
                                        setState(() => _selected = date),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        color: chosen
                                            ? colors.primaryContainer
                                            : null,
                                        borderRadius: BorderRadius.circular(8),
                                        border: date == today
                                            ? Border.all(color: colors.primary)
                                            : null,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text('$n'),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              if (done + completedPlans > 0)
                                                Icon(
                                                  Icons.check_circle,
                                                  size: 12,
                                                  color: colors.primary,
                                                ),
                                              if (due > 0)
                                                Icon(
                                                  Icons.schedule,
                                                  size: 12,
                                                  color: colors.tertiary,
                                                ),
                                              if (planned > 0)
                                                Icon(
                                                  Icons.event_note_outlined,
                                                  size: 12,
                                                  color: colors.secondary,
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          Wrap(
                            spacing: 16,
                            runSpacing: 4,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 14,
                                    color: colors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text('完成记录'),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 14,
                                    color: colors.tertiary,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text('DDL 截止'),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (snapshot.connectionState != ConnectionState.done)
                    const LinearProgressIndicator()
                  else if (snapshot.hasError)
                    TextButton(
                      onPressed: () => _selectMonth(selected),
                      child: const Text('读取失败，点击重试'),
                    )
                  else ...[
                    Text(
                      '${selected.month}月${selected.day}日',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '完成 ${detail.completed.length} 项 · 当日净得分 ${detail.points.toStringAsFixed(1)}',
                    ),
                    _section('每日任务 · 已记录', detail.daily),
                    _section('当天截止的 DDL', detail.deadlines),
                    _section('当天完成记录', detail.completed, showCompletion: true),
                    if (detail.planDeadlines.isNotEmpty)
                      _planSection('当天截止的计划', detail.planDeadlines),
                    if (detail.completedPlans.isNotEmpty)
                      _planSection('当天完成的计划', detail.completedPlans, done: true),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _section(
    String title,
    List<Task> tasks, {
    bool showCompletion = false,
  }) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          if (tasks.isEmpty)
            const Padding(padding: EdgeInsets.all(12), child: Text('暂无记录'))
          else
            for (final task in tasks)
              ListTile(
                title: Text(task.title),
                subtitle: Text(
                  showCompletion
                      ? '完成 ${formatLocalDateTime(task.completedAtUtc!)}'
                      : '截止 ${formatLocalDateTime(task.deadlineUtc)} · ${_status(task)}',
                ),
              ),
        ],
      ),
    ),
  );

  Widget _planSection(String title, List<Plan> plans, {bool done = false}) =>
      Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Card(
          child: Column(
            children: [
              ListTile(title: Text(title)),
              for (final plan in plans)
                ListTile(
                  title: Text(plan.title),
                  subtitle: Text(
                    done
                        ? '完成 ${formatLocalDateTime(plan.completedAtUtc!)}'
                        : '截止 ${formatLocalDateTime(plan.deadlineUtc!)}',
                  ),
                ),
            ],
          ),
        ),
      );

  String _status(Task task) {
    if (task.status == 'done') return '已完成';
    if (task.status == 'archived') return '逾期归档';
    if (task.status == 'overdue' || !task.deadlineUtc.isAfter(DateTime.now())) {
      return '已逾期';
    }
    return '待完成';
  }
}
