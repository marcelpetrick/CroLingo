import 'package:crolingo/app/providers.dart';
import 'package:crolingo/core/theme/app_colors.dart';
import 'package:crolingo/domain/progress/progress_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _lessons = [
  ('begrussen', 'Begrüßen'),
  ('vorstellen', 'Sich vorstellen'),
  ('befinden', 'Befinden'),
  ('hoflichkeit', 'Höflich sein'),
  ('ja-nein', 'Ja und nein'),
];

/// Sequential Adriatic-journey learning path.
class LearningPathScreen extends ConsumerStatefulWidget {
  /// Creates the learning path.
  const LearningPathScreen({super.key});

  @override
  ConsumerState<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends ConsumerState<LearningPathScreen> {
  late Future<List<LessonProgress>> _progress;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _progress = ref.read(progressRepositoryProvider).loadLessonProgress();
  }

  Future<void> _open(String lessonId) async {
    await context.push('/lesson/$lessonId');
    if (mounted) setState(_reload);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<LessonProgress>>(
    future: _progress,
    builder: (context, snapshot) {
      final completed =
          snapshot.data
              ?.where((item) => item.completedAt != null)
              .map((item) => item.lessonId)
              .toSet() ??
          <String>{};
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Text(
            'Dein Lernweg',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 6),
          const Text('Einheit 1 · Erste Worte'),
          const SizedBox(height: 20),
          const _UnitBanner(),
          const SizedBox(height: 28),
          for (var index = 0; index < _lessons.length; index++)
            _LessonNode(
              number: index + 1,
              title: _lessons[index].$2,
              completed: completed.contains(_lessons[index].$1),
              unlocked:
                  index == 0 || completed.contains(_lessons[index - 1].$1),
              onTap: () => _open(_lessons[index].$1),
            ),
        ],
      );
    },
  );
}

class _UnitBanner extends StatelessWidget {
  const _UnitBanner();

  @override
  Widget build(BuildContext context) => DecoratedBox(
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

class _LessonNode extends StatelessWidget {
  const _LessonNode({
    required this.number,
    required this.title,
    required this.completed,
    required this.unlocked,
    required this.onTap,
  });

  final int number;
  final String title;
  final bool completed;
  final bool unlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(left: number.isEven ? 78 : 22, bottom: 22),
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: unlocked ? onTap : null,
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: completed
                  ? AppColors.success
                  : unlocked
                  ? AppColors.primary
                  : AppColors.selectedSurface,
              border: Border.all(
                color: unlocked ? AppColors.primaryPressed : AppColors.border,
                width: 2,
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              completed
                  ? Icons.check_rounded
                  : unlocked
                  ? Icons.play_arrow_rounded
                  : Icons.lock_outline_rounded,
              color: unlocked ? Colors.white : AppColors.slate,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Lektion $number · $title',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    ),
  );
}
