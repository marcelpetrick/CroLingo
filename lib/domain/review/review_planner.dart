import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/domain/progress/progress_repository.dart';
import 'package:crolingo/domain/review/review_scheduler.dart';

/// Turns stored attempts into the reviews a learner owes right now.
///
/// Memory is tracked per concept and recall direction rather than per
/// exercise. Knowing `hvala` from German is a different ability from
/// recognising it in Croatian, and both are abilities of the word rather than
/// of the exercise that happened to practise it. Keying by exercise made every
/// newly authored exercise start cold even when the learner had known the word
/// for months, which is the wrong answer as the course grows.
abstract final class ReviewPlanner {
  /// Returns the reviews due at [now], soonest first.
  static List<DueReview> due({
    required Course course,
    required List<ExerciseAttempt> attempts,
    required ReviewScheduler scheduler,
    DateTime? now,
  }) {
    final catalogue = _Catalogue.of(course);
    final states = <_Key, ReviewSchedule>{};
    final lastPractised = <String, DateTime>{};

    for (final attempt in attempts) {
      if (!attempt.correct) continue;
      final exercise = catalogue.exercises[attempt.exerciseId];
      // An exercise removed or renamed since the attempt was stored still has
      // history. Its concepts are unknown now, so it can only be skipped.
      if (exercise == null) continue;

      final at = attempt.occurredAt.toUtc();
      lastPractised[attempt.exerciseId] = at;
      for (final conceptId in exercise.conceptIds) {
        final key = (
          conceptId: conceptId,
          dimension: exercise.masteryDimension,
        );
        states[key] = scheduler.review(
          previousState: states[key]?.state,
          priorIncorrectAttempts: attempt.incorrectBefore,
          reviewedAt: at,
        );
      }
    }

    final current = (now ?? DateTime.now()).toUtc();
    final due = <DueReview>[];
    for (final entry in states.entries) {
      if (entry.value.due.isAfter(current)) continue;
      final exercise = catalogue.pick(entry.key, lastPractised);
      due.add(
        DueReview(
          conceptId: entry.key.conceptId,
          dimension: entry.key.dimension,
          lessonId: catalogue.lessons[exercise.id]!,
          exerciseId: exercise.id,
          due: entry.value.due,
        ),
      );
    }
    return due..sort((left, right) => left.due.compareTo(right.due));
  }
}

typedef _Key = ({String conceptId, MasteryDimension dimension});

/// Content indexed the way scheduling needs to read it.
class _Catalogue {
  const new({
    required this.exercises,
    required this.lessons,
    required this.byKey,
  });

  factory of(Course course) {
    final exercises = <String, Exercise>{};
    final lessons = <String, String>{};
    final byKey = <_Key, List<Exercise>>{};
    for (final unit in course.units) {
      for (final lesson in unit.lessons) {
        for (final exercise in lesson.exercises) {
          exercises[exercise.id] = exercise;
          lessons[exercise.id] = lesson.id;
          for (final conceptId in exercise.conceptIds) {
            final key = (
              conceptId: conceptId,
              dimension: exercise.masteryDimension,
            );
            (byKey[key] ??= <Exercise>[]).add(exercise);
          }
        }
      }
    }
    return _Catalogue(exercises: exercises, lessons: lessons, byKey: byKey);
  }

  final Map<String, Exercise> exercises;
  final Map<String, String> lessons;
  final Map<_Key, List<Exercise>> byKey;

  /// Chooses what to actually put in front of the learner for [key].
  ///
  /// A concept practised by several exercises should not drill the same one
  /// forever, so an exercise never attempted comes first and otherwise the
  /// least recently practised wins. Authored order breaks ties, which keeps
  /// the result stable rather than merely arbitrary.
  Exercise pick(_Key key, Map<String, DateTime> lastPractised) {
    // Every scheduled key was produced by an exercise in this catalogue, so
    // the list exists and is never empty.
    final candidates = byKey[key]!;
    var best = candidates.first;
    final firstPractised = lastPractised[best.id];
    if (firstPractised == null) return best;
    var bestAt = firstPractised;
    for (final candidate in candidates.skip(1)) {
      final at = lastPractised[candidate.id];
      if (at == null) return candidate;
      if (at.isBefore(bestAt)) {
        best = candidate;
        bestAt = at;
      }
    }
    return best;
  }
}
