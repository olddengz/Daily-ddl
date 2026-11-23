import 'package:daily_ddl/ui/task_schedule_fields.dart';
import 'package:daily_ddl/ui/task_edit_page.dart';
import 'package:daily_ddl/db/database.dart';
import 'package:daily_ddl/services/reminder_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('重复常用项与自定义，无重复清空规则', (tester) async {
    String? rule;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => RepeatSelector(
              rule: rule,
              onChanged: (v) => setState(() => rule = v),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('无重复'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('每两天').last);
    await tester.pumpAndSettle();
    expect(rule, 'every:2:day');
    await tester.tap(find.text('每两天'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('自定义').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '3');
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    expect(rule, 'every:3:day');
    await tester.tap(find.textContaining('自定义').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('无重复').last);
    await tester.pumpAndSettle();
    expect(rule, isNull);
  });
  testWidgets('每日临时任务默认15分钟，首次阈值前不发，到点发且不重复', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await tester.pumpWidget(MaterialApp(home: TaskEditPage(db: db)));
    await tester.enterText(find.byType(TextField).first, '测试每日');
    await tester.scrollUntilVisible(
      find.text('保存任务'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('保存任务'));
    await tester.pumpAndSettle();
    final task = (await db.select(db.tasks).get()).single;
    expect(task.remindMinutes, '[15]');
    expect(task.repeatRule, isNull);
    var count = 0;
    final reminders = ReminderService(db, (_, _, _) async {
      count++;
    });
    await reminders.check([
      task,
    ], task.deadlineUtc.subtract(const Duration(minutes: 16)));
    expect(count, 0);
    await reminders.check([
      task,
    ], task.deadlineUtc.subtract(const Duration(minutes: 15)));
    expect(count, 1);
    await reminders.check([
      task,
    ], task.deadlineUtc.subtract(const Duration(minutes: 10)));
    expect(count, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  test('默认与旧配置可保留，DDL10分钟每日15分钟', () {
    expect(defaultReminders('ddl'), [10]);
    expect(defaultReminders('daily'), [15]);
    expect(repeatOptions[''], '无重复');
  });
}
