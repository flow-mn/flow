import "package:flow/data/actionable_nofications/actionable_notification.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/widgets/internal_notifications/internal_notification_list_tile.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";

class TurnOnICloudSyncNotification extends StatelessWidget {
  final TurnOnICloudNotification notification;
  final VoidCallback? onDismiss;

  const TurnOnICloudSyncNotification({
    super.key,
    required this.notification,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return ActionableNotificationListTile(
      onDismiss: onDismiss,
      icon: notification.icon,
      title: "tabs.home.reminders.turnOnICloudSync".t(context),
      subtitle: "tabs.home.reminders.turnOnICloudSync.subtitle".t(context),
      action: Builder(
        builder: (context) {
          return TextButton.icon(
            onPressed: () {
              context.push("/preferences/sync");
            },
            label: Text(
              "tabs.home.reminders.turnOnICloudSync.action".t(context),
            ),
            icon: Icon(Symbols.open_in_new_rounded),
          );
        },
      ),
    );
  }
}
