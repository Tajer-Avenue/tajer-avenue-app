import 'package:flutter/material.dart';

import 'brand.dart';

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: Brand.accent,
    brightness: Brightness.light,
    surface: Brand.surface,
  ).copyWith(
    primary: Brand.ink,
    onPrimary: Colors.white,
    secondary: Brand.accent,
    onSecondary: Brand.ink,
    surface: Brand.surface,
    onSurface: Brand.ink,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Brand.canvas,
    drawerTheme: const DrawerThemeData(
      backgroundColor: Brand.canvas,
      surfaceTintColor: Colors.transparent,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Brand.canvas,
      surfaceTintColor: Colors.transparent,
      foregroundColor: Brand.ink,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE1D4BC),
      thickness: 1,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      height: 72,
      backgroundColor: Brand.surface,
      indicatorColor: Color(0xFFF0D8A8),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
      ),
    ),
    radioTheme: const RadioThemeData(
      fillColor: WidgetStatePropertyAll(Brand.accent),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Brand.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE8DDC8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE8DDC8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Brand.accent, width: 1.6),
      ),
    ),
  );
}
