import 'package:crolingo/core/theme/app_theme.dart';
import 'package:crolingo/core/widgets/speech_button.dart';
import 'package:flutter/material.dart';

/// Immediate correction shown after one graded answer.
///
/// Correctness is signalled by icon, wording, and colour together, never by
/// colour alone.
class AnswerFeedback extends StatelessWidget {
  /// Creates feedback for one graded answer.
  const new({
    required this.correct,
    required this.submitted,
    required this.correction,
    required this.croatianCorrection,
    required this.explanation,
    super.key,
  });

  /// Whether the submitted answer was accepted.
  final bool correct;

  /// Answer the learner submitted.
  final String submitted;

  /// Canonical accepted answer.
  final String correction;

  /// Croatian text offered for playback, when the correction is Croatian.
  final String? croatianCorrection;

  /// Short German explanation.
  final String explanation;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Container(
      width: double.infinity,
      color: correct
          ? context.palette.successSurface
          : context.palette.errorSurface,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: correct
                    ? context.palette.success
                    : context.palette.error,
              ),
              const SizedBox(width: 8),
              Text(
                correct ? 'Richtig!' : 'Noch nicht richtig',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          if (!correct) Text('Deine Antwort: $submitted'),
          Row(
            children: [
              Expanded(child: Text('Lösung: $correction')),
              if (croatianCorrection != null)
                SpeechButton(text: croatianCorrection!),
            ],
          ),
          Text(explanation),
        ],
      ),
    ),
  );
}
