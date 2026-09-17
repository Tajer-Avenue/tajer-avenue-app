import 'package:flutter/material.dart';

import 'brand.dart';

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: Brand.ink,
    brightness: Brightness.light,
    surface: Brand.surface,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Brand.canvas,
    navigationBarTheme: const NavigationBarThemeData(
      height: 72,
      backgroundColor: Brand.surface,
      indicatorColor: Color(0xFFECE8DF),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Brand.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
