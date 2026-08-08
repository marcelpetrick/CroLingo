/// Current answer reported by one exercise-family input.
class ExerciseAnswer {
  /// Creates an answer snapshot.
  const ExerciseAnswer({required this.value, required this.canSubmit});

  /// Empty answer used before the learner interacts with an exercise.
  static const empty = ExerciseAnswer(value: '', canSubmit: false);

  /// Text handed to the grader when the learner submits.
  final String value;

  /// Whether the input holds enough to be graded.
  final bool canSubmit;
}

/// Reports the answer held by an exercise-family input.
typedef ExerciseAnswerChanged = void Function(ExerciseAnswer answer);
