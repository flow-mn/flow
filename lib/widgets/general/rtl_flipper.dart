import "package:flow/utils/extensions/directionality.dart";
import "package:flutter/material.dart";

class RTLFlipper extends StatelessWidget {
  final Widget child;

  const RTLFlipper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Transform.flip(flipX: context.isRtl, child: child);
  }
}
