import 'package:crolingo/app/providers.dart';
import 'package:crolingo/core/motion/app_motion.dart';
import 'package:crolingo/core/theme/app_theme.dart';
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
  const new({this.course, super.key});

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
        const MotionEntrance(child: _Header()),
        const SizedBox(height: 24),
        MotionEntrance(
          delay: const Duration(milliseconds: 45),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
            ],
          ),
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
            return MotionEntrance(
              delay: const Duration(milliseconds: 90),
              child: _ContinuationCard(
                data: data,
                onOpen: () => _open(data.position),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        const MotionEntrance(
          delay: Duration(milliseconds: 135),
          child: _Stats(),
        ),
      ],
    );
  }
}

class _ContinuationCard extends StatelessWidget {
  const new({required this.data, required this.onOpen});

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
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: context.palette.selectedSurface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    complete
                        ? Icons.workspace_premium_rounded
                        : Icons.flag_rounded,
                    color: complete
                        ? context.palette.crown
                        : context.palette.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    complete
                        ? 'Kurs abgeschlossen'
                        : 'Einheit ${position.unitNumber} · '
                              '${position.unit.title}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: context.palette.slate,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
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
  const new({required this.position, required this.courseTitle});

  final CoursePosition? position;
  final String courseTitle;
}

class _Stats extends ConsumerWidget {
  const new();

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

class _Header extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref
        .watch(appVersionProvider)
        .when(
          data: (value) => value,
          error: (error, stackTrace) => null,
          loading: () => null,
        );
    return Row(
      children: [
        const CrowMark(size: 58),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CroLingo',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              Text(
                '🇩🇪 Deutsch → 🇭🇷 Hrvatski',
                style: TextStyle(color: context.palette.slate),
              ),
              if (version != null)
                Semantics(
                  label: 'Installierte Version $version',
                  child: ExcludeSemantics(
                    child: Text(
                      'Version $version',
                      style: TextStyle(
                        color: context.palette.slate,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const new({required this.icon, required this.value, required this.label});

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
            Icon(icon, color: context.palette.primary),
            const SizedBox(width: 10),
            // Two stat cards share a phone width, so the label has to be
            // allowed to wrap instead of overflowing its card.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: Theme.of(context).textTheme.titleLarge),
                  Text(label, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
