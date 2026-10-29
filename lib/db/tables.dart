import 'package:drift/drift.dart';

/// 数据表定义（v3.2 §6，锁定 schema + 实现细节列）
///
/// 实现细节补充（不改变锁定规则，为支持「撤销完成删除已生成实例」）：
/// - tasks.parent_task_id：循环任务自动生成的实例记录其父实例 id，撤销时据此删除。

class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get course => text().withDefault(const Constant(''))();
  TextColumn get note => text().withDefault(const Constant(''))();

  /// assignment / exam / self
  TextColumn get type => text().withDefault(const Constant('self'))();

  /// legacy preserves existing tasks until the user explicitly classifies them.
  TextColumn get taskKind => text().withDefault(const Constant('legacy'))();
  TextColumn get scheduledDate => text().nullable()();
  TextColumn get seriesId => text().nullable()();

  /// high / medium / low
  TextColumn get priority => text().withDefault(const Constant('medium'))();

  /// UTC，精度到分钟
  DateTimeColumn get deadlineUtc => dateTime()();

  /// JSON 数组字符串，如 [1440,180]
  TextColumn get remindMinutes => text().withDefault(const Constant('[]'))();

  /// 手动权重覆盖；NULL 表示按公式
  RealColumn get weightOverride => real().nullable()();

  /// todo / done / overdue / cancelled
  TextColumn get status => text().withDefault(const Constant('todo'))();

  /// manual / recurring
  TextColumn get source => text().withDefault(const Constant('manual'))();

  /// 同步预留（阶段 2 用）
  TextColumn get deviceId => text().withDefault(const Constant('windows'))();
  DateTimeColumn get createdAtUtc => dateTime()();
  DateTimeColumn get updatedAtUtc => dateTime()();
  DateTimeColumn get completedAtUtc => dateTime().nullable()();

  /// 每 N 天/周/月：`every:N:unit`；NULL=不重复
  TextColumn get repeatRule => text().nullable()();

  /// 循环结束日期；NULL=永不结束
  DateTimeColumn get repeatEndUtc => dateTime().nullable()();

  /// 实现细节：自动生成的循环实例记录父实例 id（撤销完成时删除）
  TextColumn get parentTaskId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Subtasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get taskId => text().references(Tasks, #id)();
  TextColumn get title => text()();
  IntColumn get estMinutes => integer().nullable()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// 统一积分流水（v3.2：取代 v3 的 credits 表）
class CreditLedger extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()(); // earn / redeem / penalty / adjust
  RealColumn get amount =>
      real()(); // earn 正 / redeem 负 / penalty 负 / adjust 可正可负
  TextColumn get refType => text().nullable()(); // task / reward / null
  TextColumn get refId => text().nullable()();
  TextColumn get settleDate => text()(); // 本地日期 YYYY-MM-DD
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAtUtc => dateTime()();
}

class Rewards extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get cost => real()();
  BoolColumn get repeatable => boolean().withDefault(const Constant(false))();
  IntColumn get redeemedCount => integer().withDefault(const Constant(0))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAtUtc => dateTime()();
}

class RewardLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get ledgerId => integer().references(CreditLedger, #id)();
  IntColumn get rewardId => integer().references(Rewards, #id)();
  RealColumn get cost => real()();
  DateTimeColumn get redeemedAtUtc => dateTime()();
}

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column> get primaryKey => {key};
}

/// AI 解析缓存（仅 F11 按日缓存，阶段 2 使用）
class AiCache extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get cacheKey => text().unique()();
  TextColumn get feature => text()();
  TextColumn get resultJson => text()();
  DateTimeColumn get createdAtUtc => dateTime()();
}
