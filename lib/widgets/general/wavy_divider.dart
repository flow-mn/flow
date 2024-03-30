import 'package:flow/widgets/general/wavy_divider/wavy_divider_painter.dart';
import 'package:flutter/material.dart';

class WavyDivider extends StatelessWidget {
  /// Height of the divider
  ///
  /// Visually, will be less than [height] due to usage of bezier curves
  final double height;

  /// Width of a single wave
  final double waveWidth;

  /// Color of the divider, defaults to theme's `dividerColor`
  final Color? color;

  /// Width of the stroke
  final double strokeWidth;

  const WavyDivider({
    super.key,
    this.height = 16.0,
    this.waveWidth = 16.0,
    this.strokeWidth = 2.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ClipRect(
        child: CustomPaint(
          painter: WavyDividerPainter(
            color: color ?? Theme.of(context).dividerColor,
            height: height,
            waveWidth: waveWidth,
            strokeWidth: strokeWidth,
          ),
          isComplex: false,
          willChange: false,
        ),
      ),
    );
  }
}
