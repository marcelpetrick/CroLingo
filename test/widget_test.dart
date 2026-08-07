import 'package:crolingo/app/crolingo_app.dart';
import 'package:crolingo/app/providers.dart';
import 'package:crolingo/app/router.dart';
import 'package:crolingo/domain/progress/progress_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    appRouter.go('/');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
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
    expect(find.text('Deutsch → Hrvatski'), findsOneWidget);
    expect(find.text('Keine Herzen'), findsNothing);
  });

  testWidgets('opens the learning path from the dashboard', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Lernweg öffnen'));
    await tester.pumpAndSettle();

    expect(find.text('Dein Lernweg'), findsOneWidget);
    expect(find.text('Lektion 1 · Begrüßen'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline_rounded), findsWidgets);
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
    await tester.pumpAndSettle();
    expect(find.text('Bok!'), findsOneWidget);
    expect(find.text('Noch nicht geübt'), findsWidgets);
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
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    appRouter.go('/review');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
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
