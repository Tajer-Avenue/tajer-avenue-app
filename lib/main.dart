import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final launchUri = Uri.base;
  final isAuthCallback =
      launchUri.queryParameters.containsKey('code') ||
      launchUri.queryParameters['type'] == 'signup' ||
      launchUri.fragment.contains('access_token=') ||
      launchUri.fragment.contains('type=signup');

  await Supabase.initialize(
    url: 'https://buwzeaayopsfjgsbwefs.supabase.co',
    anonKey: 'sb_publishable_-ZYKLjxGt52JuhbMP7buqg_wF9_LaWZ',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit,
    ),
  );

  runApp(TajerAvenueApp(openAccountOnLaunch: isAuthCallback));
}
