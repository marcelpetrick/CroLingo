import 'package:crolingo/core/theme/app_palette.dart';
import 'package:crolingo/domain/settings/app_theme_variant.dart';
import 'package:flutter/material.dart';

/// CroLingo Material themes, one per selectable appearance.
abstract final class AppTheme {
  /// Original Adriatic appearance.
  ///
  /// The correct-answer green is darker than the first release palette so the
  /// feedback icon clears the 3:1 contrast floor against its own surface.
  static const adriatic = AppPalette(
    primary: Color(0xFF1769D2),
    primaryPressed: Color(0xFF1052A8),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFFE53935),
    crown: Color(0xFFF4B942),
    background: Color(0xFFF5F8FC),
    surface: Color(0xFFFFFFFF),
    selectedSurface: Color(0xFFE8F1FC),
    charcoal: Color(0xFF26343D),
    slate: Color(0xFF536475),
    border: Color(0xFFD9E2EC),
    success: Color(0xFF187A43),
    error: Color(0xFFC92A35),
    successSurface: Color(0xFFE6F6ED),
    errorSurface: Color(0xFFFCEAEC),
    mascotEye: Color(0xFFFFFFFF),
  );

  /// Neon violet night appearance.
  static const neonViolet = AppPalette(
    primary: Color(0xFF7C3AED),
    primaryPressed: Color(0xFF5B21B6),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFFEC4899),
    crown: Color(0xFFFBBF24),
    background: Color(0xFF12101E),
    surface: Color(0xFF1E1B33),
    selectedSurface: Color(0xFF2E2A4D),
    charcoal: Color(0xFFF2EEFF),
    slate: Color(0xFFBCB4DC),
    border: Color(0xFF403A66),
    success: Color(0xFF34D399),
    error: Color(0xFFFB7185),
    successSurface: Color(0xFF123027),
    errorSurface: Color(0xFF3B1220),
    mascotEye: Color(0xFF12101E),
  );

  /// Deep black appearance for OLED displays.
  ///
  /// The pressed state is lighter than the resting state, which is the
  /// convention for raised surfaces on a dark background.
  static const midnight = AppPalette(
    primary: Color(0xFF4C8DFF),
    primaryPressed: Color(0xFF6BA5FF),
    onPrimary: Color(0xFF04121F),
    accent: Color(0xFFFF6B6B),
    crown: Color(0xFFF4B942),
    background: Color(0xFF000000),
    surface: Color(0xFF121212),
    selectedSurface: Color(0xFF1F2733),
    charcoal: Color(0xFFF5F7FA),
    slate: Color(0xFFB7C0CC),
    border: Color(0xFF333B45),
    success: Color(0xFF4ADE80),
    error: Color(0xFFFF7A85),
    successSurface: Color(0xFF0E2A18),
    errorSurface: Color(0xFF2E1114),
    mascotEye: Color(0xFF000000),
  );

  /// Soft mint appearance.
  static const mint = AppPalette(
    primary: Color(0xFF0F7A5A),
    primaryPressed: Color(0xFF0A5A42),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFFC2410C),
    crown: Color(0xFFB7791F),
    background: Color(0xFFF1FAF5),
    surface: Color(0xFFFFFFFF),
    selectedSurface: Color(0xFFDCF3E6),
    charcoal: Color(0xFF12312A),
    slate: Color(0xFF4A6B60),
    border: Color(0xFFC2E2D2),
    success: Color(0xFF0E5C2B),
    error: Color(0xFFB91C1C),
    successSurface: Color(0xFFDFF3E6),
    errorSurface: Color(0xFFFBE6E6),
    mascotEye: Color(0xFFFFFFFF),
  );

  /// Maximum-contrast appearance for low vision.
  static const highContrast = AppPalette(
    primary: Color(0xFF00409E),
    primaryPressed: Color(0xFF002C6D),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFF9A0000),
    crown: Color(0xFF6B4E00),
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    selectedSurface: Color(0xFFE8EEF9),
    charcoal: Color(0xFF000000),
    slate: Color(0xFF1A1A1A),
    border: Color(0xFF000000),
    success: Color(0xFF005B2F),
    error: Color(0xFF9A0000),
    successSurface: Color(0xFFE2F2E8),
    errorSurface: Color(0xFFFBE7E7),
    mascotEye: Color(0xFFFFFFFF),
  );

  /// Palette backing one selectable appearance.
  static AppPalette paletteFor(AppThemeVariant variant) => switch (variant) {
    AppThemeVariant.adriatic => adriatic,
    AppThemeVariant.neonViolet => neonViolet,
    AppThemeVariant.midnight => midnight,
    AppThemeVariant.mint => mint,
    AppThemeVariant.highContrast => highContrast,
  };

  /// Builds the Material theme for one appearance.
  static ThemeData themeFor(AppThemeVariant variant) {
    final palette = paletteFor(variant);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: palette.primary,
          brightness: palette.isDark ? Brightness.dark : Brightness.light,
        ).copyWith(
          primary: palette.primary,
          onPrimary: palette.onPrimary,
          error: palette.error,
          surface: palette.surface,
          onSurface: palette.charcoal,
          outline: palette.border,
        );
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: palette.background,
      useMaterial3: true,
      extensions: [palette],
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: palette.charcoal,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
        headlineMedium: TextStyle(
          color: palette.charcoal,
          fontSize: 26,
          fontWeight: FontWeight.w700,
          height: 1.15,
        ),
        titleLarge: TextStyle(
          color: palette.charcoal,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: palette.charcoal,
          fontSize: 17,
          height: 1.4,
        ),
        bodyMedium: TextStyle(color: palette.slate, fontSize: 15, height: 1.4),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: palette.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        elevation: 0,
        height: 72,
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// Reads the active palette from the widget tree.
extension AppPaletteContext on BuildContext {
  /// Active CroLingo palette.
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppTheme.adriatic;
}
