import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers.dart';
import 'core/settings/settings_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env'); // API_BASE_URL and timeouts
  final preferences = await SharedPreferences.getInstance(); // theme and language

  runApp(
    ProviderScope(
      retry: retryPolicy,
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: const AnalyticsTrackerApp(),
    ),
  );
}
