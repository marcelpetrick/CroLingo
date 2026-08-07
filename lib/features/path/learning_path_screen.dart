import 'package:crolingo/app/providers.dart';
import 'package:crolingo/core/theme/app_colors.dart';
import 'package:crolingo/data/course/asset_course_repository.dart';
import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/domain/progress/progress_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Sequential Adriatic-journey learning path.
class LearningPathScreen extends ConsumerStatefulWidget {
  /// Creates the learning path.
  const LearningPathScreen({this.course, super.key});

  /// Optional course source for deterministic tests.
  final Future<Course>? course;

  @override
  ConsumerState<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends ConsumerState<LearningPathScreen> {
  late Future<_PathData> _data;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _data = _loadData();
  }

  Future<_PathData> _loadData() async => _PathData(
    await (widget.course ?? AssetCourseRepository().load()),
    await ref.read(progressRepositoryProvider).loadLessonProgress(),
  );

  List<Widget> _sections(Course course, Set<String> completed) {
    final children = <Widget>[];
    String? previousLessonId;
    for (var unitIndex = 0; unitIndex < course.units.length; unitIndex++) {
      final unit = course.units[unitIndex];
      final unitCompleted = unit.lessons.every(
        (lesson) => completed.contains(lesson.id),
      );
      if (unitIndex > 0) children.add(const SizedBox(height: 12));
      children
        ..add(Text('Einheit ${unitIndex + 1} · ${unit.title}'))
        ..add(const SizedBox(height: 20))
        ..add(
          _UnitBanner(
            completed: unitCompleted,
            description: unit.description,
          ),
        )
        ..add(const SizedBox(height: 28));
      for (
        var lessonIndex = 0;
        lessonIndex < unit.lessons.length;
        lessonIndex++
      ) {
        final lesson = unit.lessons[lessonIndex];
        final unlocked =
            previousLessonId == null || completed.contains(previousLessonId);
        children.add(
          _LessonNode(
            number: lessonIndex + 1,
            title: lesson.title,
            completed: completed.contains(lesson.id),
            unlocked: unlocked,
            onTap: () => _open(lesson.id),
          ),
        );
        previousLessonId = lesson.id;
      }
    }
    return children;
  }

  Future<void> _open(String lessonId) async {
    await context.push('/lesson/$lessonId');
    if (mounted) setState(_reload);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<_PathData>(
    future: _data,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Center(
          child: Text('Lernweg konnte nicht geladen werden.'),
        );
      }
      final data = snapshot.data;
      if (data == null) return const Center(child: CircularProgressIndicator());
      final completed = data.progress
          .where((item) => item.completedAt != null)
          .map((item) => item.lessonId)
          .toSet();
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Text(
            'Dein Lernweg',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 6),
          ..._sections(data.course, completed),
        ],
      );
    },
  );
}

class _UnitBanner extends StatelessWidget {
  const _UnitBanner({required this.completed, required this.description});

  final bool completed;
  final String description;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Icon(
            completed
                ? Icons.workspace_premium_rounded
                : Icons.waving_hand_rounded,
            color: completed ? AppColors.crown : Colors.white,
            size: 34,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              completed
                  ? 'Goldkrone verdient! Einheit abgeschlossen.'
                  : description,
              style: const TextStyle(
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

class _PathData {
  const _PathData(this.course, this.progress);

  final Course course;
  final List<LessonProgress> progress;
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
