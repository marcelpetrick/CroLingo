import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/domain/progress/progress_repository.dart';
import 'package:crolingo/features/lesson/lesson_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('completes all four text exercise families with feedback', (
    tester,
  ) async {
    final progress = _RecordingProgress();
    tester.view
      ..physicalSize = const Size(412, 915)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: LessonScreen(
          lessonId: 'begrussen',
          lesson: Future<Lesson>.value(_completeLesson),
          repository: progress,
        ),
      ),
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
    await tester.pumpAndSettle();
    expect(progress.attempts, 5);
    expect(progress.progress.single.completedAt, isNotNull);
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

  testWidgets('fits a narrow phone with 200 percent text', (tester) async {
    tester.view
      ..physicalSize = const Size(320, 800)
      ..devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(() {
      tester.view.reset();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: LessonScreen(
          lessonId: 'narrow',
          lesson: Future<Lesson>.value(_narrowLesson),
        ),
      ),
    );
    for (var index = 0; index < 10; index++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(tester.takeException(), isNull);
    expect(find.bySemanticsLabel('0 Prozent abgeschlossen'), findsOneWidget);
  });
}

const _completeLesson = Lesson(
  id: 'begrussen',
  title: 'Begrüßen',
  exercises: [
    Exercise(
      id: 'match',
      type: ExerciseType.matching,
      masteryDimension: MasteryDimension.recognition,
      prompt: 'Verbinde die Begrüßungen.',
      acceptedAnswers: ['vollständig'],
      explanation: 'Begrüßungen',
      conceptIds: ['bok', 'dobar-dan'],
      pairs: [
        WordPair(croatian: 'Bok!', german: 'Hallo!'),
        WordPair(croatian: 'Dobar dan!', german: 'Guten Tag!'),
      ],
      tiles: [],
    ),
    Exercise(
      id: 'translate',
      type: ExerciseType.translation,
      masteryDimension: MasteryDimension.germanToCroatian,
      prompt: 'Übersetze: Guten Tag!',
      acceptedAnswers: ['Dobar dan!'],
      explanation: 'Dobar dan bedeutet Guten Tag.',
      conceptIds: ['dobar-dan'],
      pairs: [],
      tiles: [],
    ),
    Exercise(
      id: 'blank',
      type: ExerciseType.fillBlank,
      masteryDimension: MasteryDimension.grammarApplication,
      prompt: 'Ergänze: ___!',
      acceptedAnswers: ['Bok'],
      explanation: 'Bok bedeutet Hallo.',
      conceptIds: ['bok'],
      pairs: [],
      tiles: [],
    ),
    Exercise(
      id: 'sentence',
      type: ExerciseType.sentence,
      masteryDimension: MasteryDimension.sentenceProduction,
      prompt: 'Baue: Guten Tag!',
      acceptedAnswers: ['Dobar dan!'],
      explanation: 'Dobar steht vor dan.',
      conceptIds: ['dobar-dan'],
      pairs: [],
      tiles: ['dan!', 'Dobar'],
    ),
  ],
);

const _narrowLesson = Lesson(
  id: 'narrow',
  title: 'Narrow',
  exercises: [
    Exercise(
      id: 'match',
      type: ExerciseType.matching,
      masteryDimension: MasteryDimension.recognition,
      prompt: 'Verbinde die Wörter.',
      acceptedAnswers: ['vollständig'],
      explanation: 'Explanation',
      conceptIds: ['one', 'two'],
      pairs: [
        WordPair(croatian: 'Dobar dan!', german: 'Guten Tag!'),
        WordPair(croatian: 'Bok!', german: 'Hallo!'),
      ],
      tiles: [],
    ),
  ],
);

class _RecordingProgress implements ProgressRepository {
  final progress = <LessonProgress>[];
  int attempts = 0;

  @override
  Future<List<DueReview>> loadDueReviews({DateTime? now}) async => [];

  @override
  Future<List<ExerciseAttempt>> loadAttemptHistory() async => [];

  @override
  Future<List<LessonProgress>> loadLessonProgress() async => progress;

  @override
  Future<LearningStats> loadStats() async => const LearningStats(
    totalXp: 0,
    completedLessons: 0,
    studyDays: 0,
    currentStreak: 0,
    longestStreak: 0,
    startedOn: null,
  );

  @override
  Future<List<RecentMistake>> loadRecentMistakes({int limit = 20}) async => [];

  @override
  Future<void> recordAttempt({
    required String lessonId,
    required String exerciseId,
    required String submittedAnswer,
    required bool correct,
    required int incorrectBefore,
    required DateTime occurredAt,
  }) async {
    attempts++;
  }

  @override
  Future<void> saveLessonProgress(LessonProgress value) async {
    progress
      ..removeWhere((item) => item.lessonId == value.lessonId)
      ..add(value);
  }
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
