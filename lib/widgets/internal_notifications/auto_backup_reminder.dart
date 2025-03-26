import "package:flow/data/internal_nofications/internal_notification.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/internal_notifications/internal_notification_list_tile.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class AutoBackupReminderNotification extends StatelessWidget {
  final AutoBackupReminder notification;
  final VoidCallback? onDismiss;

  const AutoBackupReminderNotification({
    super.key,
    required this.notification,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return InternalNotificationListTile(
      onDismiss: onDismiss,
      icon: notification.icon,
      title: "tabs.home.reminders.autoBackup".t(context),
      subtitle: "tabs.home.reminders.autoBackup.subtitle".t(context),
      action: Builder(
        builder: (context) {
          return TextButton.icon(
            onPressed: () {
              if (notification.payload == null) {
                context.showErrorToast(
                  error: "error.sync.fileNotFound".t(context),
                );
                return;
              }

              TransitiveLocalPreferences().lastSavedAutoBackupPath
                  .set(notification.payload!.filePath)
                  .then((_) {})
                  .catchError((e) {
                    // Silent fail
                  });

              context.showFileShareSheet(
                subject: "sync.export.save.shareTitle".t(context, {
                  "type": notification.payload!.type,
                  "date":
                      notification.payload!.createdDate
                          .toLocal()
                          .toMoment()
                          .lll,
                }),
                filePath: notification.payload!.filePath,
              );

              if (onDismiss != null) {
                onDismiss!();
              }
            },
            label: Text("sync.export.save".t(context)),
            icon: Icon(Symbols.download_rounded),
          );
        },
      ),
    );
  }
}
