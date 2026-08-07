import 'package:crolingo/app/providers.dart';
import 'package:crolingo/core/theme/app_colors.dart';
import 'package:crolingo/core/widgets/crow_mark.dart';
import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/domain/learning/course_progression.dart';
import 'package:crolingo/domain/progress/progress_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Learner dashboard and continuation entry point.
class HomeScreen extends ConsumerStatefulWidget {
  /// Creates the dashboard.
  const HomeScreen({this.course, super.key});

  /// Optional deterministic course source for tests.
  final Future<Course>? course;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late Future<_HomeData> _data;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _data = _load();
  }

  Future<_HomeData> _load() async {
    final course = await (widget.course ?? ref.read(courseProvider.future));
    final repository = ref.read(progressRepositoryProvider);
    final progress = await repository.loadLessonProgress();
    return _HomeData(
      position: CourseProgression.next(course, progress),
      courseTitle: course.title,
    );
  }

  Future<void> _open(CoursePosition? position) async {
    if (position == null) {
      context.go('/path');
      return;
    }
    await context.push('/lesson/${position.lesson.id}');
    if (mounted) setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        const _Header(),
        const SizedBox(height: 24),
        Text(
          'Bok! Bereit für Kroatisch?',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Kleine Schritte, klare Antworten und so viele Versuche, '
          'wie du brauchst.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        FutureBuilder<_HomeData>(
          future: _data,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Dein nächster Schritt konnte nicht geladen werden.',
                  ),
                ),
              );
            }
            final data = snapshot.data;
            if (data == null) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(28),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }
            return _ContinuationCard(
              data: data,
              onOpen: () => _open(data.position),
            );
          },
        ),
        const SizedBox(height: 16),
        const _Stats(),
      ],
    );
  }
}

class _ContinuationCard extends StatelessWidget {
  const _ContinuationCard({required this.data, required this.onOpen});

  final _HomeData data;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final position = data.position;
    final complete = position == null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  complete
                      ? Icons.workspace_premium_rounded
                      : Icons.flag_rounded,
                  color: complete ? AppColors.crown : AppColors.accent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    complete
                        ? 'Kurs abgeschlossen'
                        : 'Einheit ${position.unitNumber} · '
                              '${position.unit.title}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              complete ? data.courseTitle : position.lesson.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              complete
                  ? 'Du hast alle verfügbaren Lektionen abgeschlossen.'
                  : position.isResuming
                  ? 'Setze Lektion ${position.lessonNumber} an deinem '
                        'gespeicherten Punkt fort.'
                  : position.unit.description,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onOpen,
              icon: Icon(
                complete ? Icons.route_rounded : Icons.play_arrow_rounded,
              ),
              label: Text(
                complete
                    ? 'Lernweg ansehen'
                    : position.isResuming
                    ? 'Weiterlernen'
                    : 'Lektion starten',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeData {
  const _HomeData({required this.position, required this.courseTitle});

  final CoursePosition? position;
  final String courseTitle;
}

class _Stats extends ConsumerWidget {
  const _Stats();

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      FutureBuilder<LearningStats>(
        future: ref.read(progressRepositoryProvider).loadStats(),
        builder: (context, snapshot) {
          final stats = snapshot.data;
          return Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department_outlined,
                  value: '${stats?.currentStreak ?? 0}',
                  label: 'Tage Serie',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.bolt_rounded,
                  value: '${stats?.totalXp ?? 0}',
                  label: 'XP',
                ),
              ),
            ],
          );
        },
      );
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        CrowMark(size: 58),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CroLingo',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              Text(
                '🇩🇪 Deutsch → 🇭🇷 Hrvatski',
                style: TextStyle(color: AppColors.slate),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: Theme.of(context).textTheme.titleLarge),
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
