import 'dart:async';

import 'package:crolingo/app/providers.dart';
import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/domain/progress/progress_repository.dart';
import 'package:crolingo/features/vocabulary/vocabulary_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows loading and every practiced mastery dimension', (
    tester,
  ) async {
    final course = Completer<Course>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          courseProvider.overrideWith((ref) => course.future),
          progressRepositoryProvider.overrideWithValue(
            _VocabularyProgress(_attempts),
          ),
        ],
        child: const MaterialApp(home: VocabularyScreen()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    course.complete(_course);
    await tester.pumpAndSettle();

    expect(find.text('Bok!'), findsOneWidget);
    expect(find.text('Hallo!'), findsOneWidget);
    expect(find.text('100 %'), findsOneWidget);
    expect(
      find.text(
        'Erkennen · Deutsch → Kroatisch · Kroatisch → Deutsch · '
        'Sätze bilden · Anwenden',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows an unpracticed concept without inventing mastery', (
    tester,
  ) async {
    await _pumpVocabulary(tester, course: _course, attempts: const []);

    expect(find.text('0 %'), findsOneWidget);
    expect(find.text('Noch nicht geübt'), findsOneWidget);
  });

  testWidgets('shows a safe message when course loading fails', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          courseProvider.overrideWith(
            (ref) => Future<Course>.error(StateError('broken course')),
          ),
          progressRepositoryProvider.overrideWithValue(
            const _VocabularyProgress([]),
          ),
        ],
        child: const MaterialApp(home: VocabularyScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Wortschatz konnte nicht geladen werden.'),
      findsOneWidget,
    );
  });
}

Future<void> _pumpVocabulary(
  WidgetTester tester, {
  required Course course,
  required List<ExerciseAttempt> attempts,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        courseProvider.overrideWith((ref) => course),
        progressRepositoryProvider.overrideWithValue(
          _VocabularyProgress(attempts),
        ),
      ],
      child: const MaterialApp(home: VocabularyScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

class _VocabularyProgress implements ProgressRepository {
  const _VocabularyProgress(this.attempts);

  final List<ExerciseAttempt> attempts;

  @override
  Future<List<ExerciseAttempt>> loadAttemptHistory() async => attempts;

  @override
  Future<List<DueReview>> loadDueReviews({DateTime? now}) async => [];

  @override
  Future<List<LessonProgress>> loadLessonProgress() async => [];

  @override
  Future<List<RecentMistake>> loadRecentMistakes({int limit = 20}) async => [];

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
  Future<void> recordAttempt({
    required String lessonId,
    required String exerciseId,
    required String submittedAnswer,
    required bool correct,
    required int incorrectBefore,
    required DateTime occurredAt,
  }) async {}

  @override
  Future<void> saveLessonProgress(LessonProgress progress) async {}
}

const _concept = Concept(id: 'bok', croatian: 'Bok!', german: 'Hallo!');

final _course = Course(
  id: 'vocabulary-test',
  title: 'Test',
  concepts: [_concept],
  units: [
    CourseUnit(
      id: 'unit',
      title: 'Unit',
      description: 'Description',
      lessons: [
        Lesson(
          id: 'lesson',
          title: 'Lesson',
          exercises: MasteryDimension.values
              .map(
                (dimension) => Exercise(
                  id: 'exercise-${dimension.name}',
                  type: ExerciseType.translation,
                  masteryDimension: dimension,
                  prompt: 'Prompt',
                  acceptedAnswers: const ['Answer'],
                  explanation: 'Explanation',
                  conceptIds: const ['bok'],
                  pairs: const [],
                  tiles: const [],
                ),
              )
              .toList(),
        ),
      ],
    ),
  ],
);

final List<ExerciseAttempt> _attempts = [
  for (final dimension in MasteryDimension.values)
    ExerciseAttempt(
      exerciseId: 'exercise-${dimension.name}',
      correct: true,
      incorrectBefore: 0,
      occurredAt: DateTime.utc(2026, 8, 7),
    ),
];
