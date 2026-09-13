import 'package:crolingo/core/theme/app_theme.dart';
import 'package:crolingo/domain/settings/app_theme_variant.dart';
import 'package:crolingo/features/lesson/widgets/lesson_celebration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('stages the mascot, XP, and action into the win moment', (
    tester,
  ) async {
    await tester.pumpWidget(_preview(xp: 42));

    expect(find.text('+0 XP'), findsOneWidget);
    expect(find.text('Lektion geschafft!'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 450));
    expect(find.text('+0 XP'), findsNothing);
    expect(find.text('+42 XP'), findsNothing);

    await tester.pumpAndSettle();
    expect(find.text('+42 XP'), findsOneWidget);
    expect(find.text('Zum Lernweg'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the final state immediately when motion is reduced', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_preview(xp: 36, reduceMotion: true));

    expect(find.text('+36 XP'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Lektion geschafft. 36 XP verdient.'),
      findsOneWidget,
    );
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNotNull);
    semantics.dispose();
  });

  testWidgets('remains usable with narrow 200 percent text', (tester) async {
    tester.view
      ..physicalSize = const Size(320, 800)
      ..devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(() {
      tester.view.reset();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await tester.pumpWidget(_preview(xp: 48));
    await tester.pumpAndSettle();

    expect(find.text('Lektion geschafft!'), findsOneWidget);
    expect(find.text('Zum Lernweg'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _preview({required int xp, bool reduceMotion = false}) => MaterialApp(
  theme: AppTheme.themeFor(AppThemeVariant.adriatic),
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Scaffold(
      body: LessonCelebration(
        lessonTitle: 'Begrüßen & Vorstellen',
        xp: xp,
        actionLabel: 'Zum Lernweg',
        onContinue: _doNothing,
      ),
    ),
  ),
);

void _doNothing() {}
