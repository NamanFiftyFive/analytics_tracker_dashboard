import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/generated/app_localizations.dart';

/// Numbers, dates and durations in the app's current language.
class Formatters {
  Formatters(this._l10n, this._locale, {DateTime? now}) : _now = now ?? DateTime.now();

  factory Formatters.of(BuildContext context) =>
      Formatters(AppLocalizations.of(context), Localizations.localeOf(context).toLanguageTag());

  final AppLocalizations _l10n;
  final String _locale;
  final DateTime _now;

  /// 1520 → "1,520" (Hindi uses its own grouping).
  String number(num value) => NumberFormat.decimalPattern(_locale).format(value.round());

  /// 754 → "12m 34s".
  String duration(num seconds) {
    final total = seconds.round();
    return _l10n.durationMinSec(total ~/ 60, total % 60);
  }

  /// 12.5 → "↑ 12.5%", -3 → "↓ 3%".
  String change(double percent) {
    final text = NumberFormat('0.#', _locale).format(percent.abs());
    return percent >= 0 ? _l10n.changeUp(text) : _l10n.changeDown(text);
  }

  /// "10:16"
  String time(DateTime value) => DateFormat.Hm(_locale).format(value);

  /// "Today", "Yesterday" or "20 Oct 2026": for list section headers.
  String dayHeader(DateTime value) {
    final day = DateUtils.dateOnly(value);
    final today = DateUtils.dateOnly(_now);
    if (day == today) return _l10n.todayLabel;
    if (day == today.subtract(const Duration(days: 1))) return _l10n.yesterdayLabel;
    return DateFormat.yMMMd(_locale).format(value);
  }

  /// "20 Oct, 10:16"
  String dateTime(DateTime value) => '${DateFormat.MMMd(_locale).format(value)}, ${time(value)}';

  /// "just now", "5 min ago", "3 h ago", or a date.
  String relative(DateTime value) {
    final diff = _now.difference(value);
    if (diff.inMinutes < 1) return _l10n.justNow;
    if (diff.inMinutes < 60) return _l10n.minutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return _l10n.hoursAgo(diff.inHours);
    return dayHeader(value);
  }

  /// Short weekday for chart labels: "Mon".
  String weekday(DateTime value) => DateFormat.E(_locale).format(value);

  /// Short date for chart labels: "16 Oct".
  String shortDate(DateTime value) => DateFormat.MMMd(_locale).format(value);
}
