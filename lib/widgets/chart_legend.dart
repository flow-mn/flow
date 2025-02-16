import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";

class ChartLegend extends StatelessWidget {
  final Color color;
  final String label;

  const ChartLegend({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16.0,
          height: 16.0,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(
              color: context.colorScheme.onSurface,
              width: 1.0,
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        Text(label, style: context.textTheme.bodyMedium),
      ],
    );
  }
}
