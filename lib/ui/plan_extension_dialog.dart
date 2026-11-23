import 'package:flutter/material.dart';

import '../services/plan_service.dart';

Future<int?> choosePlanExtension(BuildContext context, double balance) =>
    showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('用积分延长计划'),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text('选择后立即扣分，新截止时间从确认时起算。'),
          ),
          for (final entry in PlanService.extensionCosts.entries)
            SimpleDialogOption(
              onPressed: balance < entry.value
                  ? null
                  : () => Navigator.pop(context, entry.key),
              child: Text(
                '延长 ${entry.key} 天 · 扣 ${entry.value} 积分'
                '${balance < entry.value ? '（积分不足）' : ''}',
              ),
            ),
        ],
      ),
    );
