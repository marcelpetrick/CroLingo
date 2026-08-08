import 'dart:async';

import 'package:crolingo/app/providers.dart';
import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/domain/progress/progress_repository.dart';
import 'package:crolingo/features/path/learning_path_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('shows a loading indicator until the path resolves', (
    tester,
  ) async {
    _useTallViewport(tester);
    final course = Completer<Course>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progressRepositoryProvider.overrideWithValue(const _PathProgress([])),
        ],
        child: MaterialApp(
          home: Scaffold(body: LearningPathScreen(course: course.future)),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    course.complete(_course);
    await tester.pumpAndSettle();

    expect(find.text('Dein Lernweg'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('locks every lesson after the first until one is completed', (
    tester,
  ) async {
    await _pumpPath(tester, progress: const []);

    expect(find.text('Einheit 1 · Begrüßung'), findsOneWidget);
    expect(find.text('Einheit 2 · Abschied'), findsOneWidget);
    expect(find.text('Lektion 1 · Hallo sagen'), findsOneWidget);

    // Only the very first lesson is reachable.
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline_rounded), findsNWidgets(3));
    expect(find.byIcon(Icons.check_rounded), findsNothing);
  });

  testWidgets('unlocks the next lesson once the previous one is completed', (
    tester,
  ) async {
    await _pumpPath(tester, progress: [_completed('hallo')]);

    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline_rounded), findsNWidgets(2));
  });

  testWidgets('awards the unit crown and unlocks across the unit boundary', (
    tester,
  ) async {
    await _pumpPath(
      tester,
      progress: [_completed('hallo'), _completed('vorstellen')],
    );

    expect(
      find.text('Goldkrone verdient! Einheit abgeschlossen.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.workspace_premium_rounded), findsOneWidget);
    // The second unit keeps its description until it is finished too.
    expect(find.text('Auf Wiedersehen sagen'), findsOneWidget);
    expect(find.byIcon(Icons.waving_hand_rounded), findsOneWidget);
    // First lesson of the second unit became reachable.
    expect(find.byIcon(Icons.check_rounded), findsNWidgets(2));
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
  });

  testWidgets('ignores an unfinished lesson checkpoint when unlocking', (
    tester,
  ) async {
    await _pumpPath(
      tester,
      progress: const [
        LessonProgress(
          lessonId: 'hallo',
          exerciseIndex: 1,
          xp: 4,
          completedAt: null,
        ),
      ],
    );

    expect(find.byIcon(Icons.check_rounded), findsNothing);
    expect(find.byIcon(Icons.lock_outline_rounded), findsNWidgets(3));
  });

  testWidgets('opens an unlocked lesson and reloads progress on return', (
    tester,
  ) async {
    _useTallViewport(tester);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: LearningPathScreen(course: Future<Course>.value(_course)),
          ),
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
          progressRepositoryProvider.overrideWithValue(const _PathProgress([])),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lektion 1 · Hallo sagen'));
    await tester.pumpAndSettle();
    expect(find.text('lesson hallo'), findsOneWidget);

    // Returning from the lesson reloads the checkpoints behind the path.
    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('Dein Lernweg'), findsOneWidget);
  });

  testWidgets('shows a safe message when the path cannot be loaded', (
    tester,
  ) async {
    final course = Completer<Course>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progressRepositoryProvider.overrideWithValue(const _PathProgress([])),
        ],
        child: MaterialApp(
          home: Scaffold(body: LearningPathScreen(course: course.future)),
        ),
      ),
    );
    course.completeError(StateError('broken course'));
    await tester.pumpAndSettle();

    expect(find.text('Lernweg konnte nicht geladen werden.'), findsOneWidget);
  });
}

/// Renders the whole path, so lazy list building cannot hide a lesson node.
void _useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1236, 3600);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> _pumpPath(
  WidgetTester tester, {
  required List<LessonProgress> progress,
}) async {
  _useTallViewport(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        progressRepositoryProvider.overrideWithValue(_PathProgress(progress)),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: LearningPathScreen(course: Future<Course>.value(_course)),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

LessonProgress _completed(String lessonId) => LessonProgress(
  lessonId: lessonId,
  exerciseIndex: 0,
  xp: 10,
  completedAt: DateTime.utc(2026, 8, 8),
);

class _PathProgress implements ProgressRepository {
  const _PathProgress(this.progress);

  final List<LessonProgress> progress;

  @override
  Future<List<LessonProgress>> loadLessonProgress() async => progress;

  @override
  Future<List<ExerciseAttempt>> loadAttemptHistory() async => [];

  @override
  Future<List<DueReview>> loadDueReviews({DateTime? now}) async => [];

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
  id: 'path-test',
  title: 'Test',
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
          id: 'vorstellen',
          title: 'Sich vorstellen',
          exercises: [_exercise('vorstellen-1')],
        ),
      ],
    ),
    CourseUnit(
      id: 'unit-2',
      title: 'Abschied',
      description: 'Auf Wiedersehen sagen',
      lessons: [
        Lesson(
          id: 'tschuess',
          title: 'Tschüss sagen',
          exercises: [_exercise('tschuess-1')],
        ),
        Lesson(
          id: 'danke',
          title: 'Danke sagen',
          exercises: [_exercise('danke-1')],
        ),
      ],
    ),
  ],
);
