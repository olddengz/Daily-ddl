import 'package:flutter/material.dart';

import '../db/database.dart';
import '../services/task_service.dart';
import 'time_label.dart';

class TaskHistoryPage extends StatefulWidget {
  const TaskHistoryPage({super.key, required this.db});
  final AppDatabase db;
  @override
  State<TaskHistoryPage> createState() => _TaskHistoryPageState();
}

class _TaskHistoryPageState extends State<TaskHistoryPage> {
  late final TaskService _service;
  List<Task> _rows = [];
  String? _kind, _error;
  bool _loading = false, _more = true;
  final Set<String> _busy = {};
  int _generation = 0;
  @override
  void initState() {
    super.initState();
    _service = TaskService(widget.db);
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
      final rows = await _service.history(
        kind: _kind,
        offset: reset ? 0 : _rows.length,
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        _rows = [..._rows, ...rows];
        _more = rows.length == 30;
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

  Future<void> _undo(Task t) async {
    if (_busy.contains(t.id)) return;
    setState(() => _busy.add(t.id));
    try {
      final ok = await _service.undo(t, DateTime.now().toUtc());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? '已撤销完成，任务按原日期与截止时间恢复' : '任务状态已变化，请刷新')),
      );
      await _load(reset: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('撤销失败，请重试')));
      }
    } finally {
      if (mounted) setState(() => _busy.remove(t.id));
    }
  }

  void _details(Task t) => showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(t.title),
      content: SingleChildScrollView(
        child: Text(
          [
            '类别：${t.taskKind == 'daily'
                ? '每日任务'
                : t.taskKind == 'legacy'
                ? '旧版待分类'
                : 'DDL'}',
            '完成时间：${t.completedAtUtc == null ? '未记录' : formatLocalDateTime(t.completedAtUtc!)}',
            '截止时间：${formatLocalDateTime(t.deadlineUtc)}',
            if (t.scheduledDate != null) '所属日期：${t.scheduledDate}',
            if (t.course.isNotEmpty) '课程：${t.course}',
            if (t.note.isNotEmpty) '备注：${t.note}',
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
              }.entries)
                ChoiceChip(
                  label: Text(entry.value),
                  selected: _kind == entry.key,
                  onSelected: (_) {
                    _kind = entry.key;
                    _load(reset: true);
                  },
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
                for (final t in _rows)
                  Card(
                    child: ListTile(
                      title: Text(t.title),
                      onTap: () => _details(t),
                      subtitle: Text(
                        '完成：${t.completedAtUtc == null ? '未记录' : formatLocalDateTime(t.completedAtUtc!)}',
                      ),
                      trailing: IconButton(
                        tooltip: '撤销完成',
                        onPressed: _busy.contains(t.id) ? null : () => _undo(t),
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
