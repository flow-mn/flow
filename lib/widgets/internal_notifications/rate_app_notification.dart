import "dart:io";

import "package:flow/constants.dart";
import "package:flow/data/internal_nofications/internal_notification.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/widgets/internal_notifications/internal_notification_list_tile.dart";
import "package:flutter/material.dart";
import "package:in_app_review/in_app_review.dart";

class RateAppNotification extends StatelessWidget {
  final RateApp notification;
  final VoidCallback? onDismiss;

  static String getStoreName(String? downloadedFrom) {
    switch (downloadedFrom?.toLowerCase()) {
      case "com.android.vending":
      case "play_store":
        return "Google Play";
      case "com.apple":
      case "com.apple.simulator":
        return "App Store";
      case "com.apple.testflight":
      case "testflight":
        return "TestFlight";
      case null:
      default:
        return Platform.isAndroid ? "Google Play" : "App Store";
    }
  }

  const RateAppNotification({
    super.key,
    required this.notification,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return InternalNotificationListTile(
      onDismiss: onDismiss,
      icon: notification.icon,
      title: "tabs.home.reminders.rateApp".t(
        context,
        getStoreName(downloadedFrom),
      ),
      action: TextButton(
        onPressed: () {
          if (notification.payload) {
            InAppReview.instance.requestReview();
          } else {
            InAppReview.instance.openStoreListing(appStoreId: appleAppStoreId);
          }

          if (onDismiss != null) {
            onDismiss!();
          }
        },
        child: Text("tabs.home.reminders.rateApp.action".t(context)),
      ),
    );
  }
}
