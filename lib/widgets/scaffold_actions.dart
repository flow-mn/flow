import "dart:io";

import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";

class ScaffoldActions extends StatelessWidget {
  final List<Widget> children;

  const ScaffoldActions({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withAlpha(0x18),
            blurRadius: 8.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: .only(top: 20.0),
      child: SafeArea(
        child: Padding(
          padding: Platform.isIOS ? .zero : .only(bottom: 16.0),
          child: Column(mainAxisSize: .min, spacing: 12.0, children: children),
        ),
      ),
    );
  }
}
