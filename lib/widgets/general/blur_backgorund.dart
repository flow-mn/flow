import "dart:ui";

import "package:flutter/material.dart";

class BlurBackground extends StatelessWidget {
  final bool blur;
  final Widget child;

  final double sigmaX;
  final double sigmaY;

  const BlurBackground({
    super.key,
    required this.blur,
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
          if (blur)
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
