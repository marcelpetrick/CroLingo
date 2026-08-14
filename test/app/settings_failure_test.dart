import 'package:crolingo/app/crolingo_app.dart';
import 'package:crolingo/app/providers.dart';
import 'package:crolingo/app/router.dart';
import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/domain/progress/progress_repository.dart';
import 'package:crolingo/domain/settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unreadable preferences must never take the app down: every screen falls
/// back to the safe default instead.
void main() {
  Future<void> pumpWithBrokenSettings(WidgetTester tester, String at) async {
    tester.view
      ..physicalSize = const Size(1236, 3600)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    appRouter.go(at);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith(
            (ref) => Stream<AppSettings>.error(const _Unreadable()),
          ),
          courseProvider.overrideWith((ref) => _course),
          progressRepositoryProvider.overrideWithValue(const _Progress()),
        ],
        child: const CroLingoApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('keeps the default appearance when settings fail', (
    tester,
  ) async {
    await pumpWithBrokenSettings(tester, '/');

    expect(find.text('Bok! Bereit für Kroatisch?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('still opens a lesson with sounds left enabled', (tester) async {
    // The lesson route resolves against the bundled course, so this uses a
    // real lesson id rather than the fixture above.
    await pumpWithBrokenSettings(tester, '/lesson/begrussen');

    expect(find.text('Was gehört zusammen?'), findsOneWidget);
    addTearDown(() => appRouter.go('/'));
  });

  testWidgets('warns on the settings screen and keeps safe defaults', (
    tester,
  ) async {
    await pumpWithBrokenSettings(tester, '/more/settings');

    expect(find.textContaining('sichere Standard'), findsOneWidget);
    expect(find.text('Ergebnistöne'), findsOneWidget);
    expect(find.text('Adria-Blau'), findsOneWidget);
    addTearDown(() => appRouter.go('/'));
  });
}

class _Unreadable implements Exception {
  const _Unreadable();
}

class _Progress implements ProgressRepository {
  const _Progress();

  @override
  Future<List<LessonProgress>> loadLessonProgress() async => [];

  @override
  Future<List<ExerciseAttempt>> loadAttemptHistory() async => [];

  @override
  Future<List<DueReview>> loadDueReviews({
    required Course course,
    DateTime? now,
  }) async => [];

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

const _course = Course(
  id: 'settings-failure',
  title: 'Kroatisch',
  concepts: [Concept(id: 'bok', croatian: 'Bok!', german: 'Hallo!')],
  units: [
    CourseUnit(
      id: 'unit-1',
      title: 'Begrüßung',
      description: 'Hallo sagen lernen',
      lessons: [
        Lesson(
          id: 'hallo',
          title: 'Hallo sagen',
          exercises: [
            Exercise(
              id: 'hallo-1',
              type: ExerciseType.translation,
              masteryDimension: MasteryDimension.germanToCroatian,
              prompt: 'Übersetze: Hallo!',
              acceptedAnswers: ['Bok!'],
              explanation: 'Bok ist die lockere Begrüßung.',
              conceptIds: ['bok'],
              pairs: [],
              tiles: [],
            ),
          ],
        ),
      ],
    ),
  ],
);
