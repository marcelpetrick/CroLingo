import 'dart:math' as math;

import 'package:crolingo/core/theme/app_palette.dart';
import 'package:crolingo/core/theme/app_theme.dart';
import 'package:crolingo/domain/settings/app_theme_variant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Relative luminance from WCAG 2.1.
double _luminance(Color color) {
  double channel(double value) => value <= 0.04045
      ? value / 12.92
      : math.pow((value + 0.055) / 1.055, 2.4) as double;
  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

double _contrast(Color a, Color b) {
  final first = _luminance(a);
  final second = _luminance(b);
  final lighter = math.max(first, second);
  final darker = math.min(first, second);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('every appearance stays readable', () {
    // Text pairs must clear WCAG AA. The high-contrast appearance exists for
    // low vision, so it is held to AAA instead.
    for (final variant in AppThemeVariant.values) {
      test(variant.name, () {
        final palette = AppTheme.paletteFor(variant);
        final textFloor = variant == AppThemeVariant.highContrast ? 7.0 : 4.5;
        final iconFloor = variant == AppThemeVariant.highContrast ? 7.0 : 3.0;

        void check(String label, Color fg, Color bg, double floor) {
          expect(
            _contrast(fg, bg),
            greaterThanOrEqualTo(floor),
            reason: '${variant.name}: $label needs $floor:1',
          );
        }

        check(
          'body on background',
          palette.charcoal,
          palette.background,
          textFloor,
        );
        check('body on surface', palette.charcoal, palette.surface, textFloor);
        check(
          'secondary on background',
          palette.slate,
          palette.background,
          textFloor,
        );
        check(
          'secondary on surface',
          palette.slate,
          palette.surface,
          textFloor,
        );
        check(
          'body on selected surface',
          palette.charcoal,
          palette.selectedSurface,
          textFloor,
        );
        check('ink on primary', palette.onPrimary, palette.primary, textFloor);
        check(
          'ink on pressed primary',
          palette.onPrimary,
          palette.primaryPressed,
          textFloor,
        );
        check(
          'correct icon on its surface',
          palette.success,
          palette.successSurface,
          iconFloor,
        );
        check(
          'incorrect icon on its surface',
          palette.error,
          palette.errorSurface,
          iconFloor,
        );
        check(
          'primary icon on selected surface',
          palette.primary,
          palette.selectedSurface,
          iconFloor,
        );
        check(
          'accent icon on surface',
          palette.accent,
          palette.surface,
          iconFloor,
        );
        check(
          'text on correct feedback',
          palette.charcoal,
          palette.successSurface,
          textFloor,
        );
        check(
          'text on incorrect feedback',
          palette.charcoal,
          palette.errorSurface,
          textFloor,
        );
        check(
          'mascot eye on mascot body',
          palette.mascotEye,
          palette.charcoal,
          iconFloor,
        );
      });
    }
  });

  test('each variant maps to a distinct palette', () {
    final backgrounds = {
      for (final variant in AppThemeVariant.values)
        AppTheme.paletteFor(variant).background,
    };

    expect(backgrounds.length, AppThemeVariant.values.length);
  });

  test('the theme carries its palette as an extension', () {
    for (final variant in AppThemeVariant.values) {
      final theme = AppTheme.themeFor(variant);

      expect(
        theme.extension<AppPalette>(),
        same(AppTheme.paletteFor(variant)),
        reason: '${variant.name} must expose its palette to widgets',
      );
      expect(
        theme.scaffoldBackgroundColor,
        AppTheme.paletteFor(variant).background,
      );
    }
  });

  testWidgets('context.palette reads the active appearance', (tester) async {
    late AppPalette seen;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.themeFor(AppThemeVariant.midnight),
        home: Builder(
          builder: (context) {
            seen = context.palette;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(seen, same(AppTheme.midnight));
  });

  testWidgets('context.palette falls back when no theme supplies one', (
    tester,
  ) async {
    late AppPalette seen;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: Builder(
          builder: (context) {
            seen = context.palette;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(seen, same(AppTheme.adriatic));
  });

  test('a palette can be copied and interpolated', () {
    const base = AppTheme.adriatic;
    final recoloured = base.copyWith(primary: const Color(0xFF123456));

    expect(recoloured.primary, const Color(0xFF123456));
    expect(recoloured.crown, base.crown);
    expect(base.lerp(null, 0.5), same(base));
    expect(
      base.lerp(AppTheme.midnight, 1).background,
      AppTheme.midnight.background,
    );
  });

  test('dark appearances report themselves as dark', () {
    expect(AppTheme.midnight.isDark, isTrue);
    expect(AppTheme.neonViolet.isDark, isTrue);
    expect(AppTheme.adriatic.isDark, isFalse);
    expect(AppTheme.mint.isDark, isFalse);
    expect(AppTheme.highContrast.isDark, isFalse);
  });
}
