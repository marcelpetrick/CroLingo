import 'package:crolingo/app/providers.dart';
import 'package:crolingo/core/theme/app_colors.dart';
import 'package:crolingo/data/course/asset_course_repository.dart';
import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/domain/progress/concept_mastery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Local vocabulary list with fine-grained learning strength.
class VocabularyScreen extends ConsumerStatefulWidget {
  /// Creates the vocabulary screen.
  const VocabularyScreen({super.key});

  @override
  ConsumerState<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends ConsumerState<VocabularyScreen> {
  late final Future<List<ConceptMastery>> _mastery = _load();

  Future<List<ConceptMastery>> _load() async {
    final course = await AssetCourseRepository().load();
    final attempts = await ref
        .read(progressRepositoryProvider)
        .loadAttemptHistory();
    return ConceptMasteryCalculator.calculate(course, attempts);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<ConceptMastery>>(
    future: _mastery,
    builder: (context, snapshot) => CustomScrollView(
      slivers: [
        SliverAppBar.large(
          leading: IconButton(
            tooltip: 'Zurück',
            onPressed: context.pop,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: const Text('Wortschatz'),
        ),
        if (snapshot.hasError)
          const SliverFillRemaining(
            child: Center(
              child: Text('Wortschatz konnte nicht geladen werden.'),
            ),
          )
        else if (!snapshot.hasData)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            sliver: SliverList.separated(
              itemCount: snapshot.data!.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _ConceptCard(mastery: snapshot.data![index]),
            ),
          ),
      ],
    ),
  );
}

class _ConceptCard extends StatelessWidget {
  const _ConceptCard({required this.mastery});

  final ConceptMastery mastery;

  @override
  Widget build(BuildContext context) {
    final percent = (mastery.overall * 100).round();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mastery.concept.croatian,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(mastery.concept.german),
                    ],
                  ),
                ),
                Text(
                  '$percent %',
                  semanticsLabel: '$percent Prozent gelernt',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: mastery.overall,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
              backgroundColor: AppColors.selectedSurface,
            ),
            const SizedBox(height: 10),
            Text(
              mastery.scores.isEmpty
                  ? 'Noch nicht geübt'
                  : mastery.scores.keys.map(_dimensionLabel).join(' · '),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

String _dimensionLabel(MasteryDimension dimension) => switch (dimension) {
  // Kept local so German product language does not leak into domain models.
  MasteryDimension.recognition => 'Erkennen',
  MasteryDimension.germanToCroatian => 'Deutsch → Kroatisch',
  MasteryDimension.croatianToGerman => 'Kroatisch → Deutsch',
  MasteryDimension.sentenceProduction => 'Sätze bilden',
  MasteryDimension.grammarApplication => 'Anwenden',
};
