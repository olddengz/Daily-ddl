import 'package:daily_ddl/db/database.dart';
import 'package:daily_ddl/db/settings_dao.dart';
import 'package:daily_ddl/db/task_repository.dart';
import 'package:daily_ddl/engine/daily_settlement.dart';
import 'package:daily_ddl/engine/overdue_checker.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';

/// 仓储事务测试：完成/撤销/逾期/循环生成（v3.2 §3.3 / 验收 B·G·C 前半）
///
/// 依赖宿主 sqlite3 可用；如本机 flutter test 报 sqlite3.dll 缺失，
/// 见 AGENTS.md「测试说明」补 dll 后再跑。
void main() {
  late AppDatabase db;
  late TaskRepository repo;
  final now = DateTime.utc(2026, 10, 16, 12, 0);

  setUp(() async {
    db = AppDatabase.memory();
    repo = TaskRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<String> addTask({
    required String title,
    required DateTime deadlineUtc,
    String priority = 'medium',
    String course = '',
    double? weightOverride,
    String? repeatRule,
    DateTime? repeatEndUtc,
  }) async {
    final id = 't${title.hashCode.abs()}';
    await repo.addTask(TasksCompanion.insert(
      id: id,
      title: title,
      course: Value(course),
      deadlineUtc: deadlineUtc,
      priority: Value(priority),
      weightOverride: Value(weightOverride),
      createdAtUtc: now,
      updatedAtUtc: now,
      repeatRule: Value(repeatRule),
      repeatEndUtc: Value(repeatEndUtc),
    ));
    return id;
  }

  group('完成事务（验收 C 前半）', () {
    test('完成 → done + earn 流水同现，余额 == 冻结分数', () async {
      final id = await addTask(title: '作业', deadlineUtc: now.add(const Duration(days: 2)), priority: 'high');
      final r = await repo.completeTask(id, now);
      expect(r.ok, isTrue);
      expect(r.score, isNotNull);

      final t = await repo.taskById(id);
      expect(t!.status, 'done');
      expect(t.completedAtUtc, isNotNull);

      final ledger = await repo.ledger();
      final earns = ledger.where((l) => l.type == 'earn' && l.refId == id).toList();
      expect(earns.length, 1);
      expect(earns.single.amount, r.score);

      expect(await repo.balance(), closeTo(r.score!, 0.01));
    });

    test('重复完成被拒（already_done）且不产生第二笔流水', () async {
      final id = await addTask(title: '作业', deadlineUtc: now.add(const Duration(days: 2)));
      await repo.completeTask(id, now);
      final r2 = await repo.completeTask(id, now);
      expect(r2.ok, isFalse);
      expect(r2.reason, 'already_done');
      final earns = (await repo.ledger()).where((l) => l.type == 'earn' && l.refId == id).toList();
      expect(earns.length, 1);
    });
  });

  group('验收 B：逾期判定精确到时刻', () {
    test('14:00 截止，14:01 完成被拒并置 overdue', () async {
      final dl = DateTime.utc(2026, 10, 16, 14, 0);
      final id = await addTask(title: '下午截止', deadlineUtc: dl);
      final late = DateTime.utc(2026, 10, 16, 14, 1);
      final r = await repo.completeTask(id, late);
      expect(r.ok, isFalse);
      expect(r.reason, 'overdue');
      expect((await repo.taskById(id))!.status, 'overdue');
      expect((await repo.ledger()).where((l) => l.type == 'earn').length, 0);
    });

    test('截止时刻整点：14:00 整视为逾期（now >= deadline）', () async {
      final dl = DateTime.utc(2026, 10, 16, 14, 0);
      final id = await addTask(title: '整点截止', deadlineUtc: dl);
      final r = await repo.completeTask(id, dl);
      expect(r.ok, isFalse);
      expect(r.reason, 'overdue');
    });

    test('14:00 截止，13:59 完成成功', () async {
      final dl = DateTime.utc(2026, 10, 16, 14, 0);
      final id = await addTask(title: '提前完成', deadlineUtc: dl);
      final r = await repo.completeTask(id, DateTime.utc(2026, 10, 16, 13, 59));
      expect(r.ok, isTrue);
    });

    test('跨日遗留任务：日结算置 overdue', () async {
      final id = await addTask(title: '昨日遗留', deadlineUtc: now.subtract(const Duration(days: 1)));
      final s = await DailySettlement(db).run(now);
      expect(s.overdueCount, 1);
      expect((await repo.taskById(id))!.status, 'overdue');
    });

    test('OverdueChecker 辅助函数', () {
      expect(OverdueChecker.isOverdue(status: 'todo', deadlineUtc: now, nowUtc: now), isTrue);
      expect(OverdueChecker.isOverdue(status: 'todo', deadlineUtc: now.add(const Duration(seconds: 1)), nowUtc: now), isFalse);
      expect(OverdueChecker.isOverdue(status: 'done', deadlineUtc: now, nowUtc: now), isFalse);
      expect(OverdueChecker.isOverdue(status: 'overdue', deadlineUtc: now, nowUtc: now), isFalse);
    });
  });

  group('验收 G：定期代办（仓储层）', () {
    test('完成循环任务 → 自动生成下一实例（+3 天、字段复制、source=recurring、parentTaskId）', () async {
      final dl = DateTime.utc(2026, 10, 17, 23, 59);
      final id = await addTask(title: '每周健身', deadlineUtc: dl, repeatRule: 'every:3:day', priority: 'low');

      final r = await repo.completeTask(id, now);
      expect(r.ok, isTrue);

      final children = await (db.select(db.tasks)..where((t) => t.parentTaskId.equals(id))).get();
      expect(children.length, 1);
      final child = children.single;
      expect(child.status, 'todo');
      // drift 读回的 DateTime 为本地时区表示（isUtc=false），比较时先 toUtc() 归一化
      expect(child.deadlineUtc.toUtc(), DateTime.utc(2026, 10, 20, 23, 59));
      expect(child.source, 'recurring');
      expect(child.title, '每周健身');
      expect(child.priority, 'low');
      expect(child.repeatRule, 'every:3:day');
    });

    test('逾期完成被拒 → 不生成下一实例', () async {
      final dl = now.subtract(const Duration(hours: 1));
      final id = await addTask(title: '逾期循环', deadlineUtc: dl, repeatRule: 'every:1:day');
      final r = await repo.completeTask(id, now);
      expect(r.ok, isFalse);
      expect(r.reason, 'overdue');
      final children = await (db.select(db.tasks)..where((t) => t.parentTaskId.equals(id))).get();
      expect(children, isEmpty);
    });

    test('repeat_end 到点 → 完成不生成下一实例', () async {
      final dl = DateTime.utc(2026, 10, 17, 23, 59);
      final end = DateTime.utc(2026, 10, 19, 0, 0);
      final id = await addTask(title: '限次循环', deadlineUtc: dl, repeatRule: 'every:3:day', repeatEndUtc: end);
      final r = await repo.completeTask(id, now);
      expect(r.ok, isTrue); // 本次可完成
      final children = await (db.select(db.tasks)..where((t) => t.parentTaskId.equals(id))).get();
      expect(children, isEmpty); // next=10-20 > end → 不生成
    });
  });

  group('撤销完成（验收 C 后半）', () {
    test('撤销 → adjust 冲正 + 状态回 todo + 余额回滚', () async {
      final id = await addTask(title: '可撤销', deadlineUtc: now.add(const Duration(days: 2)));
      final r = await repo.completeTask(id, now);
      final before = await repo.balance();
      expect(before, r.score);

      final ok = await repo.undoComplete(id, now);
      expect(ok, isTrue);
      expect((await repo.taskById(id))!.status, 'todo');
      expect((await repo.taskById(id))!.completedAtUtc, isNull);
      final adjusts = (await repo.ledger()).where((l) => l.type == 'adjust' && l.refId == id).toList();
      expect(adjusts.length, 1);
      expect(adjusts.single.amount, closeTo(-r.score!, 0.01));
      expect(await repo.balance(), closeTo(0, 0.01));
    });

    test('撤销循环任务完成 → 删除已生成的下一实例', () async {
      final dl = DateTime.utc(2026, 10, 17, 23, 59);
      final id = await addTask(title: '循环撤销', deadlineUtc: dl, repeatRule: 'every:3:day');
      await repo.completeTask(id, now);
      expect((await (db.select(db.tasks)..where((t) => t.parentTaskId.equals(id))).get()).length, 1);

      await repo.undoComplete(id, now);
      final children = await (db.select(db.tasks)..where((t) => t.parentTaskId.equals(id))).get();
      expect(children, isEmpty);
      expect((await repo.taskById(id))!.status, 'todo');
    });

    test('撤销时 deadline 已过 → 状态回 overdue', () async {
      final dl = now.add(const Duration(hours: 2));
      final id = await addTask(title: '跨时撤销', deadlineUtc: dl);
      await repo.completeTask(id, now); // 13:00 完成，截止 14:00
      final later = DateTime.utc(2026, 10, 16, 15, 0);
      await repo.undoComplete(id, later);
      expect((await repo.taskById(id))!.status, 'overdue');
    });

    test('对 todo 任务撤销返回 false', () async {
      final id = await addTask(title: '未完成', deadlineUtc: now.add(const Duration(days: 2)));
      expect(await repo.undoComplete(id, now), isFalse);
    });
  });

  group('删除规则（v3.2 §3.3）', () {
    test('done 任务不可删（只能撤销）', () async {
      final id = await addTask(title: '已完成', deadlineUtc: now.add(const Duration(days: 2)));
      await repo.completeTask(id, now);
      expect(await repo.deleteTask(id), isFalse);
      expect(await repo.taskById(id), isNotNull);
    });

    test('todo 任务可删；删除循环实例 = 跳过本次（不生成）', () async {
      final id = await addTask(title: '可删除', deadlineUtc: now.add(const Duration(days: 2)), repeatRule: 'every:1:day');
      expect(await repo.deleteTask(id), isTrue);
      expect(await repo.taskById(id), isNull);
    });
  });

  group('earnedToday / 日结算幂等', () {
    test('同日撤销 → earnedToday 退回（试用修复 2026-10-17）', () async {
      final id = await addTask(title: '统计', deadlineUtc: now.add(const Duration(days: 2)));
      await repo.completeTask(id, now);
      final earned = await repo.earnedToday(now.toLocal());
      expect(earned, greaterThan(0));

      // 撤销冲正挂回原完成日（同日）→ 当日净得分退回 0
      expect(await repo.undoComplete(id, now), isTrue);
      final earned2 = await repo.earnedToday(now.toLocal());
      expect(earned2, closeTo(0, 0.01));
      // 余额同时冲正归零
      expect(await repo.balance(), closeTo(0, 0.01));

      // 同日撤销后重新完成 → 拿完整池（earnedToday 恢复为该次得分）
      final r2 = await repo.completeTask(id, now);
      expect(r2.ok, isTrue);
      expect(await repo.earnedToday(now.toLocal()), closeTo(r2.score!, 0.01));
    });

    test('跨天撤销 → 冲正挂原完成日：修正原日净得分与余额，撤销日无负数（复审 P2 措辞）', () async {
      final id = await addTask(title: '跨天统计', deadlineUtc: now.add(const Duration(days: 2)));
      final r = await repo.completeTask(id, now);
      final yesterdayEarned = await repo.earnedToday(now.toLocal());
      expect(yesterdayEarned, closeTo(r.score!, 0.01));

      final tomorrow = now.add(const Duration(days: 1));
      expect(await repo.undoComplete(id, tomorrow), isTrue);
      // 原完成日净得分退回
      expect(await repo.earnedToday(now.toLocal()), closeTo(0, 0.01));
      // 撤销当日（明天）已得不受影响、无负数
      expect(await repo.earnedToday(tomorrow.toLocal()), closeTo(0, 0.01));
      // 余额冲正归零
      expect(await repo.balance(), closeTo(0, 0.01));
    });

    test('日结算幂等：重复 run 不重复置位', () async {
      await addTask(title: '遗留', deadlineUtc: now.subtract(const Duration(days: 1)));
      final s1 = await DailySettlement(db).run(now);
      final s2 = await DailySettlement(db).run(now);
      expect(s1.overdueCount, 1);
      expect(s2.overdueCount, 0);
    });

    test('惩罚默认关闭 → 无 penalty 流水', () async {
      await addTask(title: '昨日未完成', deadlineUtc: now.subtract(const Duration(days: 1)));
      await DailySettlement(db).run(now);
      final penalties = (await repo.ledger()).where((l) => l.type == 'penalty').toList();
      expect(penalties, isEmpty);
    });

    test('开启惩罚且昨日 earn < 80 → 一条 penalty；再次 run 幂等', () async {
      await addTask(title: '昨日完成', deadlineUtc: now.subtract(const Duration(days: 1)));
      final settings = SettingsDao(db);
      await settings.set('penalty_enabled', 'true');
      final s1 = await DailySettlement(db).run(now);
      expect(s1.penaltyApplied, isTrue);
      final penalties = (await repo.ledger()).where((l) => l.type == 'penalty').toList();
      expect(penalties.length, 1);
      expect(penalties.single.amount, -10.0);

      final s2 = await DailySettlement(db).run(now);
      expect(s2.penaltyApplied, isFalse);
      expect((await repo.ledger()).where((l) => l.type == 'penalty').length, 1);
    });

    test('惩罚阈值边界：昨日 earn ≥ 阈值不罚（严格小于才罚）', () async {
      // 昨日（本地 10-15）完成任务：UTC 10-15 14:00 = 本地 10-15 22:00，
      // deadline UTC 10-15 15:00 = 本地 23:00 未逾期 → earn 记入昨日
      final yesterday = DateTime.utc(2026, 10, 15, 14, 0);
      final dl = DateTime.utc(2026, 10, 15, 15, 0);
      final id = await addTask(title: '昨日高分', deadlineUtc: dl);
      final r = await repo.completeTask(id, yesterday);
      expect(r.ok, isTrue);
      expect(await repo.earnedToday(yesterday.toLocal()), closeTo(100, 0.01));

      final settings = SettingsDao(db);
      await settings.set('penalty_enabled', 'true');
      await settings.set('penalty_threshold', '50');
      final s = await DailySettlement(db).run(now);
      expect(s.penaltyApplied, isFalse);
      expect((await repo.ledger()).where((l) => l.type == 'penalty').length, 0);
    });

    test('惩罚跟随净得分：昨日完成高分但已撤销（净 0）→ 应罚（撤销语义变更复审 P1）', () async {
      final yesterday = DateTime.utc(2026, 10, 15, 14, 0);
      final dl = DateTime.utc(2026, 10, 15, 15, 0);
      final id = await addTask(title: '昨日撤销高分', deadlineUtc: dl);
      final r = await repo.completeTask(id, yesterday);
      expect(r.ok, isTrue);
      expect(await repo.earnedToday(yesterday.toLocal()), closeTo(100, 0.01));

      // 今日撤销 → 冲正挂回昨日 → 昨日净得分 0
      expect(await repo.undoComplete(id, now), isTrue);
      expect(await repo.earnedToday(yesterday.toLocal()), closeTo(0, 0.01));

      // 净口径下昨日不足阈值 → 应罚（撤销 = 昨日未完成）
      final settings = SettingsDao(db);
      await settings.set('penalty_enabled', 'true');
      final s = await DailySettlement(db).run(now);
      expect(s.penaltyApplied, isTrue);
      final penalties = (await repo.ledger()).where((l) => l.type == 'penalty').toList();
      expect(penalties.length, 1);
    });

    test('并发两个 run 结算同一天：罚分每日仅一条（事务原子化+唯一索引，2026-10-17 审查）', () async {
      await addTask(title: '昨日未完成', deadlineUtc: now.subtract(const Duration(days: 1)));
      await SettingsDao(db).set('penalty_enabled', 'true');

      // 模拟定时器/前台恢复/手动刷新重叠：两个 run 同时执行
      final results = await Future.wait([
        DailySettlement(db).run(now),
        DailySettlement(db).run(now),
      ]);
      expect(results.where((r) => r.penaltyApplied).length, 1);
      expect((await repo.ledger()).where((l) => l.type == 'penalty').length, 1);
    });
  });

  group('审查修复回归（双 AI 审查 P1/P2/P3）', () {
    test('编辑保存（write 语义）不重置 status/source（P1-2）', () async {
      final id = await addTask(title: '编辑回归', deadlineUtc: now.add(const Duration(days: 2)));
      final r = await repo.completeTask(id, now);
      expect(r.ok, isTrue);

      await repo.updateTask(id, TasksCompanion(
            title: const Value('编辑回归-改名'),
            updatedAtUtc: Value(now),
          ));
      final t = await repo.taskById(id);
      expect(t!.status, 'done'); // 不得被重置为 todo
      expect(t.source, 'manual');
      expect(t.title, '编辑回归-改名');

      // 重复完成被拒、余额仍为冻结分数（不重复领分）
      final r2 = await repo.completeTask(id, now);
      expect(r2.ok, isFalse);
      expect(r2.reason, 'already_done');
    });

    test('循环子实例复制 course（P1-1 / 验收 G 字段一致）', () async {
      final dl = DateTime.utc(2026, 10, 17, 9, 0);
      final id = await addTask(title: '带课程循环', deadlineUtc: dl, course: '高数', repeatRule: 'every:1:day', priority: 'low');
      await repo.completeTask(id, now);
      final children = await (db.select(db.tasks)..where((t) => t.parentTaskId.equals(id))).get();
      expect(children.length, 1);
      expect(children.single.course, '高数');
      expect(children.single.title, '带课程循环');
      expect(children.single.note, '');
    });

    test('撤销时子实例已完成 → 保留（已真实发生）', () async {
      final dl = now.add(const Duration(days: 3));
      final id = await addTask(title: '父任务', deadlineUtc: dl, repeatRule: 'every:1:day');
      await repo.completeTask(id, now);
      final children = await (db.select(db.tasks)..where((t) => t.parentTaskId.equals(id))).get();
      final child = children.single;
      // 子实例在父任务撤销前已被完成
      final c2 = await repo.completeTask(child.id, now);
      expect(c2.ok, isTrue);

      await repo.undoComplete(id, now);
      final after = await repo.taskById(child.id);
      expect(after, isNotNull); // 已完成子实例保留
      expect(after!.status, 'done');
    });

    test('completeTask 不存在任务 → not_found 且无流水', () async {
      final r = await repo.completeTask('no_such_id', now);
      expect(r.ok, isFalse);
      expect(r.reason, 'not_found');
      expect(await repo.ledger(), isEmpty);
    });

    test('删除曾完成-撤销的 todo 任务：流水保留（审计）', () async {
      final id = await addTask(title: '曾完成', deadlineUtc: now.add(const Duration(days: 2)));
      await repo.completeTask(id, now);
      await repo.undoComplete(id, now);
      expect(await repo.deleteTask(id), isTrue);
      // 余额不受影响（earn+adjust 相抵），流水保留作为审计
      expect(await repo.balance(), closeTo(0, 0.01));
      expect((await repo.ledger()).length, 2);
    });

    test('撤销时 overdue 子实例一并删除（第三轮审查 P3-1）', () async {
      final dl = now.add(const Duration(days: 3));
      final id = await addTask(title: '父任务', deadlineUtc: dl, repeatRule: 'every:1:day');
      await repo.completeTask(id, now);
      final children = await (db.select(db.tasks)..where((t) => t.parentTaskId.equals(id))).get();
      expect(children.length, 1);
      final childId = children.single.id;

      // 子实例已逾期（markOverdueAll 置 overdue）；父任务已完成不受影响
      final later = children.single.deadlineUtc.toUtc().add(const Duration(minutes: 1));
      final marked = await repo.markOverdueAll(later);
      expect(marked, 1);
      expect((await repo.taskById(childId))!.status, 'overdue');

      // 撤销父任务完成 → overdue 子实例同事务删除，不留孤儿
      expect(await repo.undoComplete(id, later), isTrue);
      final after = await (db.select(db.tasks)..where((t) => t.parentTaskId.equals(id))).get();
      expect(after, isEmpty);
      // 父任务 deadline 也已过 → 回滚为 overdue
      expect((await repo.taskById(id))!.status, 'overdue');
    });

    test('逾期任务延后截止 → 自动恢复 todo（外部审查-高：避免 0 分完成）', () async {
      final id = await addTask(title: '逾期延期', deadlineUtc: now.subtract(const Duration(days: 1)));
      final marked = await repo.markOverdueAll(now);
      expect(marked, 1);
      expect((await repo.taskById(id))!.status, 'overdue');

      // 延后到未来（nowUtc 注入，确定性）→ 恢复 todo
      await repo.updateTask(id, TasksCompanion(
            deadlineUtc: Value(now.add(const Duration(days: 2))),
            updatedAtUtc: Value(now),
          ), nowUtc: now);
      expect((await repo.taskById(id))!.status, 'todo');

      // 仍在过去 → 该更新不触发恢复（保持 todo）；日结算随后置位 overdue
      await repo.updateTask(id, TasksCompanion(
            deadlineUtc: Value(now.subtract(const Duration(hours: 1))),
            updatedAtUtc: Value(now),
          ), nowUtc: now);
      expect((await repo.taskById(id))!.status, 'todo');
      await repo.markOverdueAll(now);
      expect((await repo.taskById(id))!.status, 'overdue');
    });

    test('done 任务编辑 deadline → 状态保持 done（恢复逻辑不触碰已完成）', () async {
      final id = await addTask(title: '已完成编辑', deadlineUtc: now.add(const Duration(days: 2)));
      await repo.completeTask(id, now);
      await repo.updateTask(id, TasksCompanion(
            deadlineUtc: Value(now.add(const Duration(days: 5))),
            updatedAtUtc: Value(now),
          ), nowUtc: now);
      expect((await repo.taskById(id))!.status, 'done');
    });
  });
}
