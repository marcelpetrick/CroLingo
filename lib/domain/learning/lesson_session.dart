import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/domain/learning/answer_grader.dart';

/// Immutable state of one in-progress lesson.
class LessonSessionState {
  /// Creates lesson state.
  const LessonSessionState({
    required this.index,
    required this.xp,
    required this.incorrectAttempts,
    required this.submittedAnswer,
    required this.grade,
    required this.isComplete,
  });

  /// Initial state.
  const LessonSessionState.initial()
    : index = 0,
      xp = 0,
      incorrectAttempts = 0,
      submittedAnswer = null,
      grade = null,
      isComplete = false;

  /// Current exercise index.
  final int index;

  /// XP earned in this session, including the completion bonus.
  final int xp;

  /// Incorrect submissions for the current exercise.
  final int incorrectAttempts;

  /// Most recently submitted answer.
  final String? submittedAnswer;

  /// Most recent grade, or null while awaiting an answer.
  final GradeResult? grade;

  /// Whether every exercise was eventually solved.
  final bool isComplete;
}

/// Pure lesson state machine with unlimited retries.
class LessonSession {
  /// Starts a session for [lesson].
  LessonSession(this.lesson);

  /// Lesson being learned.
  final Lesson lesson;

  /// Current state.
  LessonSessionState state = const LessonSessionState.initial();

  /// Grades an answer for the current exercise.
  void submit(String answer) {
    if (state.isComplete || (state.grade?.isCorrect ?? false)) return;
    final grade = AnswerGrader.grade(lesson.exercises[state.index], answer);
    final earned = grade.isCorrect
        ? (10 - 2 * state.incorrectAttempts).clamp(2, 10)
        : 0;
    state = LessonSessionState(
      index: state.index,
      xp: state.xp + earned,
      incorrectAttempts: grade.isCorrect
          ? state.incorrectAttempts
          : state.incorrectAttempts + 1,
      submittedAnswer: answer,
      grade: grade,
      isComplete: false,
    );
  }

  /// Clears incorrect feedback so the same exercise can be retried.
  void retry() {
    if (state.grade?.isCorrect ?? true) return;
    state = LessonSessionState(
      index: state.index,
      xp: state.xp,
      incorrectAttempts: state.incorrectAttempts,
      submittedAnswer: null,
      grade: null,
      isComplete: false,
    );
  }

  /// Advances after correctness, adding ten completion XP at the end.
  void continueAfterCorrect() {
    if (state.grade?.isCorrect != true) return;
    final last = state.index == lesson.exercises.length - 1;
    state = LessonSessionState(
      index: last ? state.index : state.index + 1,
      xp: state.xp + (last ? 10 : 0),
      incorrectAttempts: 0,
      submittedAnswer: null,
      grade: null,
      isComplete: last,
    );
  }
}
