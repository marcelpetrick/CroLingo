import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/features/lesson/lesson_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('completes all four text exercise families with feedback', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(412, 915)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(home: LessonScreen(lessonId: 'begrussen')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Was gehört zusammen?'), findsOneWidget);

    await _choose(tester, 0, 'Hallo!');
    await _choose(tester, 1, 'Guten Tag!');
    await _pressButton(tester, 'Prüfen');
    expect(find.text('Richtig!'), findsOneWidget);
    await _pressButton(tester, 'Weiter');

    await tester.enterText(find.byKey(const Key('answerField')), 'Falsch');
    await tester.pump();
    await _pressButton(tester, 'Prüfen');
    expect(find.text('Noch nicht richtig'), findsOneWidget);
    expect(find.text('Lösung: Dobar dan!'), findsOneWidget);
    await _pressButton(tester, 'Noch einmal');
    await tester.enterText(find.byKey(const Key('answerField')), 'Dobar dan!');
    await tester.pump();
    await _pressButton(tester, 'Prüfen');
    await _pressButton(tester, 'Weiter');

    await tester.enterText(find.byKey(const Key('answerField')), 'Bok');
    await tester.pump();
    await _pressButton(tester, 'Prüfen');
    await _pressButton(tester, 'Weiter');

    await tester.tap(find.widgetWithText(ActionChip, 'Dobar'));
    await tester.tap(find.widgetWithText(ActionChip, 'dan!'));
    await tester.pumpAndSettle();
    await _pressButton(tester, 'Prüfen');
    await _pressButton(tester, 'Weiter');

    expect(find.text('Lektion geschafft!'), findsOneWidget);
    expect(find.textContaining('48 XP'), findsOneWidget);
  });

  testWidgets('shows a safe error for an unknown lesson', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LessonScreen(
          lessonId: 'missing',
          lesson: Future<Lesson>.delayed(
            Duration.zero,
            () => throw StateError('missing'),
          ),
        ),
      ),
    );
    for (var index = 0; index < 10; index++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(
      find.text('Die Lektion konnte nicht geladen werden.'),
      findsOneWidget,
    );
  });
}

Future<void> _choose(
  WidgetTester tester,
  int dropdownIndex,
  String value,
) async {
  await tester.tap(
    find.byType(DropdownButtonFormField<String>).at(dropdownIndex),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(value).last);
  await tester.pumpAndSettle();
}

Future<void> _pressButton(WidgetTester tester, String label) async {
  final finder = find.widgetWithText(FilledButton, label);
  final button = tester.widget<FilledButton>(finder);
  expect(button.onPressed, isNotNull);
  button.onPressed!();
  await tester.pumpAndSettle();
}
