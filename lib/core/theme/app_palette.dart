import 'package:flutter/material.dart';

/// Colour tokens for one CroLingo appearance.
///
/// Every pair a learner reads was checked against WCAG contrast ratios. Text
/// pairs clear AA 4.5:1, icons and borders clear 3:1, and the high-contrast
/// appearance clears AAA 7:1 throughout.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  /// Creates a palette.
  const new({
    required this.primary,
    required this.primaryPressed,
    required this.onPrimary,
    required this.accent,
    required this.crown,
    required this.background,
    required this.surface,
    required this.selectedSurface,
    required this.charcoal,
    required this.slate,
    required this.border,
    required this.success,
    required this.error,
    required this.successSurface,
    required this.errorSurface,
    required this.mascotEye,
  });

  /// Main interactive colour.
  final Color primary;

  /// Pressed or depressed variant of [primary].
  final Color primaryPressed;

  /// Readable ink on [primary] and [primaryPressed].
  final Color onPrimary;

  /// Secondary cultural accent.
  final Color accent;

  /// Reward and crown colour.
  final Color crown;

  /// Screen background behind all surfaces.
  final Color background;

  /// Card and sheet surface.
  final Color surface;

  /// Highlighted informational surface.
  final Color selectedSurface;

  /// Primary text and mascot ink.
  final Color charcoal;

  /// Secondary text.
  final Color slate;

  /// Subtle separators and outlines.
  final Color border;

  /// Correct-answer signal.
  final Color success;

  /// Incorrect-answer signal.
  final Color error;

  /// Background behind correct-answer feedback.
  final Color successSurface;

  /// Background behind incorrect-answer feedback.
  final Color errorSurface;

  /// Mascot eye, which must contrast with the mascot body.
  ///
  /// The body uses [charcoal], the primary ink, so it inverts with the
  /// appearance. The eye has to invert with it or the crow goes blank.
  final Color mascotEye;

  /// Whether this appearance expects light-on-dark rendering.
  bool get isDark =>
      ThemeData.estimateBrightnessForColor(background) == Brightness.dark;

  @override
  AppPalette copyWith({
    Color? primary,
    Color? primaryPressed,
    Color? onPrimary,
    Color? accent,
    Color? crown,
    Color? background,
    Color? surface,
    Color? selectedSurface,
    Color? charcoal,
    Color? slate,
    Color? border,
    Color? success,
    Color? error,
    Color? successSurface,
    Color? errorSurface,
    Color? mascotEye,
  }) => AppPalette(
    primary: primary ?? this.primary,
    primaryPressed: primaryPressed ?? this.primaryPressed,
    onPrimary: onPrimary ?? this.onPrimary,
    accent: accent ?? this.accent,
    crown: crown ?? this.crown,
    background: background ?? this.background,
    surface: surface ?? this.surface,
    selectedSurface: selectedSurface ?? this.selectedSurface,
    charcoal: charcoal ?? this.charcoal,
    slate: slate ?? this.slate,
    border: border ?? this.border,
    success: success ?? this.success,
    error: error ?? this.error,
    successSurface: successSurface ?? this.successSurface,
    errorSurface: errorSurface ?? this.errorSurface,
    mascotEye: mascotEye ?? this.mascotEye,
  );

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryPressed: Color.lerp(primaryPressed, other.primaryPressed, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      crown: Color.lerp(crown, other.crown, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      selectedSurface: Color.lerp(selectedSurface, other.selectedSurface, t)!,
      charcoal: Color.lerp(charcoal, other.charcoal, t)!,
      slate: Color.lerp(slate, other.slate, t)!,
      border: Color.lerp(border, other.border, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      successSurface: Color.lerp(successSurface, other.successSurface, t)!,
      errorSurface: Color.lerp(errorSurface, other.errorSurface, t)!,
      mascotEye: Color.lerp(mascotEye, other.mascotEye, t)!,
    );
  }
}
