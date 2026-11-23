import 'package:flutter/material.dart';

const repeatOptions = <String, String>{
  '': '无重复',
  'every:1:day': '每天',
  'every:2:day': '每两天',
  'every:1:week': '每周',
  'every:1:month': '每月',
};
List<int> defaultReminders(String kind) => [kind == 'daily' ? 15 : 10];

class RepeatSelector extends StatelessWidget {
  const RepeatSelector({
    super.key,
    required this.rule,
    required this.onChanged,
    this.enabled = true,
  });
  final String? rule;
  final ValueChanged<String?> onChanged;
  final bool enabled;
  Future<void> _custom(BuildContext context) async {
    final parts = rule?.split(':');
    final interval = TextEditingController(
      text: parts?.length == 3 ? parts![1] : '1',
    );
    var unit = parts?.length == 3 ? parts![2] : 'day';
    String? error;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('自定义重复'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: interval,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: '每隔', errorText: error),
              ),
              DropdownButtonFormField<String>(
                initialValue: unit,
                items: const [
                  DropdownMenuItem(value: 'day', child: Text('天')),
                  DropdownMenuItem(value: 'week', child: Text('周')),
                  DropdownMenuItem(value: 'month', child: Text('月')),
                ],
                onChanged: (v) => unit = v!,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                final n = int.tryParse(interval.text);
                if (n == null || n < 1) {
                  setState(() => error = '请输入大于0的整数');
                  return;
                }
                Navigator.pop(ctx, 'every:$n:$unit');
              },
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
    // Dialog reverse transition can still reference its controller.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    interval.dispose();
    if (result != null && context.mounted) onChanged(result);
  }

  @override
  Widget build(BuildContext context) => InputDecorator(
    decoration: const InputDecoration(labelText: '重复'),
    child: DropdownButton<String>(
      isExpanded: true,
      underline: const SizedBox.shrink(),
      value: repeatOptions.containsKey(rule ?? '') ? (rule ?? '') : 'custom',
      items: [
        for (final e in repeatOptions.entries)
          DropdownMenuItem(value: e.key, child: Text(e.value)),
        DropdownMenuItem(
          value: 'custom',
          child: Text(
            rule != null && !repeatOptions.containsKey(rule)
                ? '自定义（每${rule!.split(':')[1]}${{'day': '天', 'week': '周', 'month': '月'}[rule!.split(':')[2]] ?? ''}）'
                : '自定义',
          ),
        ),
      ],
      onChanged: !enabled
          ? null
          : (v) {
              if (v == 'custom') {
                _custom(context);
              } else {
                onChanged(v!.isEmpty ? null : v);
              }
            },
    ),
  );
}

class ReminderSelector extends StatelessWidget {
  const ReminderSelector({
    super.key,
    required this.minutes,
    required this.onChanged,
    this.enabled = true,
  });
  final List<int> minutes;
  final ValueChanged<List<int>> onChanged;
  final bool enabled;
  @override
  Widget build(BuildContext context) {
    final value = minutes.join(',');
    final choices = <String, String>{
      '': '不提醒',
      '10': '提前10分钟',
      '15': '提前15分钟',
      '20': '提前20分钟',
      '30': '提前30分钟',
      '60': '提前1小时',
    };
    if (!choices.containsKey(value)) {
      choices[value] = '保留原提醒（${minutes.join('、')}分钟）';
    }
    return DropdownButtonFormField<String>(
      key: ValueKey(value),
      initialValue: value,
      decoration: const InputDecoration(labelText: '截止前提醒'),
      items: choices.entries
          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
          .toList(),
      onChanged: !enabled
          ? null
          : (v) => onChanged(
              v!.isEmpty ? [] : v.split(',').map(int.parse).toList(),
            ),
    );
  }
}
