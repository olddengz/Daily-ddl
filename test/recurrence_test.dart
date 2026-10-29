import 'package:daily_ddl/engine/recurrence.dart';
import 'package:flutter_test/flutter_test.dart';

/// 验收 G：定期代办（v3.2 §3.3 / §13-G）
void main() {
  group('every:N:day', () {
    test('每 3 天：10-17 23:59 → 10-20 23:59（时刻保留）', () {
      final dl = DateTime.utc(2026, 10, 17, 23, 59);
      final next = nextDeadline(dl, 'every:3:day', null);
      expect(next, DateTime.utc(2026, 10, 20, 23, 59));
    });

    test('每 1 天跨月正常', () {
      final dl = DateTime.utc(2026, 10, 31, 8, 0);
      expect(nextDeadline(dl, 'every:1:day', null), DateTime.utc(2026, 11, 1, 8, 0));
    });
  });

  group('every:N:week', () {
    test('每 2 周 = +14 天', () {
      final dl = DateTime.utc(2026, 10, 17, 23, 59);
      expect(nextDeadline(dl, 'every:2:week', null), DateTime.utc(2026, 10, 31, 23, 59));
    });
  });

  group('every:N:month（月末顺延，按本地日历月，2026-10-16 外部审查修复）', () {
    // 语义：每月按用户本地日历推进；输入/断言均用本地构造，与时区无关。
    test('1-31 → 2-28（2026 非闰年取月末）', () {
      final dl = DateTime(2026, 1, 31, 23, 59);
      final next = nextDeadline(dl, 'every:1:month', null)!;
      expect(next.toLocal(), DateTime(2026, 2, 28, 23, 59));
    });

    test('1-31 → 2-29（2028 闰年）', () {
      final dl = DateTime(2028, 1, 31, 23, 59);
      final next = nextDeadline(dl, 'every:1:month', null)!;
      expect(next.toLocal(), DateTime(2028, 2, 29, 23, 59));
    });

    test('1-31 每 2 月 → 3-31（无顺延）', () {
      final dl = DateTime(2026, 1, 31, 8, 0);
      final next = nextDeadline(dl, 'every:2:month', null)!;
      expect(next.toLocal(), DateTime(2026, 3, 31, 8, 0));
    });

    test('12-31 → 次年 1-31', () {
      final dl = DateTime(2026, 12, 31, 8, 0);
      final next = nextDeadline(dl, 'every:1:month', null)!;
      expect(next.toLocal(), DateTime(2027, 1, 31, 8, 0));
    });

    test('本地月末早于 UTC 月末的边界（本地 1-31 07:00 → 本地 2-28 07:00，时区无关）', () {
      // 本地构造 + toLocal 断言（复审查 P2）：任何时区下语义一致；
      // 在 UTC+8 下该输入的 UTC 表示为 1-30 23:00，恰好跨越 UTC 月份，
      // 验证"每月按本地日历月"而非 UTC 月份。
      final dl = DateTime(2026, 1, 31, 7, 0);
      final next = nextDeadline(dl, 'every:1:month', null)!;
      expect(next.toLocal(), DateTime(2026, 2, 28, 7, 0));
    });
  });

  group('repeat_end_utc 结束日期', () {
    test('next > end → 不生成（null）', () {
      final dl = DateTime.utc(2026, 10, 17, 23, 59);
      final end = DateTime.utc(2026, 10, 19, 0, 0);
      expect(nextDeadline(dl, 'every:3:day', end), isNull); // next=10-20 > end
    });

    test('next == end 边界 → 允许生成', () {
      final dl = DateTime.utc(2026, 10, 17, 23, 59);
      final end = DateTime.utc(2026, 10, 20, 23, 59);
      expect(nextDeadline(dl, 'every:3:day', end), DateTime.utc(2026, 10, 20, 23, 59));
    });

    test('当前实例截止已不在 end 之前 → 不生成', () {
      final dl = DateTime.utc(2026, 10, 21, 0, 0);
      final end = DateTime.utc(2026, 10, 20, 0, 0);
      expect(nextDeadline(dl, 'every:3:day', end), isNull);
    });
  });

  group('规则解析与非法输入', () {
    test('null / 空 → 不重复', () {
      expect(nextDeadline(DateTime.utc(2026, 10, 17), null, null), isNull);
      expect(nextDeadline(DateTime.utc(2026, 10, 17), '', null), isNull);
    });

    test('非法规则 → null', () {
      expect(nextDeadline(DateTime.utc(2026, 10, 17), 'every:0:day', null), isNull);
      expect(nextDeadline(DateTime.utc(2026, 10, 17), 'every:3:year', null), isNull);
      expect(nextDeadline(DateTime.utc(2026, 10, 17), 'weekly:1', null), isNull);
      expect(nextDeadline(DateTime.utc(2026, 10, 17), 'every:abc:day', null), isNull);
    });

    test('RepeatRule.parse 合法规则', () {
      final r = RepeatRule.parse('every:2:week');
      expect(r, isNotNull);
      expect(r!.interval, 2);
      expect(r.unit, 'week');
    });
  });
}
