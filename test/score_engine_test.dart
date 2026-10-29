import 'package:daily_ddl/engine/score_engine.dart';
import 'package:flutter_test/flutter_test.dart';

/// 验收 A：动态剩余池（v3.2 §3 / §13-A）
void main() {
  final now = DateTime.utc(2026, 10, 16, 0, 0);

  // 文档示例：作业A 剩2天/高、考试B 剩10天/中、健身 剩5天/低
  final a = ScoreTask(id: 'A', deadlineUtc: now.add(const Duration(days: 2)), priority: 'high');
  final b = ScoreTask(id: 'B', deadlineUtc: now.add(const Duration(days: 10)), priority: 'medium');
  final c = ScoreTask(id: 'C', deadlineUtc: now.add(const Duration(days: 5)), priority: 'low');

  group('初始分配（文档示例）', () {
    test('初始分数为 60.8 / 20.3 / 18.9 且合计 100.0', () {
      final r = distributeScores([a, b, c], 0, nowUtc: now);
      expect(r.scores['A'], closeTo(60.8, 0.1));
      expect(r.scores['B'], closeTo(20.3, 0.1));
      expect(r.scores['C'], closeTo(18.9, 0.1));
      final sum = r.scores.values.reduce((x, y) => x + y);
      expect(sum, closeTo(100.0, 0.01));
      expect(r.pool, 100.0);
    });
  });

  group('验收 A：任意完成顺序累计恰为 100', () {
    test('顺序 A→B→C 累计 100（旧算法回归：60.8+51.7+100=212.5 必须不再出现）', () {
      final total = simulateCompletionSequence([a, b, c], ['A', 'B', 'C'], nowUtc: now);
      expect(total, closeTo(100.0, 0.01));
      expect(total, lessThan(101.0)); // 防旧算法回归
    });

    test('顺序 B→A→C 累计 100', () {
      final total = simulateCompletionSequence([a, b, c], ['B', 'A', 'C'], nowUtc: now);
      expect(total, closeTo(100.0, 0.01));
    });

    test('顺序 C→B→A 累计 100', () {
      final total = simulateCompletionSequence([a, b, c], ['C', 'B', 'A'], nowUtc: now);
      expect(total, closeTo(100.0, 0.01));
    });

    test('单任务直接完成得 100', () {
      final total = simulateCompletionSequence([a], ['A'], nowUtc: now);
      expect(total, closeTo(100.0, 0.01));
    });
  });

  group('验收 A：中途新增任务', () {
    test('完成 A 后新增 D（剩1天/中，W=4），再全完成累计仍 100', () {
      final d = ScoreTask(id: 'D', deadlineUtc: now.add(const Duration(days: 1)), priority: 'medium');
      final total = simulateCompletionSequence([a, b, c, d], ['A', 'D', 'B', 'C'], nowUtc: now);
      expect(total, closeTo(100.0, 0.01));
    });
  });

  group('验收 A：未完成时累计 < 100', () {
    test('只完成 A 与 B，累计 < 100', () {
      final total = simulateCompletionSequence([a, b, c], ['A', 'B'], nowUtc: now);
      expect(total, lessThan(100.0));
    });
  });

  group('手动权重覆盖', () {
    test('weightOverride 生效且全完成仍为 100', () {
      final x = ScoreTask(id: 'X', deadlineUtc: now.add(const Duration(days: 10)), priority: 'medium', weightOverride: 9);
      final y = ScoreTask(id: 'Y', deadlineUtc: now.add(const Duration(days: 10)), priority: 'medium', weightOverride: 1);
      final r = distributeScores([x, y], 0, nowUtc: now);
      expect(r.scores['X'], closeTo(90.0, 0.1));
      expect(r.scores['Y'], closeTo(10.0, 0.1));
      expect(r.scores.values.reduce((a2, b2) => a2 + b2), closeTo(100.0, 0.01));
    });
  });

  group('剩余池边界', () {
    test('已得分 ≥ 池时活跃任务分 0', () {
      final r = distributeScores([a, b], 100, nowUtc: now);
      expect(r.pool, 0.0);
      expect(r.scores['A'], 0.0);
      expect(r.scores['B'], 0.0);
    });

    test('活跃为空时分 0 且池 = 100 − earned', () {
      final r = distributeScores([], 33.3, nowUtc: now);
      expect(r.pool, closeTo(66.7, 0.01));
      expect(r.scores, isEmpty);
    });
  });

  group('权重函数', () {
    test('紧迫度区间端点', () {
      expect(urgencyWeight(0), 4);
      expect(urgencyWeight(1), 4);
      expect(urgencyWeight(2), 3);
      expect(urgencyWeight(3), 3);
      expect(urgencyWeight(4), 2);
      expect(urgencyWeight(7), 2);
      expect(urgencyWeight(8), 1.5);
      expect(urgencyWeight(14), 1.5);
      expect(urgencyWeight(15), 1);
    });

    test('优先级乘数', () {
      expect(priorityMultiplier('high'), 1.5);
      expect(priorityMultiplier('medium'), 1);
      expect(priorityMultiplier('low'), 0.7);
    });

    test('remainingDays 用 floor（不足整天向下取）', () {
      final now2 = DateTime.utc(2026, 10, 16, 12, 0);
      final dl = DateTime.utc(2026, 10, 18, 6, 0); // 1 天 18 小时 → floor 1
      expect(remainingDays(dl, now2), 1);
      final dl2 = DateTime.utc(2026, 10, 17, 6, 0); // 18 小时 → floor 0
      expect(remainingDays(dl2, now2), 0);
    });
  });
}
