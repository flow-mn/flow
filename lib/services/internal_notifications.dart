import "dart:io";

import "package:flow/data/internal_nofications/internal_notification.dart";
import "package:flow/entity/backup_entry.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/widgets/utils/should_execute_scheduled_task.dart";
import "package:flutter/foundation.dart";
import "package:in_app_review/in_app_review.dart";
import "package:moment_dart/moment_dart.dart";

class InternalNotificationsService {
  static InternalNotificationsService? _instance;

  final ValueNotifier<List<InternalNotification>> _notifications =
      ValueNotifier([]);

  ValueListenable<List<InternalNotification>> get notifications =>
      _notifications;

  factory InternalNotificationsService() =>
      _instance ??= InternalNotificationsService._internal();

  void add(InternalNotification notification) {
    _notifications.value = [..._notifications.value, notification]
      ..sort((a, b) => b.priority.value.compareTo(a.priority.value));
  }

  /// Returns the most relevant notification, and deletes it from the pool
  InternalNotification? consume() {
    if (_notifications.value.isEmpty) {
      return null;
    }

    final [top, ...rest] = _notifications.value;

    _notifications.value = rest;

    return top;
  }

  /// Does not add a notification if there is any notification in the pool
  ///
  /// This function adds one notification at most, and can be recalled multiple times
  /// to add the next relevant available notification
  ///
  /// Adds the following notifications:
  /// - Auto backup reminder
  /// - Rate app
  /// - Star on GitHub
  void checkAndAddNotifications() async {
    if (_notifications.value.isNotEmpty) {
      return;
    }

    try {
      final String? savedPath =
          TransitiveLocalPreferences().lastSavedAutoBackupPath.get();

      final String? lastPath =
          TransitiveLocalPreferences().lastAutoBackupPath.get();

      if (lastPath != null && lastPath != savedPath) {
        final Query<BackupEntry> query =
            ObjectBox()
                .box<BackupEntry>()
                .query(BackupEntry_.filePath.equals(lastPath))
                .build();

        final BackupEntry? backupEntry = query.findFirst();

        query.close();

        if (backupEntry != null) {
          add(AutoBackupReminder(payload: backupEntry));
        }
      }
    } catch (e) {
      // Silent fail
    }

    if (_notifications.value.isNotEmpty) {
      return;
    }

    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      try {
        final DateTime? lastRateAppShowedAt =
            TransitiveLocalPreferences().lastRateAppShowedAt.get();

        if (shouldExecuteScheduledTask(
          Duration(days: 75),
          lastRateAppShowedAt,
        )) {
          add(
            RateApp(
              payload: await InAppReview.instance.isAvailable().catchError(
                (_) => false,
              ),
            ),
          );
          await TransitiveLocalPreferences().lastRateAppShowedAt.set(
            Moment.now(),
          );
        }
      } catch (e) {
        // Silent fail
      }
    }

    if (_notifications.value.isNotEmpty) {
      return;
    }

    try {
      final DateTime? lastStarOnGitHubShowedAt =
          TransitiveLocalPreferences().lastStarOnGitHubShowedAt.get();

      if (shouldExecuteScheduledTask(
        Duration(days: 120),
        lastStarOnGitHubShowedAt,
      )) {
        add(StarOnGitHub());
        await TransitiveLocalPreferences().lastStarOnGitHubShowedAt.set(
          Moment.now(),
        );
      }
    } catch (e) {
      // Silent fail
    }
  }

  InternalNotificationsService._internal() {
    checkAndAddNotifications();
  }
}
