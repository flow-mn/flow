import "package:flutter/material.dart";

class Frame extends StatelessWidget {
  final bool pad;
  final EdgeInsets padding;
  final Widget child;

  const Frame({
    super.key,
    this.pad = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    required this.child,
  });

  const Frame.standalone({
    super.key,
    required this.child,
  })  : pad = true,
        padding = const EdgeInsets.all(16.0);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: pad ? padding : EdgeInsets.zero,
      child: child,
    );
  }
}
