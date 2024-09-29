import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";

class AnalyticsCard extends StatelessWidget {
  final Widget child;

  static const borderRadius = BorderRadius.all(
    Radius.circular(24.0),
  );

  const AnalyticsCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Surface(
      elevation: 0.0,
      builder: (context) => ClipRRect(
        borderRadius: borderRadius,
        child: child,
      ),
      shape: const RoundedRectangleBorder(borderRadius: borderRadius),
    );
  }
}
