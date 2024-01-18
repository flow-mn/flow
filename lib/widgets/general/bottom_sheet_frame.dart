import 'package:flow/theme/theme.dart';
import 'package:flutter/material.dart';

class BottomSheetFrame extends StatelessWidget {
  final Widget child;
  final bool scrollable;

  final double borderRadiusSize;

  const BottomSheetFrame({
    super.key,
    required this.child,
    this.scrollable = false,
    this.borderRadiusSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(borderRadiusSize),
        topRight: Radius.circular(borderRadiusSize),
      ),
      clipBehavior: Clip.hardEdge,
      color: context.colorScheme.background,
      child: SafeArea(
        child: scrollable
            ? SingleChildScrollView(
                child: child,
              )
            : child,
      ),
    );
  }
}
