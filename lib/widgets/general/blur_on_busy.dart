import "dart:ui";

import "package:flutter/material.dart";

class BlurOnBusy extends StatelessWidget {
  final bool busy;
  final Widget child;

  final double sigmaX;
  final double sigmaY;

  const BlurOnBusy({
    super.key,
    required this.busy,
    required this.child,
    this.sigmaX = 2.0,
    this.sigmaY = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          child,
          if (busy)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
                child: Container(),
              ),
            ),
        ],
      ),
    );
  }
}
