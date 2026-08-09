import 'dart:io';
import 'dart:ui' as ui;

import 'package:crolingo/core/theme/app_theme.dart';
import 'package:crolingo/core/widgets/crow_mark.dart';
import 'package:crolingo/domain/settings/app_theme_variant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regenerates the Android launcher icons from the in-app mascot.
///
/// This is a generator, not a check, so it lives outside `test/` and never
/// runs in the pipeline. Invoke it deliberately:
///
/// ```bash
/// ./scripts/generate_launcher_icons.sh
/// ```
///
/// The icon is composed from the real [CrowMark] widget rather than a copied
/// drawing, so the launcher and the dashboard mascot cannot drift apart.
void main() {
  const legacy = <String, int>{
    'mdpi': 48,
    'hdpi': 72,
    'xhdpi': 96,
    'xxhdpi': 144,
    'xxxhdpi': 192,
  };
  // Adaptive layers are 108dp; Android crops to a 72dp safe zone.
  const adaptive = <String, int>{
    'mdpi': 108,
    'hdpi': 162,
    'xhdpi': 216,
    'xxhdpi': 324,
    'xxxhdpi': 432,
  };

  // One case per file: repeated toImage() renders inside a single test case
  // deadlock, and separate cases also make a partial failure obvious.
  legacy.forEach((density, pixels) {
    testWidgets('legacy $density', (tester) async {
      await _write(
        tester,
        const _LegacyIcon(),
        pixels,
        'android/app/src/main/res/mipmap-$density/ic_launcher.png',
      );
    });
  });

  adaptive.forEach((density, pixels) {
    testWidgets('adaptive background $density', (tester) async {
      await _write(
        tester,
        const _AdaptiveBackground(),
        pixels,
        'android/app/src/main/res/mipmap-$density/ic_launcher_background.png',
      );
    });
    testWidgets('adaptive foreground $density', (tester) async {
      await _write(
        tester,
        const _AdaptiveForeground(),
        pixels,
        'android/app/src/main/res/mipmap-$density/ic_launcher_foreground.png',
      );
    });
  });

  testWidgets('master', (tester) async {
    // A high-resolution master for stores and the repository README.
    await _write(tester, const _LegacyIcon(), 512, 'media/app_icon.png');
  });
}

Future<void> _write(
  WidgetTester tester,
  Widget art,
  int pixels,
  String path,
) async {
  final key = GlobalKey();
  tester.view
    ..physicalSize = Size(pixels.toDouble(), pixels.toDouble())
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: Size(pixels.toDouble(), pixels.toDouble())),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Theme(
          data: AppTheme.themeFor(AppThemeVariant.adriatic),
          child: RepaintBoundary(
            key: key,
            child: SizedBox.square(dimension: pixels.toDouble(), child: art),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;

  // Rasterising needs the real clock. Inside the fake async zone the returned
  // future resolves but the case itself never finishes.
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    File(path)
      ..parent.createSync(recursive: true)
      ..writeAsBytesSync(data!.buffer.asUint8List());
  });
  // A generator is expected to report what it produced.
  // ignore: avoid_print
  print('wrote $path (${pixels}px)');
}

/// The Croatian chequy, drawn from the flag's red and white.
class _Sahovnica extends StatelessWidget {
  const _Sahovnica();

  static const _red = Color(0xFFD32F2F);
  static const _white = Color(0xFFFFFFFF);
  static const _squares = 5;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _SahovnicaPainter(),
    child: const SizedBox.expand(),
  );
}

class _SahovnicaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / _Sahovnica._squares;
    final red = Paint()..color = _Sahovnica._red;
    canvas.drawRect(Offset.zero & size, Paint()..color = _Sahovnica._white);
    for (var row = 0; row < _Sahovnica._squares; row++) {
      for (var column = 0; column < _Sahovnica._squares; column++) {
        if ((row + column).isEven) {
          canvas.drawRect(
            Rect.fromLTWH(column * cell, row * cell, cell, cell),
            red,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Pre-Android-26 icon: chequy field, white medallion, crow.
class _LegacyIcon extends StatelessWidget {
  const _LegacyIcon();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final side = constraints.biggest.shortestSide;
      return ClipRRect(
        borderRadius: BorderRadius.circular(side * 0.22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _Sahovnica(),
            Center(
              child: Container(
                width: side * 0.76,
                height: side * 0.76,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.palette.charcoal,
                    width: side * 0.02,
                  ),
                ),
                // The medallion guarantees the crow reads against the chequy
                // at 48 pixels, where the squares are only a few pixels wide.
                child: Center(child: CrowMark(size: side * 0.52)),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// Adaptive background layer: the chequy alone.
class _AdaptiveBackground extends StatelessWidget {
  const _AdaptiveBackground();

  @override
  Widget build(BuildContext context) => const _Sahovnica();
}

/// Adaptive foreground layer: medallion and crow inside the safe zone.
class _AdaptiveForeground extends StatelessWidget {
  const _AdaptiveForeground();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final side = constraints.biggest.shortestSide;
      return Center(
        child: Container(
          // 108dp layer, 72dp safe zone: keep the art well inside it.
          width: side * 0.6,
          height: side * 0.6,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: context.palette.charcoal,
              width: side * 0.016,
            ),
          ),
          child: Center(child: CrowMark(size: side * 0.4)),
        ),
      );
    },
  );
}
