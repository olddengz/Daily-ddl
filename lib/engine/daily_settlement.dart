import 'package:drift/drift.dart';

import '../db/database.dart';
import '../db/settings_dao.dart';
import '../db/task_repository.dart';

/// 日结算（v3.2 §4，幂等）：
/// 1. 将 now >= deadline 的 todo 置 overdue（按时刻判定，不按天）
/// 2. 完成率惩罚（默认关闭）：昨日净得分 < 阈值 → penalty(−10)，幂等键保证每日最多一条
///    （净得分 = earn + adjust，撤销语义变更复审 P1：撤销视为未完成，按净口径判定）
class DailySettlement {
  DailySettlement(this.db);

  final AppDatabase db;

  Future<SettlementResult> run(DateTime nowUtc) async {
    final repo = TaskRepository(db);
    await repo.ensureDailyInstances(nowUtc);
    final overdueCount = await repo.markOverdueAll(nowUtc);

    var penaltyApplied = false;
    final settings = SettingsDao(db);
    final enabled = await settings.getBool('penalty_enabled', fallback: false);
    if (enabled) {
      final threshold = await settings.getDouble(
        'penalty_threshold',
        fallback: 80,
      );
      final points = await settings.getDouble('penalty_points', fallback: 10);
      final yesterday = nowUtc.toLocal().subtract(const Duration(days: 1));
      final key = TaskRepository.localDateKey(yesterday);

      // 检查与写入原子化（并发审查 2026-10-17）：定时器/前台恢复/手动刷新可能
      // 重叠调用 run()；单连接 SQLite 事务串行执行，第二个事务内必能查到
      // 已插入的罚分；部分唯一索引 ux_credit_penalty_note 作为兜底。
      await db.transaction(() async {
        final existing =
            await (db.select(db.creditLedger)..where(
                  (l) =>
                      l.type.equals('penalty') & l.note.equals('penalty:$key'),
                ))
                .getSingleOrNull();

        // 昨日净得分（earn + adjust）：与 earnedToday 净口径统一（撤销语义变更复审 P1）。
        // 撤销后的任务视为昨日未完成，净得分不足阈值 → 应罚。
        final yesterdayLedger =
            await (db.select(db.creditLedger)..where(
                  (l) =>
                      (l.type.equals('earn') | l.type.equals('adjust')) &
                      l.settleDate.equals(key),
                ))
                .get();
        final earned = yesterdayLedger.fold<double>(0, (s, r) => s + r.amount);

        if (existing == null && earned < threshold) {
          await db
              .into(db.creditLedger)
              .insert(
                CreditLedgerCompanion.insert(
                  type: 'penalty',
                  amount: -points,
                  refType: const Value(null),
                  refId: const Value(null),
                  settleDate: TaskRepository.localDateKey(nowUtc.toLocal()),
                  note: Value('penalty:$key'),
                  createdAtUtc: nowUtc,
                ),
              );
          penaltyApplied = true;
        }
      });
    }

    return SettlementResult(
      overdueCount: overdueCount,
      penaltyApplied: penaltyApplied,
    );
  }
}

class SettlementResult {
  const SettlementResult({
    required this.overdueCount,
    required this.penaltyApplied,
  });

  final int overdueCount;
  final bool penaltyApplied;
}
