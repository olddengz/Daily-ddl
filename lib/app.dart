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
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff5265a8))
          .copyWith(
            primary: const Color(0xff5265a8),
            surface: Colors.white,
            onSurface: const Color(0xff252b3a),
            onSurfaceVariant: const Color(0xff737b8d),
            outlineVariant: const Color(0xffe9ecf2),
          ),
      scaffoldBackgroundColor: const Color(0xfff6f7fb),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xffe9ecf2),
        thickness: 1,
        space: 1,
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(height: 1.5),
        titleMedium: TextStyle(fontSize: 16, height: 1.5),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xffd8dce6)),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        isDense: true,
      ),
    ),
    home: HomePage(db: db),
  );
}
