import 'package:crolingo/core/theme/app_theme.dart';
import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/features/lesson/widgets/exercise_answer.dart';
import 'package:flutter/material.dart';

/// Builds a Croatian sentence from shuffled tiles.
class SentenceInput extends StatefulWidget {
  /// Creates a sentence-building input for one exercise.
  const new({
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
  final _selectedTileIndices = <int>[];

  void _update(void Function() action) {
    setState(action);
    widget.onChanged(
      ExerciseAnswer(
        value: _selectedTileIndices
            .map((index) => widget.exercise.tiles[index])
            .join(' '),
        canSubmit: _selectedTileIndices.isNotEmpty,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.exercise.tiles.indexed.where(
      (entry) => !_selectedTileIndices.contains(entry.$1),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: context.palette.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Wrap(
            spacing: 8,
            children: [
              for (final index in _selectedTileIndices)
                ActionChip(
                  key: ValueKey('selectedTile-$index'),
                  label: Text(widget.exercise.tiles[index]),
                  onPressed: widget.enabled
                      ? () => _update(() => _selectedTileIndices.remove(index))
                      : null,
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            for (final entry in remaining)
              ActionChip(
                key: ValueKey('availableTile-${entry.$1}'),
                label: Text(entry.$2),
                onPressed: widget.enabled
                    ? () => _update(() => _selectedTileIndices.add(entry.$1))
                    : null,
              ),
          ],
        ),
      ],
    );
  }
}
