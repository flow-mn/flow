import "package:flow/data/internal_nofications/internal_notification.dart";
import "package:flow/widgets/internal_notifications/auto_backup_reminder.dart";
import "package:flow/widgets/internal_notifications/rate_app_notification.dart";
import "package:flow/widgets/internal_notifications/star_on_github_notification.dart";
import "package:flutter/material.dart";

class InternalNotificationSection extends StatelessWidget {
  final InternalNotification notification;
  final VoidCallback? onDismiss;

  const InternalNotificationSection({
    super.key,
    required this.notification,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) => switch (notification) {
    AutoBackupReminder notification => AutoBackupReminderNotification(
      notification: notification,
      onDismiss: onDismiss,
    ),
    RateApp notification => RateAppNotification(
      notification: notification,
      onDismiss: onDismiss,
    ),
    StarOnGitHub notification => StarOnGithubNotification(
      notification: notification,
      onDismiss: onDismiss,
    ),
    _ => SizedBox.shrink(),
  };
}
