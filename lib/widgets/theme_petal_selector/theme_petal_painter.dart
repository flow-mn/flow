import "dart:math" as math;

import "package:flutter/material.dart";

class ThemePetalPainter extends CustomPainter {
  final double animationValue;

  final double petalRadiusProc;

  final double centerSpaceRadiusProc;

  final double angleOffset;

  final List<Color> colors;

  final Color selectedColor;

  final int? selectedIndex;
  final int? hoveringIndex;

  const ThemePetalPainter({
    required this.animationValue,
    required this.colors,
    required this.angleOffset,
    required this.petalRadiusProc,
    required this.centerSpaceRadiusProc,
    required this.selectedColor,
    required this.selectedIndex,
    required this.hoveringIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width * 0.5, size.height * 0.5);

    final Paint paint = Paint()..style = PaintingStyle.fill;

    final double r = size.width * 0.5;

    final Paint ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.0
      ..color = selectedColor;

    final double petalCenterDistance =
        r * (petalRadiusProc + centerSpaceRadiusProc);
    final double petalRadius = r * petalRadiusProc;
    final double ringRadius = petalRadius + 4.0;

    final double angleDelta = math.pi * 2 / colors.length;

    for (int i = 0; i < colors.length; i++) {
      final double localProgress =
          math.min(1, math.max(0, animationValue * colors.length - i));

      final double theta = angleOffset + angleDelta * (i - 1 + localProgress);

      final Offset center = Offset(math.cos(theta), math.sin(theta)) *
          petalCenterDistance *
          localProgress;

      paint.color = i == hoveringIndex
          ? Color.alphaBlend(selectedColor.withAlpha(0x80), colors[i])
          : colors[i];
      canvas.drawCircle(
        center,
        petalRadius * localProgress,
        paint,
      );

      if (localProgress == 1 && selectedIndex == i) {
        canvas.drawCircle(
          center,
          ringRadius,
          ringPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(ThemePetalPainter oldDelegate) =>
      animationValue != oldDelegate.animationValue ||
      colors != oldDelegate.colors ||
      angleOffset != oldDelegate.angleOffset ||
      petalRadiusProc != oldDelegate.petalRadiusProc ||
      centerSpaceRadiusProc != oldDelegate.centerSpaceRadiusProc ||
      selectedColor != oldDelegate.selectedColor ||
      selectedIndex != oldDelegate.selectedIndex ||
      hoveringIndex != oldDelegate.hoveringIndex;
}
