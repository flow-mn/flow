import "package:flow/data/flow_icon.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flutter/material.dart";

/// A small tinted square holding an insight's icon.
class InsightIconBadge extends StatelessWidget {
  final FlowIconData icon;

  const InsightIconBadge({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32.0,
      height: 32.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.colorScheme.primary.withAlpha(0x29),
        borderRadius: .all(Radius.circular(10.0)),
      ),
      child: FlowIcon(icon, size: 18.0),
    );
  }
}
