import "package:flow/data/flow_icon.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/widgets/general/directional_slidable.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flutter/material.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:material_symbols_icons/symbols.dart";

class ActionableNotificationListTile extends StatelessWidget {
  final FlowIconData icon;

  final String title;
  final String? subtitle;

  final Widget action;

  final VoidCallback? onDismiss;

  const ActionableNotificationListTile({
    super.key,
    this.subtitle,
    required this.title,
    required this.action,
    required this.icon,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return DirectionalSlidable(
      endActions: [
        if (onDismiss != null)
          SlidableAction(
            onPressed: (BuildContext context) => onDismiss!(),
            icon: Symbols.close_rounded,
          ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: .end,
        children: [
          Row(
            spacing: 12.0,
            children: [
              FlowIcon(icon, plated: true, size: 32.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.labelLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: context.textTheme.bodySmall!,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          action,
        ],
      ),
    );
  }
}
