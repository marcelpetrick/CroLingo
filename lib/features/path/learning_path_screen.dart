import 'package:crolingo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Sequential Adriatic-journey learning path.
class LearningPathScreen extends StatelessWidget {
  /// Creates the learning path.
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Text('Dein Lernweg', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 6),
        const Text('Einheit 1 · Erste Worte'),
        const SizedBox(height: 20),
        const _UnitBanner(),
        const SizedBox(height: 28),
        ...List.generate(
          5,
          (index) => _LessonNode(number: index + 1, current: index == 0),
        ),
      ],
    );
  }
}

class _UnitBanner extends StatelessWidget {
  const _UnitBanner();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Padding(
        padding: EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(Icons.waving_hand_rounded, color: Colors.white, size: 34),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                'Begrüße Menschen und stelle dich vor.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonNode extends StatelessWidget {
  const _LessonNode({required this.number, required this.current});

  final int number;
  final bool current;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: number.isEven ? 78 : 22, bottom: 22),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: current ? AppColors.primary : AppColors.selectedSurface,
              border: Border.all(
                color: current ? AppColors.primaryPressed : AppColors.border,
                width: 2,
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              current ? Icons.play_arrow_rounded : Icons.lock_outline_rounded,
              color: current ? Colors.white : AppColors.slate,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              current ? 'Lektion $number · Begrüßen' : 'Lektion $number',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
