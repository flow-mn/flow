import "package:flutter/material.dart";

class ModalOverflowBar extends StatelessWidget {
  final EdgeInsets padding;
  final List<Widget> children;

  final double spacing;
  final MainAxisAlignment? alignment;
  final double overflowSpacing;
  final OverflowBarAlignment overflowAlignment;
  final VerticalDirection overflowDirection;
  final TextDirection? textDirection;

  const ModalOverflowBar({
    super.key,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 12.0,
    ),
    required this.children,
    this.alignment,
    this.spacing = 12.0,
    this.overflowSpacing = 12.0,
    this.overflowAlignment = OverflowBarAlignment.start,
    this.overflowDirection = VerticalDirection.down,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: OverflowBar(
        alignment: alignment,
        spacing: spacing,
        overflowSpacing: overflowSpacing,
        overflowAlignment: overflowAlignment,
        overflowDirection: overflowDirection,
        textDirection: textDirection,
        children: children,
      ),
    );
  }
}
