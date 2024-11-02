import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";

class AnalyticsCard extends StatelessWidget {
  final Widget child;

  final BorderRadius borderRadius;

  const AnalyticsCard({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(16.0),
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Surface(
      elevation: 0.0,
      builder: (context) => ClipRRect(
        borderRadius: borderRadius,
        child: child,
      ),
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
    );
  }
}
