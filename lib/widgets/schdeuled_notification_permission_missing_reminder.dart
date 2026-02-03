import "dart:io";

import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/schdeuled_notification_permission_builder.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:permission_handler/permission_handler.dart";

final Logger _log = Logger("SchdeuledNotificationPermissionMissingReminder");

class SchdeuledNotificationPermissionMissingReminder extends StatefulWidget {
  final SchdeuledNotificationPermission permissions;

  const SchdeuledNotificationPermissionMissingReminder({
    super.key,
    required this.permissions,
  });

  @override
  State<SchdeuledNotificationPermissionMissingReminder> createState() =>
      _SchdeuledNotificationPermissionMissingReminderState();
}

class _SchdeuledNotificationPermissionMissingReminderState
    extends State<SchdeuledNotificationPermissionMissingReminder> {
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];

    if (!widget.permissions.hasNotificationPermission) {
      children.add(
        InkWell(
          onTap: openNotificationsSettings,
          child: Frame.standalone(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Symbols.warning_rounded,
                  fill: 0,
                  color: context.colorScheme.error,
                  size: 24.0,
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: DefaultTextStyle(
                    style: context.textTheme.bodyMedium!
                        .semi(context)
                        .copyWith(color: context.colorScheme.error),
                    child: Text(
                      "notifications.permissionNotGranted".t(context),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                busy
                    ? SizedBox(width: 24.0, height: 24.0, child: Spinner())
                    : Icon(Symbols.open_in_new_rounded, fill: 0, size: 24.0),
              ],
            ),
          ),
        ),
      );
    }

    if (!widget.permissions.hasAlarmPermission) {
      children.add(
        InkWell(
          onTap: openNotificationsSettings,
          child: Frame.standalone(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Symbols.alarm_off_rounded,
                  fill: 0,
                  color: context.colorScheme.error,
                  size: 24.0,
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: DefaultTextStyle(
                    style: context.textTheme.bodyMedium!
                        .semi(context)
                        .copyWith(color: context.colorScheme.error),
                    child: Text(
                      "notifications.alarm.permissionNotGranted".t(context),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                busy
                    ? SizedBox(width: 24.0, height: 24.0, child: Spinner())
                    : Icon(Symbols.open_in_new_rounded, fill: 0, size: 24.0),
              ],
            ),
          ),
        ),
      );
      if (Platform.isAndroid) {
        children.add(
          Frame(
            child: InfoText(
              child: Text("notifications.alarm.androidDescription".t(context)),
            ),
          ),
        );
      }
    }

    return Column(mainAxisSize: .min, children: children);
  }

  void openNotificationsSettings() async {
    try {
      await openAppSettings();
    } catch (error) {
      _log.warning("Failed to open app settings: $error", error);
    }
  }
}
