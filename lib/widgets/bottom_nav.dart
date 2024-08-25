import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";

class BottomNav extends StatefulWidget {
  final List<Widget> children;
  final List<String>? tooltips;
  final Function(int) onPressed;
  final int currentIndex;

  const BottomNav({
    super.key,
    this.tooltips,
    required this.currentIndex,
    required this.children,
    required this.onPressed,
  }) : assert(tooltips == null || (tooltips.length == children.length),
            "If [tooltips] is provided, it must have same length as [children]");

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.primary,
      ),
      child: Row(children: [
        for (int i = 0; i < widget.children.length; i++)
          IconButton(
            onPressed: () => widget.onPressed(i),
            icon: widget.children[i],
            tooltip: widget.tooltips == null ? null : widget.tooltips![i],
            color: context.colorScheme.error,
          ),
      ]),
    );
  }
}
