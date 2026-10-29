import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import '../services/data_locator.dart';
import 'tables.dart';

part 'database.g.dart';

/// 本地数据库（v3.2 §6）。
/// 连接文件位于 exe 同级 data\db.sqlite；测试用 NativeDatabase.memory()。
@DriftDatabase(
  tables: [
    Tasks,
    Subtasks,
    CreditLedger,
    Rewards,
    RewardLogs,
    Settings,
    AiCache,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// 罚分每日唯一：type='penalty' 时 note='penalty:YYYY-MM-DD' 唯一（部分唯一索引）。
  /// 与事务内检查-写入双保险，防止多刷新入口并发重复扣罚。
  static const penaltyUniqueIndexSql =
      "CREATE UNIQUE INDEX IF NOT EXISTS ux_credit_penalty_note ON credit_ledger(note) WHERE type='penalty'";

  /// 建唯一索引前的历史去重：旧版检查-插入非事务竞态可能产生同日重复 penalty。
  /// 每组 note 保留 MIN(id) 删其余（penalty 不被 reward_logs 引用，删除安全）。
  static const penaltyDedupeSql = '''
      DELETE FROM credit_ledger
      WHERE type='penalty'
        AND id NOT IN (
          SELECT MIN(id) FROM credit_ledger WHERE type='penalty' GROUP BY note
        )
      ''';

  static const dailyUniqueIndexSql =
      "CREATE UNIQUE INDEX IF NOT EXISTS ux_daily_instance ON tasks(series_id, scheduled_date) WHERE task_kind='daily' AND series_id IS NOT NULL";

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await m.database.customStatement(penaltyUniqueIndexSql);
      await m.database.customStatement(dailyUniqueIndexSql);
    },
    onUpgrade: (m, from, to) async {
      // 1 → 2：罚分每日唯一部分索引。先去重历史重复 penalty（旧竞态产物），
      // 否则 CREATE UNIQUE INDEX 会因重复行失败导致应用无法启动。
      if (from < 3) {
        await m.database.customStatement(
          "ALTER TABLE tasks ADD COLUMN task_kind TEXT NOT NULL DEFAULT 'legacy'",
        );
        await m.database.customStatement(
          'ALTER TABLE tasks ADD COLUMN scheduled_date TEXT NULL',
        );
        await m.database.customStatement(
          'ALTER TABLE tasks ADD COLUMN series_id TEXT NULL',
        );
        await m.database.customStatement(dailyUniqueIndexSql);
      }
      if (from < 2) {
        await m.database.customStatement(penaltyDedupeSql);
        await m.database.customStatement(penaltyUniqueIndexSql);
      }
    },
  );

  /// 正式入口：数据落 exe 同级 `data\`（v3.2 §8，不写 C 盘）
  factory AppDatabase.open() {
    final dir = DataLocator.ensure();
    final file = File('$dir${Platform.pathSeparator}db.sqlite');
    return AppDatabase(NativeDatabase(file));
  }

  /// 测试入口：内存库（需宿主有 sqlite3 可用，见 AGENTS.md 测试说明）
  factory AppDatabase.memory() => AppDatabase(NativeDatabase.memory());
}
