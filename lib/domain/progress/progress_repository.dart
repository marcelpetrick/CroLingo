import 'package:crolingo/domain/course/course.dart';

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
    required this.startedOn,
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

  /// Local calendar date of the first completed study day.
  final DateTime? startedOn;
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

/// One concept and recall direction whose scheduled review is due.
class DueReview {
  /// Creates a due-review entry.
  const DueReview({
    required this.conceptId,
    required this.dimension,
    required this.lessonId,
    required this.exerciseId,
    required this.due,
  });

  /// Concept the learner owes a review of.
  final String conceptId;

  /// Ability being reviewed; the same word is scheduled per direction.
  final MasteryDimension dimension;

  /// Lesson containing the exercise chosen to practise this concept.
  final String lessonId;

  /// Exercise chosen to practise this concept, not the key it is stored under.
  final String exerciseId;

  /// UTC due time.
  final DateTime due;
}

/// One persisted answer attempt used for learning analytics.
class ExerciseAttempt {
  /// Creates an immutable attempt snapshot.
  const ExerciseAttempt({
    required this.exerciseId,
    required this.correct,
    required this.incorrectBefore,
    required this.occurredAt,
  });

  /// Stable exercise ID.
  final String exerciseId;

  /// Whether this submission was accepted.
  final bool correct;

  /// Number of errors already made on this exercise in the session.
  final int incorrectBefore;

  /// UTC submission time.
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

  /// Reconstructs and returns currently due FSRS reviews.
  ///
  /// Scheduling is keyed by concept and recall direction, which only [course]
  /// can resolve from a stored attempt, so content is supplied by the caller
  /// rather than held by the repository.
  Future<List<DueReview>> loadDueReviews({
    required Course course,
    DateTime? now,
  });

  /// Loads persisted attempts for local mastery calculations.
  Future<List<ExerciseAttempt>> loadAttemptHistory();
}
