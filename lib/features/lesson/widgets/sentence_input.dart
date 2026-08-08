import 'package:crolingo/core/theme/app_colors.dart';
import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/features/lesson/widgets/exercise_answer.dart';
import 'package:flutter/material.dart';

/// Builds a Croatian sentence from shuffled tiles.
class SentenceInput extends StatefulWidget {
  /// Creates a sentence-building input for one exercise.
  const SentenceInput({
    required this.exercise,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  /// Exercise supplying the selectable tiles.
  final Exercise exercise;

  /// Whether the learner may still change the sentence.
  final bool enabled;

  /// Reports the current sentence.
  final ExerciseAnswerChanged onChanged;

  @override
  State<SentenceInput> createState() => _SentenceInputState();
}

class _SentenceInputState extends State<SentenceInput> {
  final _selectedTiles = <String>[];

  void _update(void Function() action) {
    setState(action);
    widget.onChanged(
      ExerciseAnswer(
        value: _selectedTiles.join(' '),
        canSubmit: _selectedTiles.isNotEmpty,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.exercise.tiles.where(
      (tile) => !_selectedTiles.contains(tile),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Wrap(
            spacing: 8,
            children: [
              for (final tile in _selectedTiles)
                ActionChip(
                  label: Text(tile),
                  onPressed: widget.enabled
                      ? () => _update(() => _selectedTiles.remove(tile))
                      : null,
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            for (final tile in remaining)
              ActionChip(
                label: Text(tile),
                onPressed: widget.enabled
                    ? () => _update(() => _selectedTiles.add(tile))
                    : null,
              ),
          ],
        ),
      ],
    );
  }
}
