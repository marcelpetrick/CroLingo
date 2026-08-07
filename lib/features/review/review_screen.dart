import 'package:crolingo/app/providers.dart';
import 'package:crolingo/core/theme/app_colors.dart';
import 'package:crolingo/core/widgets/crow_mark.dart';
import 'package:crolingo/domain/progress/progress_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Focused review entry point based on stored mistakes.
class ReviewScreen extends ConsumerWidget {
  /// Creates the review screen.
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      FutureBuilder<_ReviewData>(
        future: _loadReview(ref.read(progressRepositoryProvider)),
        builder: (context, snapshot) {
          final mistakes = snapshot.data?.mistakes ?? const <RecentMistake>[];
          final due = snapshot.data?.due ?? const <DueReview>[];
          final recent = snapshot.data?.recent ?? const <LessonProgress>[];
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Wiederholen',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Übe gezielt, was noch nicht sicher sitzt. Deine Daten '
                'bleiben dabei auf diesem Gerät.',
              ),
              const SizedBox(height: 24),
              if (mistakes.isEmpty && due.isEmpty && recent.isEmpty)
                const _EmptyReview()
              else ...[
                if (due.isNotEmpty) ...[
                  Text(
                    '${due.length} Übungen fällig',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  for (final item in due)
                    Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.schedule_rounded,
                          color: AppColors.primary,
                        ),
                        title: Text(_readableId(item.exerciseId)),
                        subtitle: const Text('Jetzt wiederholen'),
                        trailing: const Icon(Icons.play_arrow_rounded),
                        onTap: () => context.push('/lesson/${item.lessonId}'),
                      ),
                    ),
                  const SizedBox(height: 14),
                ],
                if (mistakes.isNotEmpty) ...[
                  Text(
                    '${mistakes.length} letzte Fehler',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  for (final mistake in mistakes)
                    Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.refresh_rounded,
                          color: AppColors.primary,
                        ),
                        title: Text(_readableId(mistake.exerciseId)),
                        subtitle: Text(
                          'Deine Antwort: ${mistake.submittedAnswer}',
                        ),
                        trailing: const Icon(Icons.play_arrow_rounded),
                        onTap: () =>
                            context.push('/lesson/${mistake.lessonId}'),
                      ),
                    ),
                ],
                if (recent.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    '${recent.length} neu gelernte Lektionen',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  for (final lesson in recent)
                    Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.auto_awesome_outlined,
                          color: AppColors.primary,
                        ),
                        title: Text(_readableId(lesson.lessonId)),
                        subtitle: const Text('Abgeschlossene Lektion üben'),
                        trailing: const Icon(Icons.play_arrow_rounded),
                        onTap: () => context.push('/lesson/${lesson.lessonId}'),
                      ),
                    ),
                ],
              ],
              const SizedBox(height: 18),
              _ReviewOption(
                icon: Icons.schedule_rounded,
                title: 'Empfohlen & fällig',
                subtitle: due.isEmpty
                    ? 'Im Moment ist nichts fällig.'
                    : '${due.length} Übungen warten',
                enabled: due.isNotEmpty,
                onTap: due.isEmpty
                    ? null
                    : () => context.push('/lesson/${due.first.lessonId}'),
              ),
              _ReviewOption(
                icon: Icons.error_outline_rounded,
                title: 'Letzte Fehler',
                subtitle: mistakes.isEmpty
                    ? 'Noch keine Fehler gespeichert.'
                    : '${mistakes.length} zum erneuten Üben',
                enabled: mistakes.isNotEmpty,
                onTap: mistakes.isEmpty
                    ? null
                    : () => context.push('/lesson/${mistakes.first.lessonId}'),
              ),
              _ReviewOption(
                icon: Icons.auto_awesome_outlined,
                title: 'Neu gelernt',
                subtitle: recent.isEmpty
                    ? 'Noch keine Lektion abgeschlossen.'
                    : '${recent.length} Lektionen erneut üben',
                enabled: recent.isNotEmpty,
                onTap: recent.isEmpty
                    ? null
                    : () => context.push('/lesson/${recent.first.lessonId}'),
              ),
            ],
          );
        },
      );
}

Future<_ReviewData> _loadReview(ProgressRepository repository) async {
  final recent =
      (await repository.loadLessonProgress())
          .where((lesson) => lesson.completedAt != null)
          .toList()
        ..sort(
          (left, right) => right.completedAt!.compareTo(left.completedAt!),
        );
  return _ReviewData(
    due: await repository.loadDueReviews(),
    mistakes: await repository.loadRecentMistakes(),
    recent: recent,
  );
}

class _ReviewData {
  const _ReviewData({
    required this.due,
    required this.mistakes,
    required this.recent,
  });

  final List<DueReview> due;
  final List<RecentMistake> mistakes;
  final List<LessonProgress> recent;
}

String _readableId(String value) {
  final words = value.split('-').where((word) => word.isNotEmpty).join(' ');
  return '${words[0].toUpperCase()}${words.substring(1)}';
}

class _EmptyReview extends StatelessWidget {
  const _EmptyReview();

  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(
      padding: EdgeInsets.all(22),
      child: Column(
        children: [
          CrowMark(size: 86),
          SizedBox(height: 16),
          Text(
            'Noch nichts fällig',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8),
          Text(
            'Fehler aus deinen Lektionen erscheinen hier automatisch.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _ReviewOption extends StatelessWidget {
  const _ReviewOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    enabled: enabled,
    onTap: onTap,
    leading: Icon(icon, color: AppColors.primary),
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: Icon(enabled ? Icons.chevron_right_rounded : Icons.lock_outline),
  );
}
