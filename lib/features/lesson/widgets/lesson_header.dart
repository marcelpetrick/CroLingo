import 'package:crolingo/core/motion/app_motion.dart';
import 'package:crolingo/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Close control, lesson progress bar, and earned XP.
class LessonHeader extends StatelessWidget {
  /// Creates a lesson header.
  const new({required this.progress, required this.xp, super.key});

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
            child: ExcludeSemantics(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: AppMotion.responsive(context, AppMotion.standard),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => LinearProgressIndicator(
                  value: value,
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Semantics(
          label: '$xp Erfahrungspunkte',
          child: ExcludeSemantics(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: context.palette.selectedSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.bolt_rounded, color: context.palette.crown),
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: xp),
                    duration: AppMotion.responsive(context, AppMotion.standard),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) => Text(
                      '$value XP',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
