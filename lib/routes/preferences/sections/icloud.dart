import "package:flow/l10n/extensions.dart";
import "package:flow/services/local_auth.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

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

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 8.0,
      children: [
        SwitchListTile(
          secondary: const Icon(Symbols.cloud_rounded),
          title: Text("preferences.sync.autoBackup.syncToICloud".t(context)),
          value: enableICloudSync,
          onChanged: updateEnableICloudSync,
        ),
        Frame(
          child: InfoText(
            child: Text(
              "preferences.sync.autoBackup.syncToICloud.description".t(context),
            ),
          ),
        ),
        Frame(
          child: InfoText(
            child: Text(
              "preferences.sync.autoBackup.syncToICloud.disclaimer".t(context),
            ),
          ),
        ),
        Frame(
          child: InfoText(
            child: Text(
              "preferences.sync.autoBackup.syncToICloud.privacyNotice".t(
                context,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void updateEnableICloudSync(bool? newEnableICloudSync) async {
    if (newEnableICloudSync == null) return;

    UserPreferencesService().enableICloudSync = newEnableICloudSync;

    if (!mounted) return;

    setState(() {});
  }
}
