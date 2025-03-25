import "package:flow/constants.dart";
import "package:flow/data/internal_nofications/internal_notification.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/internal_notifications/internal_notification_list_tile.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/material_symbols_icons.dart";

class StarOnGithubNotification extends StatelessWidget {
  final StarOnGitHub notification;
  final VoidCallback? onDismiss;

  const StarOnGithubNotification({
    super.key,
    required this.notification,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return InternalNotificationListTile(
      onDismiss: onDismiss,
      icon: notification.icon,
      title: "tabs.home.reminders.starOnGitHub".t(context),
      subtitle: "⭐⭐⭐⭐⭐",
      action: TextButton.icon(
        onPressed: () {
          if (onDismiss != null) {
            onDismiss!();
          }
          openUrl(flowGitHubRepoLink);
        },
        label: Text("GitHub"),
        icon: Icon(Symbols.open_in_new_rounded),
      ),
    );
  }
}
