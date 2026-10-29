import 'package:flutter/material.dart';

/// Design colors that Material's ColorScheme has no slot for.
/// Read with `Theme.of(context).extension<AppColors>()!` or `context.colors`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.muted,
    required this.line,
    required this.fill,
    required this.accentSoft,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.hero,
    required this.onHero,
    required this.onHeroMuted,
  });

  /// Secondary text (labels, hints).
  final Color muted;

  /// Borders and dividers.
  final Color line;

  /// Segmented controls, chips, search fields.
  final Color fill;
  final Color accentSoft;
  final Color success;
  final Color successSoft;
  final Color warning;
  final Color warningSoft;

  /// The dark brand panel on the sign-in screens.
  final Color hero;
  final Color onHero;
  final Color onHeroMuted;

  static const light = AppColors(
    muted: Color(0xFF586170),
    line: Color(0xFFE2E5EA),
    fill: Color(0xFFEEF0F3),
    accentSoft: Color(0xFFE6F1F1),
    success: Color(0xFF12704A),
    successSoft: Color(0xFFE6F4EC),
    warning: Color(0xFF8A4305),
    warningSoft: Color(0xFFFDF1E4),
    hero: Color(0xFF12161C),
    onHero: Color(0xFFE9ECF1),
    onHeroMuted: Color(0xFFB8C0CB),
  );

  static const dark = AppColors(
    muted: Color(0xFF98A5B2),
    line: Color(0xFF27323B),
    fill: Color(0xFF1F2830),
    accentSoft: Color(0xFF15302F),
    success: Color(0xFF6FD3A0),
    successSoft: Color(0xFF14301F),
    warning: Color(0xFFF2B36B),
    warningSoft: Color(0xFF33240F),
    hero: Color(0xFF0A0E12),
    onHero: Color(0xFFE9ECF1),
    onHeroMuted: Color(0xFFAEB6C2),
  );

  @override
  AppColors copyWith({Color? muted, Color? line}) => AppColors(
        muted: muted ?? this.muted,
        line: line ?? this.line,
        fill: fill,
        accentSoft: accentSoft,
        success: success,
        successSoft: successSoft,
        warning: warning,
        warningSoft: warningSoft,
        hero: hero,
        onHero: onHero,
        onHeroMuted: onHeroMuted,
      );

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      muted: mix(muted, other.muted),
      line: mix(line, other.line),
      fill: mix(fill, other.fill),
      accentSoft: mix(accentSoft, other.accentSoft),
      success: mix(success, other.success),
      successSoft: mix(successSoft, other.successSoft),
      warning: mix(warning, other.warning),
      warningSoft: mix(warningSoft, other.warningSoft),
      hero: mix(hero, other.hero),
      onHero: mix(onHero, other.onHero),
      onHeroMuted: mix(onHeroMuted, other.onHeroMuted),
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
