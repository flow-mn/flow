import "package:flutter/material.dart";

class MaterialOverflowBar extends StatelessWidget {
  final List<Widget> children;

  const MaterialOverflowBar({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      child: OverflowBar(
        children: children,
      ),
    );
  }
}
