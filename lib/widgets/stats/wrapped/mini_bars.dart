import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";

/// A compact bar chart of [values] with the final (most recent) bar drawn in
/// [highlightColor] and the rest muted. Used inside wrapped insight cards.
class MiniBars extends StatelessWidget {
  final List<double> values;
  final Color highlightColor;

  const MiniBars({super.key, required this.values, required this.highlightColor});

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();

    final double max = values.reduce((a, b) => a > b ? a : b);
    final Color base = context.colorScheme.onSurface.withAlpha(0x33);

    return SizedBox(
      height: 44.0,
      child: Row(
        crossAxisAlignment: .end,
        children: values.asMap().entries.map((entry) {
          final bool isLast = entry.key == values.length - 1;
          final double factor = max <= 0 ? 0.0 : entry.value / max;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: factor.clamp(0.05, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isLast ? highlightColor : base,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4.0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
