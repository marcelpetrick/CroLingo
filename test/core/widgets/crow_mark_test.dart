import 'package:crolingo/core/theme/app_theme.dart';
import 'package:crolingo/core/widgets/crow_mark.dart';
import 'package:crolingo/domain/settings/app_theme_variant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpUnder(WidgetTester tester, AppThemeVariant variant) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.themeFor(variant),
        home: const Scaffold(body: CrowMark(size: 58)),
      ),
    );
    // MaterialApp animates a theme change, so the palette only reaches its
    // final values once that animation has finished.
    await tester.pumpAndSettle();
  }

  CustomPaint findPaint(WidgetTester tester) => tester.widget<CustomPaint>(
    find.descendant(
      of: find.byType(CrowMark),
      matching: find.byType(CustomPaint),
    ),
  );

  testWidgets('announces itself to a screen reader', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpUnder(tester, AppThemeVariant.adriatic);

    expect(find.bySemanticsLabel('Freundliche CroLingo-Krähe'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('takes its colours from the active appearance', (tester) async {
    await pumpUnder(tester, AppThemeVariant.adriatic);
    final light = findPaint(tester).painter;

    await pumpUnder(tester, AppThemeVariant.midnight);
    final dark = findPaint(tester).painter;

    expect(
      dark!.shouldRepaint(light!),
      isTrue,
      reason: 'switching appearance must redraw the mascot',
    );
  });

  testWidgets('does not redraw when the appearance is unchanged', (
    tester,
  ) async {
    await pumpUnder(tester, AppThemeVariant.mint);
    final first = findPaint(tester).painter;

    await tester.pumpWidget(const SizedBox.shrink());
    await pumpUnder(tester, AppThemeVariant.mint);
    final second = findPaint(tester).painter;

    expect(second!.shouldRepaint(first!), isFalse);
  });

  testWidgets('defaults to its full size', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.themeFor(AppThemeVariant.adriatic),
        home: const Scaffold(body: CrowMark()),
      ),
    );

    expect(findPaint(tester).size, const Size.square(72));
  });
}
