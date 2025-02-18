import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";

class Frame extends StatelessWidget {
  final bool pad;
  final EdgeInsets padding;
  final Widget child;
  final bool withSurface;

  const Frame({
    super.key,
    this.pad = true,
    this.withSurface = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    required this.child,
  });

  const Frame.standalone({
    super.key,
    this.withSurface = false,
    required this.child,
  }) : pad = true,
       padding = const EdgeInsets.all(16.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: withSurface ? context.colorScheme.surface : null,
      padding: pad ? padding : EdgeInsets.zero,
      child: child,
    );
  }
}
