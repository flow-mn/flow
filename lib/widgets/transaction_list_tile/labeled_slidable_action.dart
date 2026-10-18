import "package:flutter/material.dart";
import "package:flutter_slidable/flutter_slidable.dart";

/// Icon-only [SlidableAction] with a tooltip, which also serves as its
/// semantic label
class LabeledSlidableAction extends SlidableAction {
  final String tooltip;

  const LabeledSlidableAction({
    super.key,
    required super.onPressed,
    required IconData super.icon,
    required this.tooltip,
    super.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomSlidableAction(
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      autoClose: autoClose,
      flex: flex,
      borderRadius: borderRadius,
      padding: padding,
      alignment: alignment,
      child: Tooltip(message: tooltip, child: Icon(icon)),
    );
  }
}
