import "package:flutter/material.dart";

class WavyDividerPainter extends CustomPainter {
  /// Width of single semi-circle
  final double waveWidth;

  /// Height of the divider
  final double height;

  final Color color;

  final double strokeWidth;

  const WavyDividerPainter({
    super.repaint,
    required this.color,
    required this.height,
    required this.waveWidth,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double halfHeight = height * 0.5;

    final Path path = Path()..moveTo(0, halfHeight);

    final int iterations = (size.width / waveWidth).ceil();

    for (int i = 0; i < iterations; i++) {
      path.relativeQuadraticBezierTo(
        waveWidth * 0.5,
        halfHeight * (i % 2 == 0 ? 1 : -1),
        waveWidth,
        0,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavyDividerPainter oldDelegate) => false;
}
