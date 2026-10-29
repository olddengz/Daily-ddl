import 'database.dart';

/// 设置存取（settings 表，key/value 字符串）
class SettingsDao {
  SettingsDao(this.db);

  final AppDatabase db;

  Future<String?> get(String key) async {
    final row = await (db.select(db.settings)..where((s) => s.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> set(String key, String value) async {
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(key: key, value: value),
        );
  }

  Future<bool> getBool(String key, {bool fallback = false}) async {
    final v = await get(key);
    if (v == null) return fallback;
    return v == 'true' || v == '1';
  }

  Future<double> getDouble(String key, {double fallback = 0}) async {
    final v = await get(key);
    return double.tryParse(v ?? '') ?? fallback;
  }
}
