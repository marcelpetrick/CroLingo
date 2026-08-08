import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/features/lesson/widgets/exercise_answer.dart';
import 'package:flutter/material.dart';

/// Typed answer shared by translation and fill-in-the-blank exercises.
class TextAnswerInput extends StatefulWidget {
  /// Creates a typed-answer input for one exercise.
  const TextAnswerInput({
    required this.exercise,
    required this.enabled,
    required this.onChanged,
    required this.onSubmitted,
    super.key,
  });

  /// Exercise supplying the expected answer language.
  final Exercise exercise;

  /// Whether the learner may still edit the answer.
  final bool enabled;

  /// Reports the typed answer.
  final ExerciseAnswerChanged onChanged;

  /// Submits the typed answer straight from the keyboard.
  final ValueChanged<String> onSubmitted;

  @override
  State<TextAnswerInput> createState() => _TextAnswerInputState();
}

class _TextAnswerInputState extends State<TextAnswerInput> {
  final _controller = TextEditingController();

  bool get _canSubmit => _controller.text.trim().isNotEmpty;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    key: const Key('answerField'),
    controller: _controller,
    enabled: widget.enabled,
    autocorrect: false,
    enableSuggestions: false,
    textCapitalization: TextCapitalization.sentences,
    onChanged: (value) => widget.onChanged(
      ExerciseAnswer(value: value, canSubmit: value.trim().isNotEmpty),
    ),
    onSubmitted: _canSubmit && widget.enabled ? widget.onSubmitted : null,
    decoration: InputDecoration(
      labelText:
          widget.exercise.masteryDimension == MasteryDimension.croatianToGerman
          ? 'Deine Antwort auf Deutsch'
          : 'Deine Antwort auf Kroatisch',
      border: const OutlineInputBorder(),
    ),
  );
}
