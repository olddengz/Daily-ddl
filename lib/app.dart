import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'db/database.dart';
import 'ui/home_page.dart';

class App extends StatelessWidget {
  const App({super.key, required this.db});
  final AppDatabase db;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: '每日 DDL',
    debugShowCheckedModeBanner: false,
    locale: const Locale('zh', 'CN'),
    supportedLocales: const [Locale('zh', 'CN')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'Microsoft YaHei',
      fontFamilyFallback: const ['Microsoft YaHei UI', 'SimSun', 'Segoe UI'],
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff5265a8)),
      scaffoldBackgroundColor: const Color(0xfff6f7fb),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(height: 1.5),
        titleMedium: TextStyle(fontSize: 16, height: 1.5),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        isDense: true,
      ),
    ),
    home: HomePage(db: db),
  );
}
