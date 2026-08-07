/// Stored state used to resume and unlock learning.
class LessonProgress {
  /// Creates a lesson progress snapshot.
  const LessonProgress({
    required this.lessonId,
    required this.exerciseIndex,
    required this.xp,
    required this.completedAt,
  });

  /// Stable lesson ID.
  final String lessonId;

  /// Exercise to resume.
  final int exerciseIndex;

  /// XP earned in this lesson.
  final int xp;

  /// UTC completion time, or null while incomplete.
  final DateTime? completedAt;
}

/// Aggregate local learning statistics.
class LearningStats {
  /// Creates statistics.
  const LearningStats({
    required this.totalXp,
    required this.completedLessons,
    required this.studyDays,
    required this.currentStreak,
    required this.longestStreak,
  });

  /// Total earned XP.
  final int totalXp;

  /// Number of distinct completed lessons.
  final int completedLessons;

  /// Number of distinct local study dates.
  final int studyDays;

  /// Consecutive study days ending today or yesterday.
  final int currentStreak;

  /// Longest historical sequence of study days.
  final int longestStreak;
}

/// One recent incorrect answer available for focused review.
class RecentMistake {
  /// Creates a recent mistake.
  const RecentMistake({
    required this.lessonId,
    required this.exerciseId,
    required this.submittedAnswer,
    required this.occurredAt,
  });

  /// Lesson containing the exercise.
  final String lessonId;

  /// Stable exercise ID.
  final String exerciseId;

  /// Learner's submitted answer.
  final String submittedAnswer;

  /// UTC attempt time.
  final DateTime occurredAt;
}

/// Platform-independent persistence contract.
abstract interface class ProgressRepository {
  /// Records every submitted answer with its grading context.
  Future<void> recordAttempt({
    required String lessonId,
    required String exerciseId,
    required String submittedAnswer,
    required bool correct,
    required int incorrectBefore,
    required DateTime occurredAt,
  });

  /// Saves an incomplete or completed lesson checkpoint.
  Future<void> saveLessonProgress(LessonProgress progress);

  /// Loads all lesson checkpoints.
  Future<List<LessonProgress>> loadLessonProgress();

  /// Returns local aggregate statistics.
  Future<LearningStats> loadStats();

  /// Loads recent incorrect attempts, newest first.
  Future<List<RecentMistake>> loadRecentMistakes({int limit = 20});
}
