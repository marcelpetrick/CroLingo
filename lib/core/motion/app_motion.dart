import 'package:flutter/material.dart';

/// Shared motion rhythm for responsive, consistent transitions.
abstract final class AppMotion {
  /// Small state changes such as progress and selection.
  static const quick = Duration(milliseconds: 160);

  /// Standard screen and content transition.
  static const standard = Duration(milliseconds: 280);

  /// Emphasized motion used only for rewarding moments.
  static const celebration = Duration(milliseconds: 900);

  /// Returns zero when the platform or learner has disabled animation.
  static Duration responsive(BuildContext context, Duration duration) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false
      ? Duration.zero
      : duration;
}

/// A short fade-and-rise used when asynchronous or navigated content appears.
class MotionEntrance extends StatefulWidget {
  /// Creates one entrance with an optional stagger [delay].
  const new({required this.child, this.delay = Duration.zero, super.key});

  /// Content revealed by the transition.
  final Widget child;

  /// Delay folded into the controller, avoiding timers and late callbacks.
  final Duration delay;

  @override
  State<MotionEntrance> createState() => _MotionEntranceState();
}

class _MotionEntranceState extends State<MotionEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.standard + widget.delay,
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
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    child: widget.child,
    builder: (context, child) {
      final total =
          AppMotion.standard.inMilliseconds + widget.delay.inMilliseconds;
      final start = total == 0 ? 0.0 : widget.delay.inMilliseconds / total;
      final raw = ((_controller.value - start) / (1 - start)).clamp(0.0, 1.0);
      final progress = Curves.easeOutCubic.transform(raw);
      return Opacity(
        opacity: progress,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - progress)),
          child: child,
        ),
      );
    },
  );
}
