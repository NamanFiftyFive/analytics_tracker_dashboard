import 'package:analytics_tracker/core/format/formatters.dart';
import 'package:analytics_tracker/l10n/generated/app_localizations_en.dart';
import 'package:analytics_tracker/l10n/generated/app_localizations_hi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  final now = DateTime(2026, 10, 22, 15, 30);
  final en = Formatters(AppLocalizationsEn(), 'en', now: now);

  setUpAll(() => initializeDateFormatting());

  test('numbers and durations', () {
    expect(en.number(7570), '7,570');
    expect(en.number(12.6), '13');
    expect(en.duration(252), '4m 12s');
    expect(en.duration(0), '0m 0s');
  });

  test('change percent with direction', () {
    expect(en.change(12.2), '↑ 12.2%');
    expect(en.change(-3), '↓ 3%');
    expect(en.change(0), '↑ 0%');
  });

  test('relative times', () {
    expect(en.relative(now.subtract(const Duration(seconds: 20))), 'just now');
    expect(en.relative(now.subtract(const Duration(minutes: 5))), '5 min ago');
    expect(en.relative(now.subtract(const Duration(hours: 3))), '3 h ago');
    expect(en.relative(now.subtract(const Duration(days: 1, hours: 2))), 'Yesterday');
  });

  test('day headers', () {
    expect(en.dayHeader(DateTime(2026, 10, 22, 9)), 'Today');
    expect(en.dayHeader(DateTime(2026, 10, 21, 23)), 'Yesterday');
    expect(en.dayHeader(DateTime(2026, 10, 2)), 'Oct 2, 2026');
  });

  test('Hindi texts', () {
    final hi = Formatters(AppLocalizationsHi(), 'hi', now: now);
    expect(hi.relative(now.subtract(const Duration(minutes: 5))), '5 मिनट पहले');
    expect(hi.dayHeader(DateTime(2026, 10, 22)), 'आज');
    expect(hi.duration(252), '4 मि 12 से');
  });
}
