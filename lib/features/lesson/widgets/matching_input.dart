import 'package:crolingo/core/widgets/speech_button.dart';
import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/features/lesson/widgets/exercise_answer.dart';
import 'package:flutter/material.dart';

/// Pairs each Croatian word with its German meaning.
class MatchingInput extends StatefulWidget {
  /// Creates a matching input for one exercise.
  const MatchingInput({
    required this.exercise,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  /// Exercise supplying the Croatian/German pairs.
  final Exercise exercise;

  /// Whether the learner may still change the selection.
  final bool enabled;

  /// Reports the current selection.
  final ExerciseAnswerChanged onChanged;

  @override
  State<MatchingInput> createState() => _MatchingInputState();
}

class _MatchingInputState extends State<MatchingInput> {
  final _matching = <String, String>{};

  void _select(String croatian, String german) {
    setState(() => _matching[croatian] = german);
    final complete = widget.exercise.pairs.every(
      (pair) => _matching[pair.croatian] == pair.german,
    );
    widget.onChanged(
      ExerciseAnswer(
        value: complete ? 'vollständig' : 'nicht vollständig',
        canSubmit: _matching.length == widget.exercise.pairs.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final choices = widget.exercise.pairs.map((pair) => pair.german).toList();
    return Column(
      children: [
        for (final pair in widget.exercise.pairs)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        pair.croatian,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    SpeechButton(text: pair.croatian),
                  ],
                ),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _matching[pair.croatian],
                  decoration: const InputDecoration(
                    labelText: 'Deutsche Bedeutung',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final choice in choices.reversed)
                      DropdownMenuItem(value: choice, child: Text(choice)),
                  ],
                  onChanged: widget.enabled
                      ? (value) {
                          if (value != null) _select(pair.croatian, value);
                        }
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
