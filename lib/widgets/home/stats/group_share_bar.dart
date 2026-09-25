import "package:flow/data/chart_data.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions/chart_data.dart";
import "package:flutter/material.dart";

/// Stacked 100% bar of each group's share of the total.
class GroupShareBar extends StatelessWidget {
  /// Shares below this are merged into a single "other" segment
  static const double otherThreshold = 0.02;

  final Map<String, ChartData> data;
  final Map<String, Color> colors;

  final double height;

  const GroupShareBar({
    super.key,
    required this.data,
    required this.colors,
    this.height = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    final double total = data.displayTotal;

    if (total <= 0) return SizedBox(height: height);

    final List<(double, Color)> segments = [];
    double other = 0.0;

    for (final MapEntry(:key, :value) in data.entries) {
      if (value.displayTotal / total < otherThreshold) {
        other += value.displayTotal;
      } else {
        segments.add((value.displayTotal, colors[key]!));
      }
    }

    if (other > 0) {
      segments.add((other, context.flowColors.semi.withAlpha(0x80)));
    }

    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: .all(Radius.circular(height / 2)),
        child: SizedBox(
          height: height,
          child: Row(
            spacing: 2.0,
            children: segments
                .map(
                  (segment) => Expanded(
                    flex: (segment.$1 / total * 1000).round().clamp(1, 1000),
                    child: ColoredBox(color: segment.$2),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
