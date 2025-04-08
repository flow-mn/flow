import "package:flutter/material.dart";
import "package:flutter_slidable/flutter_slidable.dart";

class DirectionalSlidable extends StatelessWidget {
  final List<SlidableAction>? startActions;
  final List<SlidableAction>? endActions;
  final Widget child;
  final Key? dismissibleKey;
  final String? groupTag;

  const DirectionalSlidable({
    super.key,
    this.startActions,
    this.endActions,
    required this.child,
    this.dismissibleKey,
    this.groupTag,
  });

  @override
  Widget build(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);

    final List<SlidableAction>? directinalStartActions =
        (textDirection == TextDirection.ltr ? startActions : endActions);
    final List<SlidableAction>? directinalEndActions =
        (textDirection == TextDirection.ltr ? endActions : startActions);

    return Slidable(
      key: dismissibleKey,
      groupTag: groupTag,
      startActionPane: getPane(directinalStartActions),
      endActionPane: getPane(directinalEndActions),
      useTextDirection: false,
      child: child,
    );
  }

  ActionPane? getPane(List<SlidableAction>? actions) {
    if (actions == null || actions.isEmpty) {
      return null;
    }

    return ActionPane(motion: DrawerMotion(), children: actions);
  }
}
