import 'package:crolingo/app/providers.dart';
import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/domain/progress/progress_repository.dart';
import 'package:crolingo/features/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpProfile(
    WidgetTester tester, {
    required ProgressRepository progress,
    Future<Course>? course,
  }) async {
    tester.view
      ..physicalSize = const Size(1236, 3600)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progressRepositoryProvider.overrideWithValue(progress),
          courseProvider.overrideWith((ref) => course ?? Future.value(_course)),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );
    // A bounded pump: the screen keeps a running indicator alive while its
    // futures resolve, so pumpAndSettle would never return.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('formats the first learning day', (tester) async {
    await pumpProfile(
      tester,
      progress: _Progress(startedOn: DateTime.utc(2026, 3, 7)),
    );

    // Single digits are padded so the column does not jitter.
    expect(find.text('07.03.2026'), findsOneWidget);
  });
}

class _Progress implements ProgressRepository {
  const _Progress({this.startedOn});

  final DateTime? startedOn;

  @override
  Future<LearningStats> loadStats() async => LearningStats(
    totalXp: 120,
    completedLessons: 3,
    studyDays: 4,
    currentStreak: 2,
    longestStreak: 5,
    startedOn: startedOn,
  );

  @override
  Future<List<LessonProgress>> loadLessonProgress() async => [];

  @override
  Future<List<ExerciseAttempt>> loadAttemptHistory() async => [];

  @override
  Future<List<DueReview>> loadDueReviews({DateTime? now}) async => [];

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

const _course = Course(
  id: 'profile-test',
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
              prompt: 'Prompt',
              acceptedAnswers: ['Bok!'],
              explanation: 'Explanation',
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
