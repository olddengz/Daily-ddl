import 'package:flutter/material.dart';

import '../db/database.dart';
import '../services/task_service.dart';
import '../services/plan_service.dart';
import '../db/task_repository.dart';
import 'time_label.dart';

class TaskHistoryPage extends StatefulWidget {
  const TaskHistoryPage({super.key, required this.db});
  final AppDatabase db;
  @override
  State<TaskHistoryPage> createState() => _TaskHistoryPageState();
}

class _TaskHistoryPageState extends State<TaskHistoryPage> {
  late final TaskService _service;
  late final PlanService _plans;
  List<CompletionRecord> _rows = [];
  DateTimeRange? _range;
  String? _kind, _error;
  bool _loading = false, _more = true;
  final Set<String> _busy = {};
  int _generation = 0;
  @override
  void initState() {
    super.initState();
    _service = TaskService(widget.db);
    _plans = PlanService(widget.db);
    _load(reset: true);
  }

  Future<void> _load({bool reset = false}) async {
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
      if (reset) {
        _rows = [];
        _more = true;
      }
    });
    try {
      final range = _range;
      final end = range?.end;
      final rows = await _service.completionHistory(
        kind: _kind,
        from: range?.start,
        until: end == null ? null : DateTime(end.year, end.month, end.day + 1),
        offset: reset ? 0 : _rows.length,
        limit: 31,
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        _rows = [..._rows, ...rows.take(30)];
        _more = rows.length > 30;
      });
    } catch (e) {
      if (mounted && generation == _generation) {
        setState(() => _error = '读取记录失败，请重试');
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _pickRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2200),
      initialDateRange: _range,
      helpText: '按完成日期筛选',
      builder: (context, child) => DatePickerTheme(
        data: DatePickerTheme.of(context).copyWith(
          headerHeadlineStyle: const TextStyle(fontSize: 20),
          rangePickerHeaderHeadlineStyle: const TextStyle(fontSize: 17),
        ),
        child: child!,
      ),
    );
    if (!mounted || range == null) return;
    _range = range;
    await _load(reset: true);
  }

  Future<void> _undo(CompletionRecord row) async {
    if (!_busy.add(row.key)) return;
    setState(() {});
    try {
      final now = DateTime.now().toUtc();
      final plan = row.plan;
      final ok = plan == null
          ? await _service.undo(row.task!, now)
          : await _plans.undo(plan, now) == PlanResult.ok;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? (plan == null ? '已撤销完成，任务按原日期与截止时间恢复' : '已撤销计划，完成积分已扣回')
                : '任务状态已变化，请刷新',
          ),
        ),
      );
      await _load(reset: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('撤销失败，请重试')));
      }
    } finally {
      if (mounted) setState(() => _busy.remove(row.key));
    }
  }

  String _dateLabel() {
    final range = _range;
    if (range == null) return '按日期筛选';
    final start = TaskRepository.localDateKey(range.start);
    final end = TaskRepository.localDateKey(range.end);
    return start == end ? start : '$start 至 $end';
  }

  void _details(CompletionRecord row) => showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(row.title),
      content: SingleChildScrollView(
        child: Text(
          [
            '类别：${row.label}',
            '完成时间：${row.completedAt == null ? '未记录' : formatLocalDateTime(row.completedAt!)}',
            '截止时间：${row.deadline == null ? '未设置' : formatLocalDateTime(row.deadline!)}',
            if (row.task?.scheduledDate case final date?) '所属日期：$date',
            if (row.task case final task?) ...[
              if (task.course.isNotEmpty) '课程：${task.course}',
              if (task.note.isNotEmpty) '备注：${task.note}',
            ],
          ].join('\n'),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('关闭'),
        ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('完成记录')),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            children: [
              for (final entry in <String?, String>{
                null: '全部',
                'daily': '每日',
                'ddl': 'DDL',
                'plan': '计划',
              }.entries)
                ChoiceChip(
                  label: Text(entry.value),
                  selected: _kind == entry.key,
                  onSelected: (_) {
                    _kind = entry.key;
                    _load(reset: true);
                  },
                ),
              OutlinedButton.icon(
                onPressed: _pickRange,
                icon: const Icon(Icons.date_range_outlined, size: 18),
                label: Text(_dateLabel()),
              ),
              if (_range != null)
                IconButton(
                  tooltip: '清除日期筛选',
                  onPressed: () {
                    _range = null;
                    _load(reset: true);
                  },
                  icon: const Icon(Icons.close),
                ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _load(reset: true),
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                if (_error != null)
                  TextButton(
                    onPressed: () => _load(reset: true),
                    child: Text(_error!),
                  ),
                if (_rows.isEmpty && !_loading && _error == null)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('暂无完成记录')),
                  ),
                for (final row in _rows)
                  Card(
                    child: ListTile(
                      title: Text(row.title),
                      onTap: () => _details(row),
                      subtitle: Text(
                        '${row.label} · 完成：${row.completedAt == null ? '未记录' : formatLocalDateTime(row.completedAt!)}',
                      ),
                      trailing: IconButton(
                        tooltip: '撤销完成',
                        onPressed: _busy.contains(row.key)
                            ? null
                            : () => _undo(row),
                        icon: const Icon(Icons.undo),
                      ),
                    ),
                  ),
                if (_loading) const Center(child: CircularProgressIndicator()),
                if (_more && !_loading && _error == null)
                  TextButton(
                    onPressed: () => _load(),
                    child: const Text('加载更多'),
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
