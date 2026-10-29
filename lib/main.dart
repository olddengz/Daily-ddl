import 'package:flutter/material.dart';

import 'app.dart';
import 'services/desktop_service.dart';
import 'db/database.dart';
import 'db/migrations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // v3.2 §8：数据落 exe 同级 data\，不写 C 盘
  final db = AppDatabase.open();
  // 应用层数据迁移（幂等）：修正历史格式流水，须在 UI 结算/展示之前执行
  await DataMigrations.run(db);
  await DesktopService.instance.initialize();
  runApp(App(db: db));
}
