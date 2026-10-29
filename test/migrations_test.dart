import 'package:daily_ddl/db/database.dart';
import 'package:daily_ddl/db/migrations.dart';
import 'package:daily_ddl/db/task_repository.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

/// 应用层数据迁移（2026-10-17 审查）：旧版跨天撤销 adjust 挂在撤销当天的修正
void main() {
  late AppDatabase db;
  late TaskRepository repo;

  setUp(() {
    db = AppDatabase.memory();
    repo = TaskRepository(db);
  });

  tearDown(() => db.close());

  Future<int> insertLedger({
    required String type,
    required double amount,
    required String settleDate,
    String? note,
    required DateTime createdAtUtc,
  }) async {
    final row = await db
        .into(db.creditLedger)
        .insertReturning(
          CreditLedgerCompanion.insert(
            type: type,
            amount: amount,
            refType: const Value('task'),
            refId: const Value('t1'),
            settleDate: settleDate,
            note: Value(note ?? ''),
            createdAtUtc: createdAtUtc,
          ),
        );
    return row.id;
  }

  test('迁移 1：旧版跨天撤销（adjust 在撤销当天）→ 修正挂回原完成日', () async {
    // 旧格式：10-15 earn +100，10-16 adjust -100（撤销当天）
    final earnId = await insertLedger(
      type: 'earn',
      amount: 100,
      settleDate: '2026-10-15',
      note: 'complete',
      createdAtUtc: DateTime.utc(2026, 10, 15, 14, 0),
    );
    await insertLedger(
      type: 'adjust',
      amount: -100,
      settleDate: '2026-10-16',
      note: 'undo:$earnId',
      createdAtUtc: DateTime.utc(2026, 10, 16, 12, 0),
    );

    // 迁移前：撤销日净得分为负（旧 bug），原完成日未退回
    expect(await repo.earnedToday(DateTime(2026, 10, 16)), closeTo(-100, 0.01));
    expect(await repo.earnedToday(DateTime(2026, 10, 15)), closeTo(100, 0.01));

    await DataMigrations.run(db);

    // 迁移后：两日净得分均为 0（原日退回、撤销日无负数），余额始终相抵
    expect(await repo.earnedToday(DateTime(2026, 10, 15)), closeTo(0, 0.01));
    expect(await repo.earnedToday(DateTime(2026, 10, 16)), closeTo(0, 0.01));
    expect(await repo.balance(), closeTo(0, 0.01));
  });

  test('迁移 1：幂等（重复执行不改变结果、settings 标记只跑一次）', () async {
    final earnId = await insertLedger(
      type: 'earn',
      amount: 100,
      settleDate: '2026-10-15',
      note: 'complete',
      createdAtUtc: DateTime.utc(2026, 10, 15, 14, 0),
    );
    await insertLedger(
      type: 'adjust',
      amount: -100,
      settleDate: '2026-10-16',
      note: 'undo:$earnId',
      createdAtUtc: DateTime.utc(2026, 10, 16, 12, 0),
    );

    await DataMigrations.run(db);
    await DataMigrations.run(db); // 第二次应直接跳过

    expect(await repo.earnedToday(DateTime(2026, 10, 15)), closeTo(0, 0.01));
    expect(await repo.earnedToday(DateTime(2026, 10, 16)), closeTo(0, 0.01));
    // 流水行数不变（仅修正 settle_date，不增删）
    expect((await repo.ledger()).length, 2);
  });

  test('迁移 1：已是新格式（adjust 与 earn 同日）→ 不改动', () async {
    final earnId = await insertLedger(
      type: 'earn',
      amount: 100,
      settleDate: '2026-10-15',
      note: 'complete',
      createdAtUtc: DateTime.utc(2026, 10, 15, 14, 0),
    );
    await insertLedger(
      type: 'adjust',
      amount: -100,
      settleDate: '2026-10-15',
      note: 'undo:$earnId',
      createdAtUtc: DateTime.utc(2026, 10, 15, 16, 0),
    );

    await DataMigrations.run(db);
    expect(await repo.earnedToday(DateTime(2026, 10, 15)), closeTo(0, 0.01));
    expect(await repo.earnedToday(DateTime(2026, 10, 16)), closeTo(0, 0.01));
  });

  test('schema 2：罚分部分唯一索引存在（onCreate）', () async {
    final rows = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type='index' AND name='ux_credit_penalty_note'",
        )
        .get();
    expect(rows, isNotEmpty);
  });

  // ---- 脏数据边界（复审 P3/P4，2026-10-17） ----

  test('迁移 1：脏数据安全跳过（note 非数字 / earn 不存在 / 指向非 earn 流水）', () async {
    // 1) note='undo:abc'（id 不可解析）
    await insertLedger(
      type: 'adjust',
      amount: -50,
      settleDate: '2026-10-16',
      note: 'undo:abc',
      createdAtUtc: DateTime.utc(2026, 10, 16, 12, 0),
    );
    // 2) note='undo:999'（earn 不存在）
    await insertLedger(
      type: 'adjust',
      amount: -60,
      settleDate: '2026-10-16',
      note: 'undo:999',
      createdAtUtc: DateTime.utc(2026, 10, 16, 12, 1),
    );
    // 3) id 指向一条 redeem 流水（非 earn）→ 不得借用其 settleDate
    await insertLedger(
      type: 'redeem',
      amount: -30,
      settleDate: '2026-10-15',
      note: 'reward:1',
      createdAtUtc: DateTime.utc(2026, 10, 15, 18, 0),
    );
    await insertLedger(
      type: 'adjust',
      amount: -70,
      settleDate: '2026-10-16',
      note: 'undo:3',
      createdAtUtc: DateTime.utc(2026, 10, 16, 12, 2),
    );

    await DataMigrations.run(db); // 不得抛错

    final rows = await repo.ledger();
    final dirty = rows.where((r) => r.type == 'adjust').toList();
    // 三条 adjust 的 settle_date 均保持原样（不被错误修改）
    expect(dirty.every((r) => r.settleDate == '2026-10-16'), isTrue);
    expect(dirty.length, 3);
  });

  // ---- schema onUpgrade 真实路径（复审 P1/P2，2026-10-17） ----

  group('schema v1 → v2 升级（onUpgrade）', () {
    // 本组有意在同一 raw sqlite3 连接上先后打开两个 AppDatabase 实例模拟升级
    setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

    test('旧库存在重复 penalty：升级先去重再建索引，应用可正常打开', () async {
      final raw = sqlite3.openInMemory();

      // 第一步：以当前 schema 建库（表结构 v1/v2 相同，仅索引不同），随后降级为 v1
      final dbFresh = AppDatabase(
        NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
      );
      await dbFresh.customSelect('SELECT 1').get(); // 触发 onCreate
      await dbFresh.close();

      raw.execute('DROP INDEX IF EXISTS ux_credit_penalty_note');
      raw.execute('DROP INDEX IF EXISTS ux_daily_instance');
      raw.execute('ALTER TABLE tasks DROP COLUMN task_kind');
      raw.execute('ALTER TABLE tasks DROP COLUMN scheduled_date');
      raw.execute('ALTER TABLE tasks DROP COLUMN series_id');
      raw.execute('DROP INDEX IF EXISTS ux_daily_instance');
      raw.execute('PRAGMA user_version = 1');
      // 模拟旧版检查-插入竞态：同一日期两条重复 penalty + 另一日期一条
      raw.execute('''
        INSERT INTO credit_ledger (type, amount, ref_type, ref_id, settle_date, note, created_at_utc)
        VALUES
          ('penalty', -10, NULL, NULL, '2026-10-17', 'penalty:2026-10-16', 1760600000),
          ('penalty', -10, NULL, NULL, '2026-10-17', 'penalty:2026-10-16', 1760600001),
          ('penalty',  -8, NULL, NULL, '2026-10-18', 'penalty:2026-10-17', 1760600002)
      ''');

      // 第二步：重新打开 → 触发 onUpgrade（去重 + 建索引），不得抛错
      final dbUpgraded = AppDatabase(
        NativeDatabase.opened(raw, closeUnderlyingOnClose: true),
      );
      await expectLater(dbUpgraded.customSelect('SELECT 1').get(), completes);

      // 重复组保留 MIN(id)：2 个日期各剩 1 条
      final count = await dbUpgraded
          .customSelect(
            "SELECT COUNT(*) AS c FROM credit_ledger WHERE type='penalty'",
          )
          .getSingle();
      expect(count.read<int>('c'), 2);

      final idx = await dbUpgraded
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='index' AND name='ux_credit_penalty_note'",
          )
          .get();
      expect(idx, isNotEmpty);

      // 升级后应用层迁移也能正常跑
      await expectLater(DataMigrations.run(dbUpgraded), completes);

      await dbUpgraded.close();
      raw.close();
    });

    test('升级后：同日重复 penalty 无法再次插入（唯一索引兜底）', () async {
      final raw = sqlite3.openInMemory();
      final dbFresh = AppDatabase(
        NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
      );
      await dbFresh.customSelect('SELECT 1').get();
      await dbFresh.close();
      raw.execute('DROP INDEX IF EXISTS ux_credit_penalty_note');
      raw.execute('DROP INDEX IF EXISTS ux_daily_instance');
      raw.execute('ALTER TABLE tasks DROP COLUMN task_kind');
      raw.execute('ALTER TABLE tasks DROP COLUMN scheduled_date');
      raw.execute('ALTER TABLE tasks DROP COLUMN series_id');
      raw.execute('DROP INDEX IF EXISTS ux_daily_instance');
      raw.execute('PRAGMA user_version = 1');

      final dbUpgraded = AppDatabase(
        NativeDatabase.opened(raw, closeUnderlyingOnClose: true),
      );
      await dbUpgraded.customSelect('SELECT 1').get(); // 完成升级

      raw.execute('''
        INSERT INTO credit_ledger (type, amount, ref_type, ref_id, settle_date, note, created_at_utc)
        VALUES ('penalty', -10, NULL, NULL, '2026-10-17', 'penalty:2026-10-16', 1760600000)
      ''');
      expect(
        () => raw.execute('''
          INSERT INTO credit_ledger (type, amount, ref_type, ref_id, settle_date, note, created_at_utc)
          VALUES ('penalty', -10, NULL, NULL, '2026-10-17', 'penalty:2026-10-16', 1760600001)
        '''),
        throwsA(isA<SqliteException>()),
      );
      // 非 penalty 流水不受部分索引约束
      expect(
        () => raw.execute('''
          INSERT INTO credit_ledger (type, amount, ref_type, ref_id, settle_date, note, created_at_utc)
          VALUES ('earn', 25, NULL, NULL, '2026-10-17', 'complete', 1760600002),
                 ('earn', 25, NULL, NULL, '2026-10-17', 'complete', 1760600003)
        '''),
        returnsNormally,
      );

      await dbUpgraded.close();
      raw.close();
    });
  });
}
