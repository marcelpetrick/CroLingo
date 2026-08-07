import 'package:crolingo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Small original geometric crow mark used in the application shell.
class CrowMark extends StatelessWidget {
  /// Creates a crow mark at [size].
  const CrowMark({this.size = 72, super.key});

  /// Width and height of the mark.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Freundliche CroLingo-Krähe',
      image: true,
      child: CustomPaint(size: Size.square(size), painter: _CrowPainter()),
    );
  }
}

class _CrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final body = Paint()..color = AppColors.charcoal;
    final wing = Paint()..color = AppColors.primaryPressed;
    final white = Paint()..color = Colors.white;
    final accent = Paint()..color = AppColors.accent;
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
