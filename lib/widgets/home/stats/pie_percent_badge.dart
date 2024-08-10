import 'package:flow/data/flow_icon.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/general/flow_icon.dart';
import 'package:flutter/material.dart';

class PiePercentBadge extends StatelessWidget {
  final FlowIconData icon;

  /// Typically, value from 0.0 to 1.0
  ///
  /// e.g., 0.67 for 67%
  final double percent;

  final Color? color;
  final Color? backgroundColor;

  final BorderRadius borderRadius;

  final EdgeInsets padding;

  const PiePercentBadge({
    super.key,
    required this.icon,
    required this.percent,
    this.color,
    this.backgroundColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
    this.padding = const EdgeInsets.all(8.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: borderRadius,
        color: backgroundColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FlowIcon(
            icon,
            size: 24.0,
            color: color,
          ),
          const SizedBox(width: 4.0),
          Text(
            "${(100 * percent).toStringAsFixed(1)}%",
            style: context.textTheme.bodyMedium!.copyWith(
              color: color,
            ),
          )
        ],
      ),
    );
  }
}
