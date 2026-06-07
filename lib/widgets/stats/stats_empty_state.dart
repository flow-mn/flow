import "package:flow/widgets/general/frame.dart";
import "package:flutter/material.dart";

/// Centered placeholder shown inside a [Frame] when an analytics section has no
/// data to display.
class StatsEmptyState extends StatelessWidget {
  final String message;
  final double verticalPadding;

  const StatsEmptyState({
    super.key,
    required this.message,
    this.verticalPadding = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return Frame(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        child: Center(child: Text(message)),
      ),
    );
  }
}
