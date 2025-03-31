import "package:app_settings/app_settings.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:material_symbols_icons/symbols.dart";

final Logger _log = Logger("GeoPermissionMissingReminder");

class GeoPermissionMissingReminder extends StatefulWidget {
  const GeoPermissionMissingReminder({super.key});

  @override
  State<GeoPermissionMissingReminder> createState() =>
      _GeoPermissionMissingReminderState();
}

class _GeoPermissionMissingReminderState
    extends State<GeoPermissionMissingReminder> {
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: openGeoSettings,
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
                  "preferences.transactions.geo.auto.permissionDenied".t(
                    context,
                  ),
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
    );
  }

  void openGeoSettings() {
    try {
      AppSettings.openAppSettings(type: AppSettingsType.location);
    } catch (error) {
      _log.warning("Failed to open app settings: $error", error);
    }
  }
}
