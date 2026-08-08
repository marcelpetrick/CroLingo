import 'package:crolingo/core/theme/app_theme.dart';
import 'package:crolingo/domain/course/course.dart';
import 'package:flutter/material.dart';

/// Shows which language direction the current exercise practises.
///
/// Flags are decorative reinforcement. The written language names and the
/// semantic label carry the meaning on their own.
class LanguageDirectionHeader extends StatelessWidget {
  /// Creates a direction header for one mastery dimension.
  const LanguageDirectionHeader({required this.dimension, super.key});

  /// Ability measured by the current exercise.
  final MasteryDimension dimension;

  @override
  Widget build(BuildContext context) {
    final (visible, accessible) = switch (dimension) {
      MasteryDimension.recognition => (
        '🇭🇷 Hrvatski ↔ 🇩🇪 Deutsch',
        'Kroatisch und Deutsch zuordnen',
      ),
      MasteryDimension.croatianToGerman => (
        '🇭🇷 Hrvatski → 🇩🇪 Deutsch',
        'Von Kroatisch nach Deutsch',
      ),
      MasteryDimension.germanToCroatian ||
      MasteryDimension.sentenceProduction ||
      MasteryDimension.grammarApplication => (
        '🇩🇪 Deutsch → 🇭🇷 Hrvatski',
        'Von Deutsch nach Kroatisch',
      ),
    };
    return Semantics(
      label: accessible,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: context.palette.selectedSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.palette.border),
          ),
          child: Center(
            child: Text(
              visible,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    );
  }
}
