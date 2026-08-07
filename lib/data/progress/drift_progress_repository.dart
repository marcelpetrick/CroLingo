import 'package:crolingo/data/progress/app_database.dart';
import 'package:crolingo/domain/progress/progress_repository.dart';
import 'package:drift/drift.dart';

/// SQLite implementation of local learning progress.
class DriftProgressRepository implements ProgressRepository {
  /// Creates a repository backed by [database].
  const DriftProgressRepository(this.database);

  /// Owned database connection.
  final AppDatabase database;

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
    return LearningStats(
      totalXp: lessons.fold(0, (sum, lesson) => sum + lesson.xp),
      completedLessons: lessons
          .where((lesson) => lesson.completedAt != null)
          .length,
      studyDays: studyDays.length,
    );
  }
}
