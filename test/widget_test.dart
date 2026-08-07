import 'package:crolingo/app/crolingo_app.dart';
import 'package:crolingo/app/providers.dart';
import 'package:crolingo/app/router.dart';
import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/domain/progress/progress_repository.dart';
import 'package:crolingo/features/home/home_screen.dart';
import 'package:crolingo/features/path/learning_path_screen.dart';
import 'package:crolingo/features/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    appRouter.go('/');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          courseProvider.overrideWith((ref) => _dashboardCourse),
          progressRepositoryProvider.overrideWithValue(_FakeProgress()),
        ],
        child: const CroLingoApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the Croatian dashboard', (tester) async {
    await pumpApp(tester);

    expect(find.text('Bok! Bereit für Kroatisch?'), findsOneWidget);
    expect(find.text('🇩🇪 Deutsch → 🇭🇷 Hrvatski'), findsOneWidget);
    expect(find.text('Einheit 1 · Erste Worte'), findsOneWidget);
    expect(find.text('Begrüßen'), findsOneWidget);
    expect(find.text('Lektion starten'), findsOneWidget);
    expect(find.text('Keine Herzen'), findsNothing);
  });

  testWidgets('shows the durable lesson checkpoint as next action', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progressRepositoryProvider.overrideWithValue(
            _FakeProgress(
              progress: [
                const LessonProgress(
                  lessonId: 'lesson-one',
                  exerciseIndex: 1,
                  xp: 8,
                  completedAt: null,
                ),
              ],
            ),
          ),
        ],
        child: MaterialApp(
          home: HomeScreen(course: Future.value(_pathCourse)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Einheit 1 · Erste Einheit'), findsOneWidget);
    expect(find.text('Erste'), findsOneWidget);
    expect(find.text('Weiterlernen'), findsOneWidget);
    expect(find.textContaining('gespeicherten Punkt'), findsOneWidget);
  });

  testWidgets('unlocks the next unit from ordered course data', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progressRepositoryProvider.overrideWithValue(
            _FakeProgress(
              progress: [
                LessonProgress(
                  lessonId: 'lesson-one',
                  exerciseIndex: 1,
                  xp: 20,
                  completedAt: DateTime.utc(2026, 8, 7),
                ),
              ],
            ),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: LearningPathScreen(course: Future.value(_pathCourse)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Einheit 1 · Erste Einheit'), findsOneWidget);
    expect(find.text('Einheit 2 · Zweite Einheit'), findsOneWidget);
    expect(
      find.text('Goldkrone verdient! Einheit abgeschlossen.'),
      findsOneWidget,
    );
    expect(find.text('Zweites Ziel'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
  });

  testWidgets('opens the next lesson from the dashboard', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Lektion starten'));
    await tester.pump();

    expect(appRouter.state.uri.path, '/lesson/begrussen');
  });

  testWidgets('navigates to review and more', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Üben'));
    await tester.pumpAndSettle();
    expect(find.text('Noch nichts fällig'), findsOneWidget);

    await tester.tap(find.text('Mehr'));
    await tester.pumpAndSettle();
    expect(find.text('Wortschatz'), findsOneWidget);
    expect(find.text('Offline · Keine Werbung · Keine Herzen'), findsOneWidget);

    await tester.tap(find.text('Wortschatz'));
    await tester.pump();
    expect(appRouter.state.uri.path, '/more/vocabulary');
    expect(find.text('Wortschatz'), findsOneWidget);
  });

  testWidgets('supports a narrow phone at 200 percent text scaling', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(320, 800)
      ..devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(() {
      tester.view.reset();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await pumpApp(tester);
    expect(tester.takeException(), isNull);
    appRouter.go('/path');
    await _pumpUntil(tester, find.text('Dein Lernweg'));
    expect(tester.takeException(), isNull);
    appRouter.go('/review');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    appRouter.go('/more/vocabulary');
    await _pumpFrames(tester);
    expect(tester.takeException(), isNull);
    appRouter.go('/more/profile');
    await _pumpFrames(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows complete private profile statistics', (tester) async {
    await pumpApp(tester);
    appRouter.go('/more');
    await tester.pumpAndSettle();

    final profile = find.text('Profil & Statistik');
    await tester.ensureVisible(profile);
    await tester.tap(profile);
    await tester.pump();
    expect(appRouter.state.uri.path, '/more/profile');
  });

  testWidgets('renders complete private profile statistics', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progressRepositoryProvider.overrideWithValue(_FakeProgress()),
        ],
        child: MaterialApp(
          home: ProfileScreen(
            course: Future<Course>.value(
              const Course(id: 'test', title: 'Test', units: [], concepts: []),
            ),
          ),
        ),
      ),
    );
    await _pumpFrames(tester);
    expect(find.text('XP insgesamt'), findsOneWidget);
    expect(find.text('Wörter gelernt'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Gestartet'), 200);
    expect(find.text('Längste Serie'), findsOneWidget);
    expect(find.text('Gestartet'), findsOneWidget);
  });

  testWidgets('opens a recently completed lesson for review', (tester) async {
    appRouter.go('/review');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progressRepositoryProvider.overrideWithValue(
            _FakeProgress(
              progress: [
                LessonProgress(
                  lessonId: 'begrussen',
                  exerciseIndex: 4,
                  xp: 50,
                  completedAt: DateTime.utc(2026, 8, 7),
                ),
              ],
            ),
          ),
        ],
        child: const CroLingoApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 neu gelernte Lektionen'), findsOneWidget);
    await tester.tap(find.text('Begrussen').first);
    await tester.pump();
    expect(appRouter.state.uri.path, '/lesson/begrussen');
  });
}

Future<void> _pumpFrames(WidgetTester tester) async {
  for (var index = 0; index < 10; index++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _pumpUntil(WidgetTester tester, Finder finder) async {
  for (var index = 0; index < 50 && finder.evaluate().isEmpty; index++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

class _FakeProgress implements ProgressRepository {
  _FakeProgress({this.progress = const []});

  final List<LessonProgress> progress;

  @override
  Future<List<ExerciseAttempt>> loadAttemptHistory() async => [];

  @override
  Future<List<DueReview>> loadDueReviews({DateTime? now}) async => [];

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
  }) async {}

  @override
  Future<void> saveLessonProgress(LessonProgress progress) async {}
}

const _pathCourse = Course(
  id: 'test-course',
  title: 'Testkurs',
  concepts: [],
  units: [
    CourseUnit(
      id: 'unit-one',
      title: 'Erste Einheit',
      description: 'Erstes Ziel',
      lessons: [Lesson(id: 'lesson-one', title: 'Erste', exercises: [])],
    ),
    CourseUnit(
      id: 'unit-two',
      title: 'Zweite Einheit',
      description: 'Zweites Ziel',
      lessons: [Lesson(id: 'lesson-two', title: 'Zweite', exercises: [])],
    ),
  ],
);

const _dashboardCourse = Course(
  id: 'dashboard-course',
  title: 'Kroatisch für den Alltag',
  concepts: [],
  units: [
    CourseUnit(
      id: 'erste-worte',
      title: 'Erste Worte',
      description: 'Begrüße Menschen und stelle dich vor.',
      lessons: [
        Lesson(id: 'begrussen', title: 'Begrüßen', exercises: []),
      ],
    ),
  ],
);
