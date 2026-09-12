import 'package:crolingo/domain/course/course.dart';
import 'package:unorm_dart/unorm_dart.dart' as unicode;

/// Result of grading one submitted text answer.
class GradeResult {
  /// Creates a grade result.
  const new({required this.isCorrect, required this.correction});

  /// Whether the answer matches an authored accepted form.
  final bool isCorrect;

  /// Canonical answer shown as correction.
  final String correction;
}

/// Deterministic, offline text grader.
abstract final class AnswerGrader {
  // Marks a learner may reasonably omit or add without being wrong. Letters
  // stay untouched: `č` is not `c`, and `dán` is not `dan`. Hyphens stay too,
  // because a German compound changes meaning when its hyphen disappears.
  static final RegExp _ignorablePunctuation = RegExp('[.,!?;:…’‘“”„«»\'"()]');

  static final RegExp _whitespace = RegExp(r'\s+');

  /// Grades [submitted] without fuzzy guessing or diacritic removal.
  static GradeResult grade(Exercise exercise, String submitted) {
    final normalized = normalize(submitted);
    return GradeResult(
      // An empty submission is never an answer, whatever the content says.
      isCorrect:
          normalized.isNotEmpty &&
          exercise.acceptedAnswers.any(
            (answer) => normalize(answer) == normalized,
          ),
      correction: exercise.acceptedAnswers.first,
    );
  }

  /// Reduces [value] to the form the grader compares.
  ///
  /// Public so content validation can reject authored answers this would fold
  /// into one another; the validator and the grader must agree on equality or
  /// the check would be theatre.
  static String normalize(String value) => unicode
      .nfc(value)
      .toLowerCase()
      // Dropped rather than turned into a space: German learners write both
      // `geht's` and `gehts`, and only dropping makes those the same answer.
      .replaceAll(_ignorablePunctuation, '')
      .replaceAll(_whitespace, ' ')
      .trim();
}
