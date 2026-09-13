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
  Future<void> pumpReview(WidgetTester tester, _Progress progress) async {
    tester.view
      ..physicalSize = const Size(1236, 3600)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
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
          progressRepositoryProvider.overrideWithValue(progress),
          // Due reviews name a concept, so the screen resolves it to a word.
          courseProvider.overrideWith((ref) => _course),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('disables every mode when nothing has been practised', (
    tester,
  ) async {
    await pumpReview(tester, const _Progress());

    expect(find.text('Im Moment ist nichts fällig.'), findsOneWidget);
    expect(find.text('Noch keine Fehler gespeichert.'), findsOneWidget);
    expect(find.text('Noch keine Lektion abgeschlossen.'), findsOneWidget);
  });

  testWidgets('opens the due exercise', (tester) async {
    await pumpReview(
      tester,
      _Progress(
        due: [
          DueReview(
            conceptId: 'bok',
            dimension: MasteryDimension.germanToCroatian,
            lessonId: 'faellig',
            exerciseId: 'e1',
            due: DateTime.utc(2026, 8, 9),
          ),
        ],
      ),
    );

    await tester.tap(find.text('Empfohlen & fällig'));
    await tester.pumpAndSettle();

    expect(find.text('opened faellig e1'), findsOneWidget);
  });

  testWidgets('opens the lesson behind a recent mistake', (tester) async {
    await pumpReview(
      tester,
      _Progress(
        mistakes: [
          RecentMistake(
            lessonId: 'fehler',
            exerciseId: 'e2',
            submittedAnswer: 'falsch',
            occurredAt: DateTime.utc(2026, 8, 9),
          ),
        ],
      ),
    );

    await tester.tap(find.text('Letzte Fehler'));
    await tester.pumpAndSettle();

    expect(find.text('opened fehler e2'), findsOneWidget);
  });

  testWidgets('replays a recently completed lesson', (tester) async {
    await pumpReview(
      tester,
      _Progress(
        completed: [
          LessonProgress(
            lessonId: 'gelernt',
            exerciseIndex: 0,
            xp: 10,
            completedAt: DateTime.utc(2026, 8, 9),
          ),
        ],
      ),
    );

    await tester.tap(find.text('Neu gelernt'));
    await tester.pumpAndSettle();

    expect(find.text('opened gelernt null'), findsOneWidget);
  });
}

class _Progress implements ProgressRepository {
  const new({
    this.due = const [],
    this.mistakes = const [],
    this.completed = const [],
  });

  final List<DueReview> due;
  final List<RecentMistake> mistakes;
  final List<LessonProgress> completed;

  @override
  Future<List<DueReview>> loadDueReviews({
    required Course course,
    DateTime? now,
  }) async => due;

  @override
  Future<List<RecentMistake>> loadRecentMistakes({int limit = 20}) async =>
      mistakes;

  @override
  Future<List<LessonProgress>> loadLessonProgress() async => completed;

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
