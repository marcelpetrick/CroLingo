import 'package:crolingo/app/providers.dart';
import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/domain/progress/progress_repository.dart';
import 'package:crolingo/features/review/review_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Minimal content so a due review can be resolved to a Croatian word.
const _course = Course(
  id: 'course',
  title: 'Course',
  concepts: [Concept(id: 'bok', croatian: 'Bok!', german: 'Hallo!')],
  units: [
    CourseUnit(
      id: 'unit',
      title: 'Unit',
      description: 'Description',
      lessons: [Lesson(id: 'lesson', title: 'Lesson', exercises: [])],
    ),
  ],
);

void main() {
  testWidgets('shows and opens every available review family', (tester) async {
    final router = GoRouter(
      initialLocation: '/review',
      routes: [
        GoRoute(
          path: '/review',
          builder: (context, state) => const Scaffold(body: ReviewScreen()),
        ),
        GoRoute(
          path: '/lesson/:lessonId',
          builder: (context, state) => Scaffold(
            body: Text(
              'opened ${state.pathParameters['lessonId']} '
              '${state.uri.queryParameters['exercise']}',
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progressRepositoryProvider.overrideWithValue(_ReviewProgress()),
          // Due reviews name a concept, so the screen resolves it to a word.
          courseProvider.overrideWith((ref) => _course),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 Übungen fällig'), findsOneWidget);
    expect(find.text('1 letzte Fehler'), findsOneWidget);
    expect(find.text('2 neu gelernte Lektionen'), findsOneWidget);
    expect(find.text('Deine Antwort: falsch'), findsOneWidget);

    // A due item names the word and the direction, not the exercise slug.
    expect(find.text('Bok!'), findsOneWidget);
    expect(find.text('Kroatisch → Deutsch'), findsOneWidget);

    await tester.tap(find.text('Bok!'));
    await tester.pumpAndSettle();
    expect(find.text('opened due-lesson due-exercise'), findsOneWidget);

    router.go('/review');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mistake exercise'));
    await tester.pumpAndSettle();
    expect(find.text('opened mistake-lesson mistake-exercise'), findsOneWidget);

    router.go('/review');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Recent new'), 200);
    await tester.tap(find.text('Recent new').first);
    await tester.pumpAndSettle();
    expect(find.text('opened recent-new null'), findsOneWidget);

    router.go('/review');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Neu gelernt'), 200);
    expect(find.text('2 Lektionen erneut üben'), findsOneWidget);
  });
}

class _ReviewProgress implements ProgressRepository {
  @override
  Future<List<DueReview>> loadDueReviews({
    required Course course,
    DateTime? now,
  }) async => [
    DueReview(
      conceptId: 'bok',
      dimension: MasteryDimension.croatianToGerman,
      lessonId: 'due-lesson',
      exerciseId: 'due-exercise',
      due: DateTime.utc(2026, 8, 7),
    ),
  ];

  @override
  Future<List<RecentMistake>> loadRecentMistakes({int limit = 20}) async => [
    RecentMistake(
      lessonId: 'mistake-lesson',
      exerciseId: 'mistake-exercise',
      submittedAnswer: 'falsch',
      occurredAt: DateTime.utc(2026, 8, 7),
    ),
  ];

  @override
  Future<List<LessonProgress>> loadLessonProgress() async => [
    LessonProgress(
      lessonId: 'recent-old',
      exerciseIndex: 3,
      xp: 20,
      completedAt: DateTime.utc(2026, 8, 6),
    ),
    LessonProgress(
      lessonId: 'recent-new',
      exerciseIndex: 4,
      xp: 30,
      completedAt: DateTime.utc(2026, 8, 7),
    ),
    const LessonProgress(
      lessonId: 'incomplete',
      exerciseIndex: 1,
      xp: 4,
      completedAt: null,
    ),
  ];

  @override
  Future<List<ExerciseAttempt>> loadAttemptHistory() async => [];

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
