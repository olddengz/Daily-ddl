import 'dart:io';

/// 数据落地位置（v3.2 §8，锁定）：
/// 数据目录 = 可执行文件同级 `data\`（含 db.sqlite 与 backups\）。
/// 不写 AppData、不写 Program Files、不占 C 盘（随绿色包文件夹走）。
///
/// 测试可注入 [overridePath] 避免触碰真实目录。
class DataLocator {
  static String? overridePath;

  static String resolve() {
    if (overridePath != null) return overridePath!;
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    return '$exeDir${Platform.pathSeparator}data';
  }

  /// 确保数据目录存在并返回其路径。
  static String ensure() {
    final dir = resolve();
    Directory(dir).createSync(recursive: true);
    return dir;
  }
}
