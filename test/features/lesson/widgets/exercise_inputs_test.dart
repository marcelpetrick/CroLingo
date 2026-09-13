import 'dart:async';

import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/features/lesson/widgets/exercise_answer.dart';
import 'package:crolingo/features/lesson/widgets/lesson_header.dart';
import 'package:crolingo/features/lesson/widgets/sentence_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _sentence = Exercise(
  id: 'sentence',
  type: ExerciseType.sentence,
  masteryDimension: MasteryDimension.sentenceProduction,
  prompt: 'Baue: Guten Tag!',
  acceptedAnswers: ['Dobar dan!'],
  explanation: 'Dobar steht vor dan.',
  conceptIds: ['dobar-dan'],
  pairs: [],
  tiles: ['Dobar', 'dan!'],
);

const _sentenceWithDuplicates = Exercise(
  id: 'sentence-duplicates',
  type: ExerciseType.sentence,
  masteryDimension: MasteryDimension.sentenceProduction,
  prompt: 'Baue: Sie nennt sich.',
  acceptedAnswers: ['se zove se'],
  explanation: 'Both reflexive pronouns are required.',
  conceptIds: ['reflexive-pronoun'],
  pairs: [],
  tiles: ['se', 'zove', 'se'],
);

void main() {
  testWidgets('takes a tile back out of the sentence', (tester) async {
    final reported = <ExerciseAnswer>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SentenceInput(
            exercise: _sentence,
            enabled: true,
            onChanged: reported.add,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Dobar'));
    await tester.pump();
    await tester.tap(find.text('dan!'));
    await tester.pump();
    expect(reported.last.value, 'Dobar dan!');
    expect(reported.last.canSubmit, isTrue);

    // Tapping a chosen tile returns it to the pool.
    await tester.tap(find.widgetWithText(ActionChip, 'Dobar').first);
    await tester.pump();

    expect(reported.last.value, 'dan!');
  });

  testWidgets('keeps duplicate sentence tiles independently selectable', (
    tester,
  ) async {
    final reported = <ExerciseAnswer>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SentenceInput(
            exercise: _sentenceWithDuplicates,
            enabled: true,
            onChanged: reported.add,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('availableTile-0')));
    await tester.pump();
    expect(find.byKey(const ValueKey('availableTile-2')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('availableTile-1')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('availableTile-2')));
    await tester.pump();
    expect(reported.last.value, 'se zove se');

    await tester.tap(find.byKey(const ValueKey('selectedTile-0')));
    await tester.pump();
    expect(reported.last.value, 'zove se');
    expect(find.byKey(const ValueKey('availableTile-0')), findsOneWidget);
  });

  testWidgets('closes the lesson from the header', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('path')),
        ),
        GoRoute(
          path: '/lesson',
          builder: (context, state) =>
              const Scaffold(body: LessonHeader(progress: 0.5, xp: 12)),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    unawaited(router.push<void>('/lesson'));
    await tester.pumpAndSettle();

    expect(find.text('12 XP'), findsOneWidget);

    await tester.tap(find.byTooltip('Lektion schließen'));
    await tester.pumpAndSettle();

    expect(find.text('path'), findsOneWidget);
  });
}
