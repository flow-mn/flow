import "package:flow/data/flow_button_type.dart";
import "package:flutter/material.dart";

class TransactionTypeButton extends StatelessWidget {
  final double opacity;
  final FlowButtonType type;

  const TransactionTypeButton({
    super.key,
    required this.type,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final Widget child = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: type.actionBackgroundColor(context),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Icon(type.icon, color: type.actionColor(context), weight: 800.0),
    );

    if (opacity == 1.0) {
      return child;
    }

    return Opacity(opacity: opacity, child: child);
  }
}
