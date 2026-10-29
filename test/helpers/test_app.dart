import 'package:analytics_tracker/app.dart';
import 'package:analytics_tracker/core/config/app_config.dart';
import 'package:analytics_tracker/core/providers.dart';
import 'package:analytics_tracker/core/settings/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_server.dart';

const testConfig = AppConfig(apiBaseUrl: 'http://test/api/v1');

/// A ProviderContainer wired to [server], with empty (or given) device storage.
Future<ProviderContainer> makeContainer(
  FakeServer server, {
  Map<String, String> secureStorage = const {},
  Map<String, Object> preferences = const {},
}) async {
  FlutterSecureStorage.setMockInitialValues(Map.of(secureStorage));
  SharedPreferences.setMockInitialValues(Map.of(preferences));
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    retry: retryPolicy,
    overrides: [
      appConfigProvider.overrideWithValue(testConfig),
      httpAdapterProvider.overrideWithValue(server),
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// Starts the whole app against [server] and waits until it has settled.
Future<ProviderContainer> pumpApp(
  WidgetTester tester,
  FakeServer server, {
  Map<String, String> secureStorage = const {},
  Map<String, Object> preferences = const {},
}) async {
  final container = await tester.runAsync(
    () => makeContainer(server, secureStorage: secureStorage, preferences: preferences),
  );
  await tester.pumpWidget(UncontrolledProviderScope(container: container!, child: const AnalyticsTrackerApp()));
  await tester.pumpAndSettle();
  return container;
}

/// Phone-sized test screen (the default 800x600 is landscape).
void usePhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}
