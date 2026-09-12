import 'package:crolingo/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Small original geometric crow mark used in the application shell.
class CrowMark extends StatelessWidget {
  /// Creates a crow mark at [size].
  const new({this.size = 72, super.key});

  /// Width and height of the mark.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Freundliche CroLingo-Krähe',
      image: true,
      child: CustomPaint(
        size: Size.square(size),
        painter: _CrowPainter(
          bodyColor: context.palette.charcoal,
          wingColor: context.palette.primaryPressed,
          accentColor: context.palette.accent,
          eyeColor: context.palette.mascotEye,
        ),
      ),
    );
  }
}

class _CrowPainter extends CustomPainter {
  const new({
    required this.bodyColor,
    required this.wingColor,
    required this.accentColor,
    required this.eyeColor,
  });

  final Color bodyColor;
  final Color wingColor;
  final Color accentColor;
  final Color eyeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final body = Paint()..color = bodyColor;
    final wing = Paint()..color = wingColor;
    final white = Paint()..color = eyeColor;
    final accent = Paint()..color = accentColor;
    canvas
      ..drawOval(
        Rect.fromLTWH(
          size.width * 0.18,
          size.height * 0.18,
          size.width * 0.62,
          size.height * 0.68,
        ),
        body,
      )
      ..drawOval(
        Rect.fromLTWH(
          size.width * 0.17,
          size.height * 0.46,
          size.width * 0.4,
          size.height * 0.3,
        ),
        wing,
      )
      ..drawCircle(
        Offset(size.width * 0.62, size.height * 0.37),
        size.width * 0.09,
        white,
      )
      ..drawCircle(
        Offset(size.width * 0.64, size.height * 0.37),
        size.width * 0.035,
        body,
      );
    final beak = Path()
      ..moveTo(size.width * 0.76, size.height * 0.43)
      ..lineTo(size.width * 0.98, size.height * 0.5)
      ..lineTo(size.width * 0.75, size.height * 0.56)
      ..close();
    canvas
      ..drawPath(beak, accent)
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * 0.24,
            size.height * 0.72,
            size.width * 0.5,
            size.height * 0.1,
          ),
          Radius.circular(size.width * 0.04),
        ),
        accent,
      );
  }

  @override
  bool shouldRepaint(covariant _CrowPainter oldDelegate) =>
      oldDelegate.bodyColor != bodyColor ||
      oldDelegate.wingColor != wingColor ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.eyeColor != eyeColor;
}
