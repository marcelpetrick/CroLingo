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
      FutureBuilder<List<RecentMistake>>(
        future: ref.read(progressRepositoryProvider).loadRecentMistakes(),
        builder: (context, snapshot) {
          final mistakes = snapshot.data ?? const <RecentMistake>[];
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
              if (mistakes.isEmpty)
                const _EmptyReview()
              else ...[
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
                      onTap: () => context.push('/lesson/${mistake.lessonId}'),
                    ),
                  ),
              ],
              const SizedBox(height: 18),
              const _ReviewOption(
                icon: Icons.schedule_rounded,
                title: 'Empfohlen & fällig',
                subtitle:
                    'Der Zeitplan folgt im nächsten Lernalgorithmus-Loop.',
                enabled: false,
              ),
              _ReviewOption(
                icon: Icons.error_outline_rounded,
                title: 'Letzte Fehler',
                subtitle: mistakes.isEmpty
                    ? 'Noch keine Fehler gespeichert.'
                    : '${mistakes.length} zum erneuten Üben',
                enabled: mistakes.isNotEmpty,
              ),
              const _ReviewOption(
                icon: Icons.auto_awesome_outlined,
                title: 'Neu gelernt',
                subtitle: 'Wiederhole abgeschlossene Lektionen im Lernweg.',
                enabled: true,
              ),
            ],
          );
        },
      );
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
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;

  @override
  Widget build(BuildContext context) => ListTile(
    enabled: enabled,
    leading: Icon(icon, color: AppColors.primary),
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: Icon(enabled ? Icons.chevron_right_rounded : Icons.lock_outline),
  );
}
