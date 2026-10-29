import 'package:drift/drift.dart';

import 'database.dart';
import 'settings_dao.dart';

/// 应用层数据迁移（幂等，每次启动执行；settings 标记保证只跑一次）。
///
/// 与 AppDatabase 的 schema 迁移（建索引/改表）不同，这里处理业务数据的
/// 历史格式修正，可用 drift 查询 API 实现并单测。
class DataMigrations {
  DataMigrations._();

  /// 迁移 1（2026-10-17 撤销语义变更）：
  /// 旧版跨天撤销把 adjust 记在撤销当天；新规则要求冲正挂回原完成日
  /// （earn 的 settle_date）。否则升级后会出现：原完成日得分未退回、
  /// 撤销日净得分为负、剩余池超过 100。
  ///
  /// adjust 的 note 形如 `undo:<earnId>`，据此定位被冲正的 earn；
  /// 只修正 settle_date 与 earn 不一致的行（幂等）。
  static const _m1Key = 'migration_undo_adjust_settle_date';

  static Future<void> run(AppDatabase db) async {
    final settings = SettingsDao(db);
    // Date-only legacy repeat ends must be fixed even when tasks are never edited.
    if (await settings.get('migration_repeat_end_inclusive') == null) {
      await db.transaction(() async {
        for (final t in await db.select(db.tasks).get()) {
          final end = t.repeatEndUtc?.toLocal();
          if (end != null &&
              end.hour == 0 &&
              end.minute == 0 &&
              end.second == 0) {
            await (db.update(db.tasks)..where((r) => r.id.equals(t.id))).write(
              TasksCompanion(
                repeatEndUtc: Value(
                  DateTime(end.year, end.month, end.day, 23, 59, 59).toUtc(),
                ),
              ),
            );
          }
        }
        await settings.set('migration_repeat_end_inclusive', 'done');
      });
    }
    if (await settings.get(_m1Key) != null) return;

    await db.transaction(() async {
      final adjusts = await (db.select(
        db.creditLedger,
      )..where((l) => l.type.equals('adjust') & l.note.like('undo:%'))).get();

      for (final a in adjusts) {
        final earnId = int.tryParse(a.note.substring('undo:'.length));
        if (earnId == null) continue;
        final earn =
            await (db.select(db.creditLedger)
                  ..where((l) => l.id.equals(earnId))
                  ..limit(1))
                .getSingleOrNull();
        if (earn != null &&
            earn.type == 'earn' &&
            earn.settleDate != a.settleDate) {
          await (db.update(db.creditLedger)..where((l) => l.id.equals(a.id)))
              .write(CreditLedgerCompanion(settleDate: Value(earn.settleDate)));
        }
      }

      await settings.set(_m1Key, 'done');
    });
  }
}
