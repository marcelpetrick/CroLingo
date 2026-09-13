import 'dart:math' as math;

import 'package:crolingo/core/motion/app_motion.dart';
import 'package:crolingo/core/theme/app_theme.dart';
import 'package:crolingo/core/widgets/crow_mark.dart';
import 'package:flutter/material.dart';

/// Short, accessible reward shown after a lesson or focused review.
class LessonCelebration extends StatefulWidget {
  /// Creates a CroLingo-specific completion moment.
  const new({
    required this.lessonTitle,
    required this.xp,
    required this.actionLabel,
    required this.onContinue,
    this.review = false,
    super.key,
  });

  /// Name of the completed lesson.
  final String lessonTitle;

  /// XP earned during this session.
  final int xp;

  /// Label for the next action.
  final String actionLabel;

  /// Leaves the completion screen.
  final VoidCallback onContinue;

  /// Whether this was a focused review rather than a complete lesson.
  final bool review;

  @override
  State<LessonCelebration> createState() => _LessonCelebrationState();
}

class _LessonCelebrationState extends State<LessonCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.celebration,
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
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: math.max(0, constraints.maxHeight - 48),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final progress = _controller.value;
              final mascotProgress = Curves.elasticOut.transform(
                (progress / 0.62).clamp(0.0, 1.0),
              );
              final contentProgress = Curves.easeOutCubic.transform(
                ((progress - 0.22) / 0.52).clamp(0.0, 1.0),
              );
              final actionProgress = Curves.easeOutCubic.transform(
                ((progress - 0.52) / 0.48).clamp(0.0, 1.0),
              );
              final shownXp = (widget.xp * contentProgress).round();
              return _CelebrationCard(
                mascotProgress: mascotProgress,
                contentProgress: contentProgress,
                actionProgress: actionProgress,
                burstProgress: progress,
                semanticLabel:
                    '${widget.review ? 'Wiederholung' : 'Lektion'} geschafft. '
                    '${widget.xp} XP verdient.',
                lessonTitle: widget.lessonTitle,
                headline: widget.review
                    ? 'Stark wiederholt!'
                    : 'Lektion geschafft!',
                shownXp: shownXp,
                actionLabel: widget.actionLabel,
                onContinue: widget.onContinue,
              );
            },
          ),
        ),
      ),
    ),
  );
}

class _CelebrationCard extends StatelessWidget {
  const new({
    required this.mascotProgress,
    required this.contentProgress,
    required this.actionProgress,
    required this.burstProgress,
    required this.semanticLabel,
    required this.lessonTitle,
    required this.headline,
    required this.shownXp,
    required this.actionLabel,
    required this.onContinue,
  });

  final double mascotProgress;
  final double contentProgress;
  final double actionProgress;
  final double burstProgress;
  final String semanticLabel;
  final String lessonTitle;
  final String headline;
  final int shownXp;
  final String actionLabel;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) => Container(
    width: 360,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: context.palette.surface,
      border: Border.all(color: context.palette.border),
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: context.palette.charcoal.withValues(alpha: 0.08),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _CheckerAccent(),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            children: [
              Semantics(
                container: true,
                label: semanticLabel,
                child: ExcludeSemantics(
                  child: Column(
                    children: [
                      SizedBox(
                        width: 210,
                        height: 174,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            CustomPaint(
                              size: const Size.square(210),
                              painter: _CelebrationBurstPainter(
                                progress: burstProgress,
                                primary: context.palette.primary,
                                accent: context.palette.accent,
                                crown: context.palette.crown,
                              ),
                            ),
                            Transform.translate(
                              offset: Offset(
                                0,
                                -10 * math.sin(math.pi * burstProgress),
                              ),
                              child: Transform.rotate(
                                angle: (1 - mascotProgress) * -0.08,
                                child: Transform.scale(
                                  scale: mascotProgress,
                                  child: const CrowMark(size: 116),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 32,
                              child: Transform.rotate(
                                angle: (1 - mascotProgress) * 0.22,
                                child: Transform.scale(
                                  scale: mascotProgress,
                                  child: Icon(
                                    Icons.workspace_premium_rounded,
                                    size: 48,
                                    color: context.palette.crown,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Opacity(
                        opacity: contentProgress,
                        child: Transform.translate(
                          offset: Offset(0, 10 * (1 - contentProgress)),
                          child: Column(
                            children: [
                              Text(
                                headline,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                lessonTitle,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: context.palette.selectedSurface,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.bolt_rounded,
                                      color: context.palette.crown,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '+$shownXp XP',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Transform.translate(
                offset: Offset(0, 8 * (1 - actionProgress)),
                child: Transform.scale(
                  scale: 0.97 + (0.03 * actionProgress),
                  child: FilledButton.icon(
                    onPressed: onContinue,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(actionLabel),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _CheckerAccent extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      height: 12,
      child: Row(
        children: [
          for (var index = 0; index < 12; index++)
            Expanded(
              child: ColoredBox(
                color: index.isEven
                    ? context.palette.accent
                    : context.palette.surface,
                child: const SizedBox.expand(),
              ),
            ),
        ],
      ),
    ),
  );
}

class _CelebrationBurstPainter extends CustomPainter {
  const new({
    required this.progress,
    required this.primary,
    required this.accent,
    required this.crown,
  });

  final double progress;
  final Color primary;
  final Color accent;
  final Color crown;

  @override
  void paint(Canvas canvas, Size size) {
    final reveal = Curves.easeOutCubic.transform(
      (progress / 0.62).clamp(0.0, 1.0),
    );
    final fade = 1 - ((progress - 0.62) / 0.38).clamp(0.0, 1.0);
    final colors = [primary, accent, crown];
    final center = size.center(Offset.zero);
    for (var index = 0; index < 16; index++) {
      final angle = index * math.pi * 2 / 16 - math.pi / 2;
      final distance = (54 + (index % 3) * 10) * reveal;
      final offset =
          center + Offset(math.cos(angle), math.sin(angle)) * distance;
      final paint = Paint()
        ..color = colors[index % colors.length].withValues(
          alpha: fade * reveal,
        );
      canvas
        ..save()
        ..translate(offset.dx, offset.dy)
        ..rotate(angle + reveal)
        ..drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-3, -7, 6, 14),
            const Radius.circular(2),
          ),
          paint,
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CelebrationBurstPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.primary != primary ||
      oldDelegate.accent != accent ||
      oldDelegate.crown != crown;
}
