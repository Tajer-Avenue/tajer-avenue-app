import 'package:flutter/material.dart';

import 'core/brand.dart';
import 'core/theme.dart';
import 'features/app_shell.dart';

class TajerAvenueApp extends StatelessWidget {
  const TajerAvenueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Brand.name,
      theme: buildAppTheme(),
      home: const AppShell(),
    );
  }
}
