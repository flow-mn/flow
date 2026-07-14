import "package:flow/data/actionable_nofications/actionable_notification.dart";
import "package:flow/widgets/internal_notifications/auto_backup_reminder.dart";
import "package:flow/widgets/internal_notifications/budget_alert_notification.dart";
import "package:flow/widgets/internal_notifications/rate_app_notification.dart";
import "package:flow/widgets/internal_notifications/star_on_github_notification.dart";
import "package:flow/widgets/internal_notifications/turn_on_icloud_sync_reminder.dart";
import "package:flutter/material.dart";

class ActionableNotificationSection extends StatelessWidget {
  final ActionableNotification notification;
  final VoidCallback? onDismiss;

  const ActionableNotificationSection({
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
    TurnOnICloudNotification notification => TurnOnICloudSyncNotification(
      notification: notification,
      onDismiss: onDismiss,
    ),
    BudgetAlert notification => BudgetAlertNotification(
      notification: notification,
      onDismiss: onDismiss,
    ),
    _ => SizedBox.shrink(),
  };
}
