import 'dart:async';

import 'package:crolingo/app/providers.dart';
import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/domain/progress/progress_repository.dart';
import 'package:crolingo/features/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  Future<GoRouter> pumpHome(
    WidgetTester tester, {
    required List<LessonProgress> progress,
    bool versionUnavailable = false,
  }) async {
    tester.view
      ..physicalSize = const Size(1236, 3600)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: HomeScreen(course: Future<Course>.value(_course)),
          ),
        ),
        GoRoute(
          path: '/path',
          builder: (context, state) =>
              const Scaffold(body: Text('learning path')),
        ),
        GoRoute(
          path: '/lesson/:lessonId',
          builder: (context, state) => Scaffold(
            body: Text('lesson ${state.pathParameters['lessonId']}'),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progressRepositoryProvider.overrideWithValue(_Progress(progress)),
          if (versionUnavailable)
            appVersionProvider.overrideWith(
              (ref) async => throw const _BrokenCourse(),
            ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('offers the next lesson and opens it', (tester) async {
    final pumpedRouter = pumpHome(tester, progress: const []);
    await pumpedRouter;

    expect(find.text('Einheit 1 · Begrüßung'), findsOneWidget);
    expect(find.text('Lektion starten'), findsOneWidget);

    final router = await pumpedRouter;
    await tester.tap(find.text('Lektion starten'));
    await tester.pumpAndSettle();

    expect(find.text('lesson hallo'), findsOneWidget);

    // Coming back must refresh the dashboard, not show a stale next step.
    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('Lektion starten'), findsOneWidget);
  });

  testWidgets('celebrates a finished course and routes to the path', (
    tester,
  ) async {
    await pumpHome(
      tester,
      progress: [_done('hallo'), _done('tschuess')],
    );

    expect(find.text('Kurs abgeschlossen'), findsOneWidget);
    expect(find.byIcon(Icons.workspace_premium_rounded), findsOneWidget);

    await tester.tap(find.text('Lernweg ansehen'));
    await tester.pumpAndSettle();

    expect(find.text('learning path'), findsOneWidget);
  });

  testWidgets('hides the version when the pubspec cannot be read', (
    tester,
  ) async {
    await pumpHome(
      tester,
      progress: const [],
      versionUnavailable: true,
    );

    expect(find.textContaining('Version '), findsNothing);
    expect(find.text('CroLingo'), findsOneWidget);
  });

  testWidgets('shows a safe message when the next step cannot load', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1236, 3600)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final course = Completer<Course>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progressRepositoryProvider.overrideWithValue(
            const _Progress([]),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: HomeScreen(course: course.future)),
        ),
      ),
    );
    course.completeError(const _BrokenCourse());
    await tester.pumpAndSettle();

    expect(
      find.text('Dein nächster Schritt konnte nicht geladen werden.'),
      findsOneWidget,
    );
  });
}

class _BrokenCourse implements Exception {
  const _BrokenCourse();
}

LessonProgress _done(String lessonId) => LessonProgress(
  lessonId: lessonId,
  exerciseIndex: 0,
  xp: 10,
  completedAt: DateTime.utc(2026, 8, 9),
);

class _Progress implements ProgressRepository {
  const _Progress(this.stored);

  final List<LessonProgress> stored;

  @override
  Future<List<LessonProgress>> loadLessonProgress() async => stored;

  @override
  Future<List<ExerciseAttempt>> loadAttemptHistory() async => [];

  @override
  Future<List<DueReview>> loadDueReviews({DateTime? now}) async => [];

  @override
  Future<List<RecentMistake>> loadRecentMistakes({int limit = 20}) async => [];

  @override
  Future<LearningStats> loadStats() async => const LearningStats(
    totalXp: 40,
    completedLessons: 2,
    studyDays: 2,
    currentStreak: 1,
    longestStreak: 2,
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

Exercise _exercise(String id) => Exercise(
  id: id,
  type: ExerciseType.translation,
  masteryDimension: MasteryDimension.germanToCroatian,
  prompt: 'Prompt',
  acceptedAnswers: const ['Answer'],
  explanation: 'Explanation',
  conceptIds: const ['bok'],
  pairs: const [],
  tiles: const [],
);

final _course = Course(
  id: 'home-test',
  title: 'Kroatisch für Anfänger',
  concepts: const [Concept(id: 'bok', croatian: 'Bok!', german: 'Hallo!')],
  units: [
    CourseUnit(
      id: 'unit-1',
      title: 'Begrüßung',
      description: 'Hallo sagen lernen',
      lessons: [
        Lesson(
          id: 'hallo',
          title: 'Hallo sagen',
          exercises: [_exercise('hallo-1')],
        ),
        Lesson(
          id: 'tschuess',
          title: 'Tschüss sagen',
          exercises: [_exercise('tschuess-1')],
        ),
      ],
    ),
  ],
);
