import 'package:crolingo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Close control, lesson progress bar, and earned XP.
class LessonHeader extends StatelessWidget {
  /// Creates a lesson header.
  const LessonHeader({required this.progress, required this.xp, super.key});

  /// Completed fraction of the lesson, between 0 and 1.
  final double progress;

  /// XP earned so far in this lesson.
  final int xp;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 10, 18, 8),
    child: Row(
      children: [
        IconButton(
          tooltip: 'Lektion schließen',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close_rounded),
        ),
        Expanded(
          child: Semantics(
            label: '${(progress * 100).round()} Prozent abgeschlossen',
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.bolt_rounded, color: AppColors.crown),
        Text('$xp XP', style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    ),
  );
}
