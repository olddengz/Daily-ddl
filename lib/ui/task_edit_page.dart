import 'dart:convert';

import 'task_schedule_fields.dart';
import 'ai_add_page.dart';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../db/database.dart';
import '../db/task_repository.dart';
import '../services/task_service.dart';
import '../services/plan_service.dart';

class TaskEditPage extends StatefulWidget {
  const TaskEditPage({
    super.key,
    required this.db,
    this.task,
    this.plan,
  });
  final AppDatabase db;
  final Task? task;
  final Plan? plan;
  @override
  State<TaskEditPage> createState() => _TaskEditPageState();
}

class _TaskEditPageState extends State<TaskEditPage> {
  late final TaskRepository _repo;
  late final TextEditingController _title, _course, _note, _weight;
  String _kind = 'daily', _type = 'self', _priority = 'medium';
  DateTime? _deadline, _end;
  bool _saving = false;
  String? _rule;
  List<int> _reminders = [15];
  @override
  void initState() {
    super.initState();
    _repo = TaskRepository(widget.db);
    final t = widget.task;
    _title = TextEditingController(text: t?.title ?? widget.plan?.title ?? '');
    _course = TextEditingController(text: t?.course ?? '');
    _note = TextEditingController(text: t?.note ?? '');
    _weight = TextEditingController(text: t?.weightOverride?.toString() ?? '');
    _kind = widget.plan != null
        ? 'plan'
        : t == null || t.taskKind == 'daily'
        ? 'daily'
        : 'ddl';
    _type = t?.type ?? 'self';
    _priority = t?.priority ?? 'medium';
    _deadline = (t?.deadlineUtc ?? widget.plan?.deadlineUtc)?.toLocal();
    _end = t?.repeatEndUtc?.toLocal();
    _rule = t?.repeatRule;
    _reminders = t == null
        ? defaultReminders(_kind)
        : (jsonDecode(t.remindMinutes) as List).cast<int>();
  }

  @override
  void dispose() {
    for (final c in [_title, _course, _note, _weight]) {
      c.dispose();
    }
    super.dispose();
  }

