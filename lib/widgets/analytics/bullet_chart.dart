import "dart:math" as math;

import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";

/// A compact bullet chart for budget-vs-actual style comparisons.
///
/// Draws a horizontal track with a qualitative band up to [target], a measure
/// bar for [value], and a target tick at [target]. The recommended encoding
/// for a single KPI against a goal on a dense screen.
class BulletChart extends StatelessWidget {
  final double value;
  final double target;

  /// Bar color; defaults to a sensible "over/under target" choice.
  final Color? barColor;

  final double height;

  const BulletChart({
    super.key,
    required this.value,
    required this.target,
    this.barColor,
    this.height = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    // Always leave headroom past whichever is larger so the bar/tick never
    // pin to the very edge.
    final double max = math.max(math.max(value, target), 1.0) * 1.1;
    final bool over = value > target;

    final Color bar =
        barColor ??
        (over ? context.flowColors.expense : context.flowColors.income);
    final Color track = context.colorScheme.onSurface.withAlpha(0x1f);
    final Color band = context.colorScheme.onSurface.withAlpha(0x14);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double valueWidth = (value / max).clamp(0.0, 1.0) * width;
        final double targetX = (target / max).clamp(0.0, 1.0) * width;

        return SizedBox(
          height: height,
          width: width,
          child: Stack(
            children: [
              // Full track.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: track,
                    borderRadius: BorderRadius.all(Radius.circular(height / 2)),
                  ),
                ),
              ),
              // Qualitative band up to the target.
              Positioned(
                left: 0.0,
                top: 0.0,
                bottom: 0.0,
                child: Container(
                  width: targetX,
                  decoration: BoxDecoration(
                    color: band,
                    borderRadius: BorderRadius.all(Radius.circular(height / 2)),
                  ),
                ),
              ),
              // Measure bar, inset vertically so the track reads behind it.
              Positioned(
                left: 0.0,
                top: height * 0.28,
                bottom: height * 0.28,
                child: Container(
                  width: valueWidth,
                  decoration: BoxDecoration(
                    color: bar,
                    borderRadius: BorderRadius.all(Radius.circular(height / 2)),
                  ),
                ),
              ),
              // Target tick.
              Positioned(
                left: math.max(0.0, targetX - 1.0),
                top: -1.0,
                bottom: -1.0,
                child: Container(
                  width: 2.5,
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary,
                    borderRadius: const BorderRadius.all(Radius.circular(2.0)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
