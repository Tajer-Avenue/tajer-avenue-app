import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://buwzeaayopsfjgsbwefs.supabase.co',
    anonKey: 'sb_publishable_-ZYKLjxGt52JuhbMP7buqg_wF9_LaWZ',
  );

  runApp(const TajerAvenueApp());
}
