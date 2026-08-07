import 'package:crolingo/data/progress/app_database.dart';
import 'package:crolingo/data/review/fsrs_review_scheduler.dart';
import 'package:crolingo/domain/progress/progress_repository.dart';
import 'package:crolingo/domain/progress/streak_calculator.dart';
import 'package:crolingo/domain/review/review_scheduler.dart';
import 'package:drift/drift.dart';

/// SQLite implementation of local learning progress.
class DriftProgressRepository implements ProgressRepository {
  /// Creates a repository backed by [database].
  DriftProgressRepository(this.database, {ReviewScheduler? reviewScheduler})
    : reviewScheduler = reviewScheduler ?? FsrsReviewScheduler();

  /// Owned database connection.
  final AppDatabase database;

  /// Replaceable due-date algorithm.
  final ReviewScheduler reviewScheduler;

  @override
  Future<void> recordAttempt({
    required String lessonId,
    required String exerciseId,
    required String submittedAnswer,
    required bool correct,
    required int incorrectBefore,
    required DateTime occurredAt,
  }) async {
    await database
        .into(database.attemptEntries)
        .insert(
          AttemptEntriesCompanion.insert(
            lessonId: lessonId,
            exerciseId: exerciseId,
            submittedAnswer: submittedAnswer,
            correct: correct,
            incorrectBefore: incorrectBefore,
            occurredAt: occurredAt.toUtc(),
          ),
        );
  }

  @override
  Future<void> saveLessonProgress(LessonProgress progress) async {
    await database.transaction(() async {
      await database
          .into(database.lessonProgressEntries)
          .insertOnConflictUpdate(
            LessonProgressEntriesCompanion.insert(
              lessonId: progress.lessonId,
              exerciseIndex: progress.exerciseIndex,
              xp: progress.xp,
              completedAt: Value(progress.completedAt?.toUtc()),
            ),
          );
      if (progress.completedAt != null) {
        final local = progress.completedAt!.toLocal();
        final key =
            '${local.year.toString().padLeft(4, '0')}-'
            '${local.month.toString().padLeft(2, '0')}-'
            '${local.day.toString().padLeft(2, '0')}';
        await database
            .into(database.studyDayEntries)
            .insertOnConflictUpdate(
              StudyDayEntriesCompanion.insert(dayKey: key, xp: progress.xp),
            );
      }
    });
  }

  @override
  Future<List<LessonProgress>> loadLessonProgress() async {
    final rows = await database.select(database.lessonProgressEntries).get();
    return [
      for (final row in rows)
        LessonProgress(
          lessonId: row.lessonId,
          exerciseIndex: row.exerciseIndex,
          xp: row.xp,
          completedAt: row.completedAt?.toUtc(),
        ),
    ];
  }

  @override
  Future<LearningStats> loadStats() async {
    final lessons = await loadLessonProgress();
    final studyDays = await database.select(database.studyDayEntries).get();
    studyDays.sort((left, right) => left.dayKey.compareTo(right.dayKey));
    final streaks = StreakCalculator.calculate(
      studyDays.map((day) => day.dayKey),
      DateTime.now(),
    );
    return LearningStats(
      totalXp: lessons.fold(0, (sum, lesson) => sum + lesson.xp),
      completedLessons: lessons
          .where((lesson) => lesson.completedAt != null)
          .length,
      studyDays: studyDays.length,
      currentStreak: streaks.current,
      longestStreak: streaks.longest,
      startedOn: studyDays.isEmpty
          ? null
          : DateTime.parse(studyDays.first.dayKey),
    );
  }

  @override
  Future<List<RecentMistake>> loadRecentMistakes({int limit = 20}) async {
    final query = database.select(database.attemptEntries)
      ..where((row) => row.correct.equals(false))
      ..orderBy([(row) => OrderingTerm.desc(row.occurredAt)])
      ..limit(limit);
    final rows = await query.get();
    return [
      for (final row in rows)
        RecentMistake(
          lessonId: row.lessonId,
          exerciseId: row.exerciseId,
          submittedAnswer: row.submittedAnswer,
          occurredAt: row.occurredAt.toUtc(),
        ),
    ];
  }

  @override
  Future<List<DueReview>> loadDueReviews({DateTime? now}) async {
    final query = database.select(database.attemptEntries)
      ..where((row) => row.correct.equals(true))
      ..orderBy([(row) => OrderingTerm.asc(row.occurredAt)]);
    final rows = await query.get();
    final states = <String, ReviewSchedule>{};
    final lessons = <String, String>{};
    for (final row in rows) {
      final previous = states[row.exerciseId];
      states[row.exerciseId] = reviewScheduler.review(
        previousState: previous?.state,
        priorIncorrectAttempts: row.incorrectBefore,
        reviewedAt: row.occurredAt.toUtc(),
      );
      lessons[row.exerciseId] = row.lessonId;
    }
    final current = (now ?? DateTime.now()).toUtc();
    final due = <DueReview>[
      for (final entry in states.entries)
        if (!entry.value.due.isAfter(current))
          DueReview(
            lessonId: lessons[entry.key]!,
            exerciseId: entry.key,
            due: entry.value.due,
          ),
    ]..sort((left, right) => left.due.compareTo(right.due));
    return due;
  }

  @override
  Future<List<ExerciseAttempt>> loadAttemptHistory() async {
    final query = database.select(database.attemptEntries)
      ..orderBy([(row) => OrderingTerm.asc(row.occurredAt)]);
    final rows = await query.get();
    return [
      for (final row in rows)
        ExerciseAttempt(
          exerciseId: row.exerciseId,
          correct: row.correct,
          incorrectBefore: row.incorrectBefore,
          occurredAt: row.occurredAt.toUtc(),
        ),
    ];
  }
}
