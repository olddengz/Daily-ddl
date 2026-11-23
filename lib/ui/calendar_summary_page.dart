import 'dart:convert';

import 'package:flutter/material.dart';

import '../db/database.dart';
import '../services/ai_service.dart';
import '../services/task_calendar.dart';
import 'ai_settings_page.dart';
import 'time_label.dart';

typedef _Completion = ({String title, String kind, DateTime at});

class CalendarSummaryPage extends StatefulWidget {
  const CalendarSummaryPage({
    super.key,
    required this.db,
    required this.title,
    required this.start,
    required this.end,
    required this.days,
  });
  final AppDatabase db;
  final String title;
  final DateTime start, end;
  final Future<Map<String, CalendarDay>> days;

  @override
  State<CalendarSummaryPage> createState() => _CalendarSummaryPageState();
}

class _CalendarSummaryPageState extends State<CalendarSummaryPage> {
  final _client = ApiTaskExtractor(AiConfig.instance);
  final _expanded = <String>{};
  bool _generating = false;
  String? _summary, _error;

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  Future<void> _generate(List<_Completion> tasks, Map<String, int> counts) async {
    final config = AiConfig.instance;
    if (!config.enabled || config.key.trim().isEmpty) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => AiSettingsPage(db: widget.db)),
      );
      return;
    }
    final String host;
    try {
      host = config.uri.host;
    } on AiFailure catch (error) {
      setState(() => _error = error.message);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('生成 AI 总结'),
        content: Text(
          '将向 $host 发送所选期间的分类数量，以及 ${tasks.length} 条已完成任务的标题、类别和完成时间。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('发送并生成'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() {
      _generating = true;
      _error = null;
    });
    final payload = jsonEncode({
      'period': widget.title,
      'start': widget.start.toIso8601String().split('T').first,
      'endExclusive': widget.end.toIso8601String().split('T').first,
      'counts': counts,
      'completed': [
        for (final task in tasks)
          {
            'title': task.title,
            'kind': task.kind,
            'completedAt': formatLocalDateTime(task.at),
          },
      ],
    });
    try {
      final result = await _client.summarize(payload);
      if (mounted) setState(() => _summary = result);
    } on AiFailure catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Widget _category(String kind, String label, List<_Completion> tasks) {
    final expanded = _expanded.contains(kind);
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text('$label完成 ${tasks.length} 项'),
            trailing: IconButton(
              tooltip: expanded ? '收起$label详情' : '展开$label详情',
              icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () => setState(() {
                if (!_expanded.remove(kind)) _expanded.add(kind);
              }),
            ),
          ),
          if (expanded) ...[
            const Divider(),
            if (tasks.isEmpty) const ListTile(title: Text('暂无完成记录')),
            for (final task in tasks)
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(task.title),
                subtitle: Text(formatLocalDateTime(task.at)),
              ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final end = widget.end;
    final last = DateTime(end.year, end.month, end.day - 1);
    String date(DateTime d) => '${d.year}年${d.month}月${d.day}日';
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder(
        future: widget.days,
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('读取失败，返回后重试'));
          final data = snapshot.data;
          if (data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final completed = <_Completion>[
            for (final day in data.values) ...[
              for (final task in day.completed)
                (title: task.title, kind: task.taskKind, at: task.completedAtUtc!),
              for (final plan in day.completedPlans)
                (title: plan.title, kind: 'plan', at: plan.completedAtUtc!),
            ],
          ]..sort((a, b) => b.at.compareTo(a.at));
          final groups = <String, List<_Completion>>{'daily': [], 'ddl': [], 'plan': []};
          for (final task in completed) {
            groups.putIfAbsent(task.kind, () => []).add(task);
          }
          final counts = groups.map(
            (kind, tasks) => MapEntry(kind, tasks.length),
          );
          final categories = [
            ('daily', '每日任务'),
            ('ddl', 'DDL'),
            ('plan', '计划'),
          ];
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('${date(widget.start)} — ${date(last)}'),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          OutlinedButton.icon(
                            onPressed: completed.isEmpty || _generating
                                ? null
                                : () => _generate(completed, counts),
                            icon: const Icon(Icons.auto_awesome_outlined),
                            label: Text(_generating ? '正在生成' : '生成 AI 总结'),
                          ),
                          if (completed.isEmpty) const Text('这段时间暂无完成记录'),
                          if (_generating) const LinearProgressIndicator(),
                          if (_error != null) Text(_error!),
                          if (_summary != null) SelectableText(_summary!),
                        ],
                      ),
                    ),
                  ),
                  for (final (kind, label) in categories) ...[
                    const SizedBox(height: 10),
                    _category(kind, label, groups[kind]!),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
