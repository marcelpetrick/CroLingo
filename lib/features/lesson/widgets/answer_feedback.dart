import 'dart:math' as math;

import 'package:crolingo/core/motion/app_motion.dart';
import 'package:crolingo/core/theme/app_theme.dart';
import 'package:crolingo/core/widgets/speech_button.dart';
import 'package:flutter/material.dart';

/// Immediate correction shown after one graded answer.
///
/// Correctness is signalled by icon, wording, and colour together, never by
/// colour alone.
class AnswerFeedback extends StatefulWidget {
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
  State<AnswerFeedback> createState() => _AnswerFeedbackState();
}

class _AnswerFeedbackState extends State<AnswerFeedback>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.standard,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _controller.value = 1;
      _started = true;
    } else if (!_started) {
      _started = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = Curves.easeOutCubic.transform(_controller.value);
        final iconScale = Curves.elasticOut.transform(
          (_controller.value / 0.82).clamp(0.0, 1.0),
        );
        final shake = widget.correct
            ? 0.0
            : math.sin(_controller.value * math.pi * 5) *
                  (1 - _controller.value) *
                  7;
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - progress)),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.correct
                    ? context.palette.successSurface
                    : context.palette.errorSurface,
                border: Border(
                  top: BorderSide(
                    color: widget.correct
                        ? context.palette.success
                        : context.palette.error,
                    width: 2,
                  ),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: context.palette.charcoal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Transform.translate(
                          offset: Offset(shake, 0),
                          child: Transform.scale(
                            scale: iconScale,
                            child: Icon(
                              widget.correct
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              color: widget.correct
                                  ? context.palette.success
                                  : context.palette.error,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.correct ? 'Richtig!' : 'Noch nicht richtig',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    if (!widget.correct)
                      Text('Deine Antwort: ${widget.submitted}'),
                    Row(
                      children: [
                        Expanded(child: Text('Lösung: ${widget.correction}')),
                        if (widget.croatianCorrection != null)
                          SpeechButton(text: widget.croatianCorrection!),
                      ],
                    ),
                    Text(widget.explanation),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
