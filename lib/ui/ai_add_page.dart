import 'package:flutter/material.dart';

import 'task_schedule_fields.dart';

import '../db/database.dart';
import 'ai_settings_page.dart';
import '../services/ai_service.dart';
import '../services/task_service.dart';

class AiAddPage extends StatefulWidget {
  const AiAddPage({super.key, required this.db, this.extractor});
  final AppDatabase db;
  final TaskExtractor? extractor;
  @override
  State<AiAddPage> createState() => _AiAddPageState();
}

class _AiAddPageState extends State<AiAddPage> {
  final config = AiConfig.instance;
  final input = TextEditingController();
  late final ApiTaskExtractor extractor;
  final rows = <_DraftEditor>[];
  bool busy = false;
  String? message;
  String? requestId;
  @override
  void initState() {
    super.initState();
    extractor = ApiTaskExtractor(config);
  }

  @override
  void dispose() {
    extractor.close();
    input.dispose();
    for (final row in rows) {
      row.dispose();
    }
    super.dispose();
  }

  Future<void> _extract() async {
    setState(() {
      busy = true;
      message = null;
    });
    try {
      final drafts = await (widget.extractor ?? extractor).extract(
        input.text,
        now: DateTime.now(),
        timeZone: DateTime.now().timeZoneOffset.toString(),
      );
      if (!mounted) return;
      for (final r in rows) {
        r.dispose();
      }
      setState(() {
        rows.clear();
        rows.addAll(drafts.map(_DraftEditor.new));
        requestId = 'ai_${DateTime.now().microsecondsSinceEpoch}';
        message = drafts.isEmpty ? '未识别到待办，请补充任务内容' : '请核对日期、类别和重复规则后添加';
      });
    } catch (e) {
      if (mounted) {
        setState(() => message = e is AiFailure ? e.message : '提取未成功，请稍后重试');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _save() async {
    setState(() {
      busy = true;
      message = null;
    });
    try {
      final selected = rows
          .where((r) => r.selected)
          .map((r) => r.draft())
          .toList();
      final service = TaskService(widget.db);
      if (selected.isEmpty) throw const AiFailure('请至少选择一项');
      for (final d in selected) {
        if (service.validate(d, DateTime.now()).isNotEmpty) {
          throw AiFailure('请检查“${d.title}”的标题、日期及重复规则。每日任务目前须从今天开始，截止须晚于当前时间。');
        }
      }
      final approval = service.prepareConfirmation(selected, DateTime.now());
      await service.confirm(
        approval,
        requestId: requestId!,
        now: DateTime.now(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => message = e is AiFailure ? e.message : '保存未成功，请核对后重试');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _pickDate(_DraftEditor row, {bool repeatEnd = false}) async {
    final current = repeatEnd ? row.end : row.deadline;
    final initial = DateTime.tryParse(current.text) ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2200),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (time == null || !mounted) return;
    setState(() {
      current.text = _DraftEditor.format(
        DateTime(date.year, date.month, date.day, time.hour, time.minute),
      );
      row.reviewed = false;
    });
  }

  Widget dateField(_DraftEditor row, {bool repeatEnd = false}) {
    final controller = repeatEnd ? row.end : row.deadline;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(repeatEnd ? '重复结束' : '截止时间'),
      subtitle: Text(
        controller.text.isEmpty
            ? (row.kind == 'plan' && !repeatEnd ? '可不设置' : '请选择')
            : controller.text,
      ),
      trailing: Wrap(
        children: [
          if ((repeatEnd || row.kind == 'plan') && controller.text.isNotEmpty)
            IconButton(
              tooltip: repeatEnd ? '清除结束日期' : '清除计划截止时间',
              onPressed: busy
                  ? null
                  : () => setState(() {
                      controller.clear();
                      row.reviewed = false;
                    }),
              icon: const Icon(Icons.clear),
            ),
          IconButton(
            tooltip: repeatEnd ? '选择结束日期' : '选择截止日期',
            onPressed: busy ? null : () => _pickDate(row, repeatEnd: repeatEnd),
            icon: const Icon(Icons.calendar_month),
          ),
        ],
      ),
      onTap: busy ? null : () => _pickDate(row, repeatEnd: repeatEnd),
    );
  }

  Widget field(
    TextEditingController c,
    String label, {
    bool secret = false,
    int lines = 1,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: TextField(
      controller: c,
      enabled: !busy,
      obscureText: secret,
      maxLines: lines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );
  Widget _inputPanel() => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('描述要做的事', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          field(input, '粘贴文字或聊天通知', lines: 5),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (!config.enabled) const Text('请先在 AI 设置中启用服务'),
              FilledButton(
                onPressed: busy || !config.enabled ? null : _extract,
                child: const Text('提取任务'),
              ),
              if (busy)
                TextButton(
                  onPressed: extractor.cancel,
                  child: const Text('取消请求'),
                ),
            ],
          ),
          if (busy) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    ),
  );

  Widget _draftCard(_DraftEditor r) => Card(
    key: ObjectKey(r),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(r.title.text),
            value: r.selected,
            onChanged: busy ? null : (v) => setState(() => r.selected = v!),
          ),
          if (r.original.unresolved.isNotEmpty) const Text('请补充并核对任务信息'),
          field(r.title, '任务名称'),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: 'daily', label: Text('每日任务')),
              ButtonSegment(value: 'ddl', label: Text('DDL任务')),
              ButtonSegment(value: 'plan', label: Text('计划')),
            ],
            selected: {r.kind},
            onSelectionChanged: busy
                ? null
                : (values) => setState(() {
                    r.kind = values.first;
                    r.reminders = defaultReminders(r.kind);
                    r.reviewed = false;
                  }),
          ),
          dateField(r),
          if (r.kind != 'plan') ...[
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text('重复与提醒'),
              subtitle: Text(
                '${repeatOptions[r.repeat.text] ?? '自定义重复'} · ${r.reminders.isEmpty ? '不提醒' : '提前${r.reminders.join('、')}分钟'}',
                style: const TextStyle(fontSize: 12),
              ),
              children: [
                const SizedBox(height: 12),
                RepeatSelector(
                  rule: r.repeat.text.isEmpty ? null : r.repeat.text,
                  enabled: !busy,
                  onChanged: (v) => setState(() {
                    r.repeat.text = v ?? '';
                    if (v == null) r.end.clear();
                    r.reviewed = false;
                  }),
                ),
                ReminderSelector(
                  minutes: r.reminders,
                  enabled: !busy,
                  onChanged: (v) => setState(() {
                    r.reminders = v;
                    r.reviewed = false;
                  }),
                ),
                if (r.repeat.text.isNotEmpty) dateField(r, repeatEnd: true),
                const SizedBox(height: 12),
              ],
            ),
            DropdownButtonFormField<String>(
              initialValue: r.priority,
              decoration: const InputDecoration(labelText: '优先级'),
              items: const [
                DropdownMenuItem(value: 'high', child: Text('高')),
                DropdownMenuItem(value: 'medium', child: Text('中')),
                DropdownMenuItem(value: 'low', child: Text('低')),
              ],
              onChanged: busy ? null : (v) => r.priority = v!,
            ),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text('备注与分类'),
              children: [
                field(r.course, '课程 / 分类'),
                field(r.note, '备注', lines: 3),
                const SizedBox(height: 12),
              ],
            ),
          ],
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              r.kind == 'plan' ? '我已核对本条计划的类别和时间' : '我已核对本条日期、类别与重复规则',
            ),
            value: r.reviewed,
            onChanged: busy ? null : (v) => setState(() => r.reviewed = v!),
          ),
        ],
      ),
    ),
  );

  Widget _resultsPanel() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Expanded(
            child: Text('核对任务', style: Theme.of(context).textTheme.titleMedium),
          ),
          Text(
            '已识别 ${rows.length} 项',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      if (message != null) ...[Text(message!), const SizedBox(height: 12)],
      if (rows.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text('提取后在此核对任务信息'),
        ),
      for (final r in rows) ...[_draftCard(r), const SizedBox(height: 16)],
      if (rows.isNotEmpty)
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed:
                busy ||
                    !rows.any((r) => r.selected) ||
                    rows.any((r) => r.selected && !r.reviewed)
                ? null
                : _save,
            child: const Text('确认添加所选任务'),
          ),
        ),
    ],
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('AI 文字添加'),
      actions: [
        Tooltip(
          message: 'AI设置',
          child: TextButton(
            onPressed: busy
                ? null
                : () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => AiSettingsPage(db: widget.db),
                      ),
                    );
                    if (mounted) setState(() {});
                  },
            child: const Text('AI 设置'),
          ),
        ),
        const SizedBox(width: 12),
      ],
    ),
    body: LayoutBuilder(
      builder: (context, constraints) {
        final wide =
            constraints.maxWidth >=
            840 * MediaQuery.textScalerOf(context).scale(1);
        final results = _resultsPanel();
        return SingleChildScrollView(
          padding: EdgeInsets.all(wide ? 28 : 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 304, child: _inputPanel()),
                        const SizedBox(width: 24),
                        Expanded(child: results),
                      ],
                    )
                  else ...[
                    _inputPanel(),
                    const SizedBox(height: 24),
                    results,
                  ],
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _DraftEditor {
  _DraftEditor(this.original)
    : title = TextEditingController(text: original.title),
      course = TextEditingController(text: original.course),
      note = TextEditingController(text: original.note),
      deadline = TextEditingController(text: format(original.deadline)),
      repeat = TextEditingController(text: original.repeatRule ?? ''),
      end = TextEditingController(text: format(original.repeatEnd)),
      kind = original.kind;
  final TaskDraft original;
  final TextEditingController title, course, note, deadline, repeat, end;
  String kind;
  late String priority = original.priority;
  late List<int> reminders = original.reminders.isEmpty
      ? defaultReminders(kind)
      : List.of(original.reminders);
  bool selected = true, reviewed = false;
  static String format(DateTime? d) => d == null
      ? ''
      : d.toLocal().toIso8601String().substring(0, 16).replaceAll('T', ' ');
  DateTime? parse(String s) {
    if (s.trim().isEmpty) return null;
    if (!RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$').hasMatch(s.trim())) {
      throw const AiFailure('时间格式应为 YYYY-MM-DD HH:mm');
    }
    final d = DateTime.tryParse(s.trim());
    if (d == null || format(d) != s.trim()) throw const AiFailure('日期无效');
    return d;
  }

  TaskDraft draft() {
    if (!reviewed) throw const AiFailure('请先勾选每条任务的核对确认');
    if (kind == 'plan') {
      return TaskDraft(
        draftId: original.draftId,
        title: title.text,
        kind: kind,
        deadline: parse(deadline.text),
      );
    }
    return TaskDraft(
      draftId: original.draftId,
      title: title.text,
      kind: kind,
      deadline: parse(deadline.text),
      course: course.text,
      note: note.text,
      priority: priority,
      reminders: reminders,
      repeatRule: repeat.text.trim().isEmpty ? null : repeat.text.trim(),
      repeatEnd: parse(end.text),
    );
  }

  void dispose() {
    for (final c in [title, course, note, deadline, repeat, end]) {
      c.dispose();
    }
  }
}
