import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/domain/progress/progress_repository.dart';

/// Mastery result for one course concept.
class ConceptMastery {
  /// Creates a mastery snapshot.
  const ConceptMastery({required this.concept, required this.scores});

  /// Vocabulary or grammar concept being measured.
  final Concept concept;

  /// Scores from 0 to 1 for dimensions the learner has practiced.
  final Map<MasteryDimension, double> scores;

  /// Mean score across practiced dimensions, or zero before first practice.
  double get overall => scores.isEmpty
      ? 0
      : scores.values.reduce((left, right) => left + right) / scores.length;
}

/// Derives replaceable mastery analytics from durable answer history.
abstract final class ConceptMasteryCalculator {
  /// Calculates every concept in course order.
  static List<ConceptMastery> calculate(
    Course course,
    Iterable<ExerciseAttempt> attempts,
  ) {
    final exercises = <String, Exercise>{
      for (final exercise
          in course.units
              .expand((unit) => unit.lessons)
              .expand((lesson) => lesson.exercises))
        exercise.id: exercise,
    };
    final totals = <String, Map<MasteryDimension, _Score>>{};
    for (final attempt in attempts.where((item) => item.correct)) {
      final exercise = exercises[attempt.exerciseId];
      if (exercise == null) continue;
      final value = switch (attempt.incorrectBefore) {
        0 => 1.0,
        1 => 0.67,
        _ => 0.33,
      };
      for (final conceptId in exercise.conceptIds) {
        totals
            .putIfAbsent(conceptId, () => {})
            .update(
              exercise.masteryDimension,
              (score) => score.add(value),
              ifAbsent: () => _Score(value, 1),
            );
      }
    }
    return [
      for (final concept in course.concepts)
        ConceptMastery(
          concept: concept,
          scores: {
            for (final entry in (totals[concept.id] ?? {}).entries)
              entry.key: entry.value.total / entry.value.count,
          },
        ),
    ];
  }
}

class _Score {
  const _Score(this.total, this.count);

  final double total;
  final int count;

  _Score add(double value) => _Score(total + value, count + 1);
}
