import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/transitive.dart";
import "package:flow/services/icloud_sync.dart";
import "package:flow/services/local_auth.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions/custom_popups.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

/// This widget expects [LocalAuthService] to be initialized
class ICloud extends StatefulWidget {
  const ICloud({super.key});

  @override
  State<ICloud> createState() => _ICloudState();
}

class _ICloudState extends State<ICloud> {
  @override
  Widget build(BuildContext context) {
    final bool enableICloudSync = UserPreferencesService().enableICloudSync;

    final dynamic error = ICloudSyncService().lastError;

    final DateTime? lastSuccessfulICloudSyncAt =
        TransitiveLocalPreferences().lastSuccessfulICloudSyncAt.get();

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 8.0,
      children: [
        SwitchListTile(
          secondary: const Icon(Symbols.cloud_rounded),
          title: Text("preferences.sync.iCloud".t(context)),
          value: enableICloudSync,
          onChanged: updateEnableICloudSync,
        ),
        if (lastSuccessfulICloudSyncAt != null)
          Text(
            "preferences.sync.iCloud.lastSuccessfulSync".t(
              context,
              lastSuccessfulICloudSyncAt.toMoment().lll,
            ),
          ),
        if (error != null)
          Frame(
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: Text(
                "error".t(context),
                style: context.textTheme.bodyMedium!.copyWith(
                  color: context.colorScheme.error,
                ),
              ),
            ),
          ),
        Frame(
          child: InfoText(
            child: Text("preferences.sync.iCloud.privacyNotice".t(context)),
          ),
        ),
      ],
    );
  }

  void updateEnableICloudSync(bool? newEnableICloudSync) async {
    if (newEnableICloudSync == null) return;

    bool? confirm = false;

    if (!newEnableICloudSync) {
      confirm = true;
    } else {
      confirm = await context.showConfirmationSheet(
        child: Text(
          "preferences.sync.iCloud.singleDeviceSupportDisclaimer".t(context),
        ),
      );
    }

    if (confirm != true) return;

    UserPreferencesService().enableICloudSync = newEnableICloudSync;

    setState(() {});
  }
}
