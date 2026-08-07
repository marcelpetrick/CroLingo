import 'package:crolingo/domain/course/course.dart';
import 'package:unorm_dart/unorm_dart.dart' as unicode;

/// Result of grading one submitted text answer.
class GradeResult {
  /// Creates a grade result.
  const GradeResult({required this.isCorrect, required this.correction});

  /// Whether the answer matches an authored accepted form.
  final bool isCorrect;

  /// Canonical answer shown as correction.
  final String correction;
}

/// Deterministic, offline text grader.
abstract final class AnswerGrader {
  /// Grades [submitted] without fuzzy guessing or diacritic removal.
  static GradeResult grade(Exercise exercise, String submitted) {
    final normalized = _normalize(submitted);
    return GradeResult(
      isCorrect: exercise.acceptedAnswers.any(
        (answer) => _normalize(answer) == normalized,
      ),
      correction: exercise.acceptedAnswers.first,
    );
  }

  static String _normalize(String value) => unicode
      .nfc(value)
      .trim()
      .toLowerCase()
      .replaceAll(
        RegExp(r'\s+'),
        ' ',
      );
}
