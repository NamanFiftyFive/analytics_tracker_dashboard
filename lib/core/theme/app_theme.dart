import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Light and dark themes from the dashboard design (dark ink, teal accent).
abstract final class AppTheme {
  static ThemeData get light => _build(
        brightness: Brightness.light,
        accent: const Color(0xFF0E6B70),
        onAccent: Colors.white,
        ground: const Color(0xFFF5F6F8),
        surface: Colors.white,
        ink: const Color(0xFF12161C),
        inputBorder: const Color(0xFFCDD2D9),
        error: const Color(0xFFB42318),
        colors: AppColors.light,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        accent: const Color(0xFF5CC4C8),
        onAccent: const Color(0xFF06292B),
        ground: const Color(0xFF0F1418),
        surface: const Color(0xFF161D23),
        ink: const Color(0xFFE4E9EE),
        inputBorder: const Color(0xFF34404B),
        error: const Color(0xFFFF8A80),
        colors: AppColors.dark,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color accent,
    required Color onAccent,
    required Color ground,
    required Color surface,
    required Color ink,
    required Color inputBorder,
    required Color error,
    required AppColors colors,
  }) {
    final scheme = ColorScheme.fromSeed(seedColor: accent, brightness: brightness).copyWith(
      primary: accent,
      onPrimary: onAccent,
      surface: surface,
      onSurface: ink,
      onSurfaceVariant: colors.muted,
      outline: inputBorder,
      outlineVariant: colors.line,
      error: error,
    );
    final radius12 = BorderRadius.circular(12);
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: color, width: width));

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: ground,
      extensions: [colors],
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: ink),
      ),
      textTheme: Typography.material2021(platform: TargetPlatform.android).black.apply(
            bodyColor: ink,
            displayColor: ink,
          ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: TextStyle(color: colors.muted),
        border: border(inputBorder),
        enabledBorder: border(inputBorder),
        focusedBorder: border(accent, 2),
        errorBorder: border(error),
        focusedErrorBorder: border(error, 2),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: radius12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: radius12),
          side: BorderSide(color: inputBorder),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: colors.line)),
      ),
      dividerTheme: DividerThemeData(color: colors.line, space: 1, thickness: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: colors.accentSoft,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected) ? accent : colors.muted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(color: states.contains(WidgetState.selected) ? accent : colors.muted),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: colors.accentSoft,
          selectedForegroundColor: brightness == Brightness.light ? const Color(0xFF0A5256) : accent,
          side: BorderSide(color: colors.line),
        ),
      ),
    );
  }
}
