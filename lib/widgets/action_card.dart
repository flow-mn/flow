import 'package:flow/widgets/general/surface.dart';
import 'package:flutter/material.dart';

class ActionCard extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final Widget Function(BuildContext context) builder;

  final BorderRadius borderRadius;

  const ActionCard({
    super.key,
    this.onTap,
    this.onLongPress,
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Surface(
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
        ),
        builder: (context) => InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          onLongPress: onLongPress,
          child: builder(context),
        ),
      ),
    );
  }
}
