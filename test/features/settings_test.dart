import 'package:analytics_tracker/core/settings/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_server.dart';
import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('theme defaults to the system setting', () async {
    final container = await makeContainer(FakeServer());
    expect(container.read(themeModeProvider), ThemeMode.system);
  });

  test('theme choice is saved and read back on the next launch', () async {
    final first = await makeContainer(FakeServer());
    await first.read(themeModeProvider.notifier).set(ThemeMode.dark);
    expect(first.read(sharedPreferencesProvider).getString('settings.theme_mode'), 'dark');

    final relaunch = await makeContainer(FakeServer(), preferences: {'settings.theme_mode': 'dark'});
    expect(relaunch.read(themeModeProvider), ThemeMode.dark);
  });

  test('language: null follows the phone; a choice is saved; choosing system removes it', () async {
    final container = await makeContainer(FakeServer());
    expect(container.read(localeProvider), isNull);

    await container.read(localeProvider.notifier).set(const Locale('hi'));
    expect(container.read(localeProvider), const Locale('hi'));
    expect(container.read(sharedPreferencesProvider).getString('settings.locale'), 'hi');

    await container.read(localeProvider.notifier).set(null);
    expect(container.read(localeProvider), isNull);
    expect(container.read(sharedPreferencesProvider).containsKey('settings.locale'), isFalse);
  });

  test('an unknown saved value falls back safely', () async {
    final container = await makeContainer(
      FakeServer(),
      preferences: {'settings.theme_mode': 'purple', 'settings.locale': 'xx'},
    );
    expect(container.read(themeModeProvider), ThemeMode.system);
    expect(container.read(localeProvider), isNull);
  });
}