  void _message(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    var date = _deadline ?? now;
    if (_kind != 'daily') {
      final selected = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (selected == null || !mounted) return;
      date = selected;
    }
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deadline ?? now),
    );
    if (time == null || !mounted) return;
    setState(
      () => _deadline = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ),
    );
  }

  Future<void> _pickEnd() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _end ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null && mounted) {
      setState(
        () => _end = DateTime(date.year, date.month, date.day, 23, 59, 59),
      );
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_title.text.trim().isEmpty) {
      _message('请填写任务标题');
      return;
    }
    if (_kind == 'plan') {
      await _savePlan();
      return;
    }
    final text = _weight.text.trim();
    final weight = text.isEmpty ? null : double.tryParse(text);
    if (text.isNotEmpty &&
        (weight == null || !weight.isFinite || weight <= 0)) {
      _message('权重必须大于 0，留空则自动计算');
      return;
    }
    final now = DateTime.now();
    final temporary = _deadline == null;
    final kind = temporary ? 'daily' : _kind;
    final deadline =
        _deadline ?? DateTime(now.year, now.month, now.day, 23, 59, 59);
    final repeating = !temporary && _rule != null;
    final rule = repeating ? _rule : null;
    final end = repeating && _end != null
        ? DateTime(_end!.year, _end!.month, _end!.day, 23, 59, 59).toUtc()
        : null;
    if (end != null && deadline.toUtc().isAfter(end)) {
      _message('重复结束日期不能早于本次截止日期');
      return;
    }
    final id = widget.task?.id ?? 't${now.microsecondsSinceEpoch}';
    final series = kind == 'daily' ? widget.task?.seriesId ?? id : null;
    final date = kind == 'daily' ? TaskRepository.localDateKey(deadline) : null;
    setState(() => _saving = true);
    try {
      final values = TasksCompanion(
        title: Value(_title.text.trim()),
        course: Value(_course.text.trim()),
        note: Value(_note.text.trim()),
        taskKind: Value(kind),
        scheduledDate: Value(date),
        seriesId: Value(series),
        type: Value(_type),
        priority: Value(_priority),
        deadlineUtc: Value(deadline.toUtc()),
        weightOverride: Value(weight),
        repeatRule: Value(rule),
        repeatEndUtc: Value(end),
        remindMinutes: Value(jsonEncode(_reminders)),
        updatedAtUtc: Value(now.toUtc()),
      );
      if (widget.task == null) {
        final service = TaskService(widget.db);
        final approval = service.prepareConfirmation([
          TaskDraft(
            draftId: id,
            title: _title.text.trim(),
            kind: kind,
            weight: weight,
            deadline: temporary ? null : deadline.toUtc(),
            explicitTemporary: temporary,
            course: _course.text.trim(),
            note: _note.text.trim(),
            priority: _priority,
            type: _type,
            repeatRule: rule,
            repeatEnd: end,
            source: 'manual',
            reminders: _reminders,
          ),
        ], now.toUtc());
        await service.confirm(approval, requestId: id, now: now.toUtc());
      } else {
        await _repo.updateTask(id, values);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        _message('保存失败，输入已保留：$e');
      }
    }
  }

  Future<void> _savePlan() async {
    final now = DateTime.now();
    if (_deadline case final deadline? when !deadline.isAfter(now)) {
      _message('请选择未来的截止时间');
      return;
    }
    setState(() => _saving = true);
    try {
      if (widget.plan case final plan?) {
        final result = await PlanService(widget.db).save(
          previous: plan,
          title: _title.text,
          deadline: _deadline,
          now: now,
        );
        if (result != PlanResult.ok) {
          if (mounted) _message('计划已变化，逾期后请先延期');
          return;
        }
      } else {
        final id = 'plan_${now.microsecondsSinceEpoch}';
        final service = TaskService(widget.db);
        final approval = service.prepareConfirmation([
          TaskDraft(
            draftId: id,
            title: _title.text,
            kind: 'plan',
            deadline: _deadline,
            source: 'manual',
          ),
        ], now);
        await service.confirm(approval, requestId: id, now: now);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) _message('保存失败，输入已保留');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    if (_saving) return;
    final t = widget.task;
    final plan = widget.plan;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除任务？'),
        content: Text(
          plan != null
              ? '删除后无法恢复，已发生的积分变动会保留。'
              : t?.taskKind == 'daily' && t?.repeatRule != null
              ? '跳过本次，下一次仍会按重复规则出现。要停止重复，请将重复改为“不重复”后保存。'
              : '删除后无法在界面恢复。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) return;
    setState(() => _saving = true);
    try {
      final deleted = plan == null
          ? await _repo.deleteTask(t!.id)
          : await PlanService(widget.db).delete(plan) == PlanResult.ok;
      if (!mounted) return;
      if (deleted) {
        if (plan == null) {
          Navigator.pop(context);
        } else {
          Navigator.pop(context, true);
        }
      } else {
        _message('任务状态已变化。逾期 DDL 可在首页归档。');
      }
    } catch (e) {
      if (mounted) _message('删除失败：$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _gap() => const SizedBox(height: 16);
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.plan != null
            ? '编辑计划'
            : widget.task == null
            ? '添加任务'
            : '编辑任务',
      ),
      actions: [
        if (widget.task == null && widget.plan == null)
          TextButton.icon(
            onPressed: _saving
                ? null
                : () async {
                    final added = await Navigator.of(context).push<bool>(
                      MaterialPageRoute<bool>(
                        builder: (_) => AiAddPage(db: widget.db),
                      ),
                    );
                    if (added == true && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
            icon: const Icon(Icons.auto_awesome_outlined),
            label: const Text('AI 文字添加'),
          ),
        if (widget.plan?.completedAtUtc == null && widget.plan != null ||
            (widget.task != null &&
                widget.task!.status != 'done' &&
                widget.task!.status != 'archived' &&
                TaskRepository.archiveCost(widget.task!, DateTime.now()) ==
                    null))
          IconButton(
            onPressed: _saving ? null : _delete,
            tooltip: '删除',
            icon: const Icon(Icons.delete_outline),
          ),
      ],
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (widget.task?.taskKind == 'legacy')
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text('这是旧版任务，请确认类别；保存后按新规则计分，历史积分不变。'),
              ),
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: '任务标题'),
              maxLines: 2,
            ),
            _gap(),
            if (widget.plan == null)
              SegmentedButton<String>(
                showSelectedIcon: widget.task != null,
                segments: [
                  const ButtonSegment(value: 'daily', label: Text('每日任务')),
                  const ButtonSegment(value: 'ddl', label: Text('DDL 任务')),
                  if (widget.task == null)
                    const ButtonSegment(value: 'plan', label: Text('计划')),
                ],
                selected: {_kind},
                onSelectionChanged: (s) => setState(() {
                  _kind = s.first;
                  if (widget.task == null) _reminders = defaultReminders(_kind);
                  if (_kind == 'daily' && _deadline != null) {
                    final now = DateTime.now();
                    _deadline = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      _deadline!.hour,
                      _deadline!.minute,
                    );
                  }
                }),
              ),
            _gap(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _deadline == null
                    ? (_kind == 'plan' ? '设置截止时间（可选）' : '不设置时间 · 今天的临时任务')
                    : '${_kind == 'daily' ? '本次结束' : '截止时间'}：${_format(_deadline!)}',
              ),
              subtitle: _kind == 'plan'
                  ? null
                  : Text(
                      _deadline == null
                          ? '当天结束，不重复；需要重复请先设置结束时间'
                          : '列表中显示倒计时，详情保留准确时间',
                    ),
              onTap: _pickDeadline,
              trailing: _deadline == null
                  ? const Icon(Icons.schedule)
                  : IconButton(
                      tooltip: _kind == 'plan' ? '清除计划截止时间' : '清除，改为今日临时任务',
                      onPressed: () => setState(() {
                        _deadline = null;
                        _rule = null;
                        _end = null;
                      }),
                      icon: const Icon(Icons.clear),
                    ),
            ),
            if (_kind != 'plan') ...[
              _gap(),
              DropdownButtonFormField<String>(
                initialValue: _priority,
                decoration: const InputDecoration(labelText: '优先级'),
                items: const [
                  DropdownMenuItem(value: 'high', child: Text('● 高')),
                  DropdownMenuItem(value: 'medium', child: Text('● 中')),
                  DropdownMenuItem(value: 'low', child: Text('● 低')),
                ],
                onChanged: (v) => setState(() => _priority = v!),
              ),
              _gap(),
              ExpansionTile(
                title: const Text('重复与提醒'),
                children: [
                  const SizedBox(height: 12),
                  RepeatSelector(
                    rule: _rule,
                    enabled: _deadline != null && !_saving,
                    onChanged: (v) => setState(() {
                      _rule = v;
                      if (v == null) _end = null;
                    }),
                  ),
                  if (_deadline != null && _rule != null)
                    ListTile(
                      title: Text(
                        _end == null
                            ? '结束日期：不限'
                            : '结束日期：${_format(_end!).split(' ').first}',
                      ),
                      onTap: _pickEnd,
                      trailing: IconButton(
                        onPressed: () => setState(() => _end = null),
                        icon: const Icon(Icons.clear),
                      ),
                    ),
                  ReminderSelector(
                    minutes: _reminders,
                    enabled: !_saving,
                    onChanged: (v) => setState(() => _reminders = v),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('提醒需要应用运行，可关闭窗口保留托盘；系统免打扰可能隐藏弹窗。'),
                  ),
                ],
              ),
              ExpansionTile(
                title: const Text('备注与高级选项'),
                children: [
                  _gap(),
                  TextField(
                    controller: _course,
                    decoration: const InputDecoration(labelText: '课程 / 分类'),
                  ),
                  _gap(),
                  TextField(
                    controller: _note,
                    decoration: const InputDecoration(labelText: '备注'),
                    maxLines: 3,
                  ),
                  _gap(),
                  DropdownButtonFormField<String>(
                    initialValue: _type,
                    decoration: const InputDecoration(labelText: '内容类型'),
                    items: const [
                      DropdownMenuItem(value: 'self', child: Text('自设')),
                      DropdownMenuItem(value: 'assignment', child: Text('作业')),
                      DropdownMenuItem(value: 'exam', child: Text('考试')),
                    ],
                    onChanged: (v) => _type = v!,
                  ),
                  _gap(),
                  TextField(
                    controller: _weight,
                    decoration: const InputDecoration(labelText: '手动权重（留空自动）'),
                    keyboardType: TextInputType.number,
                  ),
                  _gap(),
                ],
              ),
            ],
            _gap(),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? '保存中…' : '保存任务'),
            ),
          ],
        ),
      ),
    ),
  );
  String _format(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
