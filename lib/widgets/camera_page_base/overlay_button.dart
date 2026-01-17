import "dart:ui";

import "package:flutter/material.dart";

class OverlayButton extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;

  final Widget child;

  const OverlayButton({
    super.key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    final Widget content = Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isIOS ? const Color(0xA0FFFFFF) : const Color(0xFFFFFFFF),
      ),
      child: ProgressIndicatorTheme(
        data: ProgressIndicatorThemeData(color: const Color(0xFF000000)),
        child: IconTheme(
          data: IconThemeData(color: const Color(0xFF000000), fill: 1.0),
          child: child,
        ),
      ),
    );

    return Material(
      type: .transparency,
      child: InkWell(
        borderRadius: .circular(999.9),
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        onLongPress: onLongPress,
        child: ClipOval(
          child: isIOS
              ? BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: content,
                )
              : content,
        ),
      ),
    );
  }
}
