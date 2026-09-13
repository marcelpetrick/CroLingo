import 'package:crolingo/app/providers.dart';
import 'package:crolingo/core/theme/app_theme.dart';
import 'package:crolingo/core/widgets/crow_mark.dart';
import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/domain/progress/progress_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Focused review entry point based on stored mistakes.
class ReviewScreen extends ConsumerStatefulWidget {
  /// Creates the review screen.
  const new({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  late Future<_ReviewData> _review;

  @override
  void initState() {
    super.initState();
    _review = _loadReview(ref);
  }

  void _retry() => setState(() => _review = _loadReview(ref));

  @override
  Widget build(BuildContext context) => FutureBuilder<_ReviewData>(
    future: _review,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return Center(
          child: Semantics(
            label: 'Wiederholungen werden geladen',
            child: const CircularProgressIndicator(),
          ),
        );
      }
      if (snapshot.hasError) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Wiederholungen konnten nicht geladen werden.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _retry,
                  child: const Text('Erneut versuchen'),
                ),
              ],
            ),
          ),
        );
      }
      final data = snapshot.requireData;
      final mistakes = data.mistakes;
      final due = data.due;
      final recent = data.recent;
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Wiederholen', style: Theme.of(context).textTheme.headlineLarge),
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
                    leading: Icon(
                      Icons.schedule_rounded,
                      color: context.palette.primary,
                    ),
                    // The learner owes a word, not an exercise number.
                    title: Text(
                      data.concepts[item.conceptId]?.croatian ??
                          _readableId(item.conceptId),
                    ),
                    subtitle: Text(_dimensionLabel(item.dimension)),
                    trailing: const Icon(Icons.play_arrow_rounded),
                    onTap: () => context.push(
                      _reviewPath(item.lessonId, item.exerciseId),
                    ),
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
                    leading: Icon(
                      Icons.refresh_rounded,
                      color: context.palette.primary,
                    ),
                    title: Text(_readableId(mistake.exerciseId)),
                    subtitle: Text('Deine Antwort: ${mistake.submittedAnswer}'),
                    trailing: const Icon(Icons.play_arrow_rounded),
                    onTap: () => context.push(
                      _reviewPath(mistake.lessonId, mistake.exerciseId),
                    ),
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
                    leading: Icon(
                      Icons.auto_awesome_outlined,
                      color: context.palette.primary,
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
                : () => context.push(
                    _reviewPath(due.first.lessonId, due.first.exerciseId),
                  ),
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
                : () => context.push(
                    _reviewPath(
                      mistakes.first.lessonId,
                      mistakes.first.exerciseId,
                    ),
                  ),
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

Future<_ReviewData> _loadReview(WidgetRef ref) async {
  final repository = ref.read(progressRepositoryProvider);
  // Reviews are scheduled per concept, so the schedule cannot be read without
  // the content that says which concept an attempt practised.
  final course = await ref.read(courseProvider.future);
  final recent =
      (await repository.loadLessonProgress())
          .where((lesson) => lesson.completedAt != null)
          .toList()
        ..sort(
          (left, right) => right.completedAt!.compareTo(left.completedAt!),
        );
  return _ReviewData(
    due: await repository.loadDueReviews(course: course),
    mistakes: await repository.loadRecentMistakes(),
    recent: recent,
    concepts: {for (final concept in course.concepts) concept.id: concept},
  );
}

class _ReviewData {
  const new({
    required this.due,
    required this.mistakes,
    required this.recent,
    required this.concepts,
  });

  final List<DueReview> due;
  final List<RecentMistake> mistakes;
  final List<LessonProgress> recent;
  final Map<String, Concept> concepts;
}

/// German name for the ability a due review measures.
String _dimensionLabel(MasteryDimension dimension) => switch (dimension) {
  MasteryDimension.recognition => 'Wiedererkennen',
  MasteryDimension.germanToCroatian => 'Deutsch → Kroatisch',
  MasteryDimension.croatianToGerman => 'Kroatisch → Deutsch',
  MasteryDimension.sentenceProduction => 'Satz bilden',
  MasteryDimension.grammarApplication => 'Lücke füllen',
};

String _readableId(String value) {
  final words = value.split('-').where((word) => word.isNotEmpty).join(' ');
  return '${words[0].toUpperCase()}${words.substring(1)}';
}

String _reviewPath(String lessonId, String exerciseId) => Uri(
  pathSegments: ['', 'lesson', lessonId],
  queryParameters: {'exercise': exerciseId},
).toString();

class _EmptyReview extends StatelessWidget {
  const new();

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
  const new({
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
    leading: Icon(icon, color: context.palette.primary),
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: Icon(enabled ? Icons.chevron_right_rounded : Icons.lock_outline),
  );
}
