import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/transitive.dart";
import "package:flow/services/local_auth.dart";
import "package:flow/services/sync/icloud_syncer.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions/custom_popups.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/icloud_failed_error_box.dart";
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
  bool iCloudSyncWorkingFine = true;

  @override
  void initState() {
    super.initState();

    TransitiveLocalPreferences().iCloudSyncWorkingFine.addListener(
      _updateICloudSyncWorkingFine,
    );
    _updateICloudSyncWorkingFine();
  }

  @override
  void dispose() {
    TransitiveLocalPreferences().iCloudSyncWorkingFine.removeListener(
      _updateICloudSyncWorkingFine,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool enableICloudSync = UserPreferencesService().enableICloudSync;

    final DateTime? lastSuccessfulICloudSyncAt = TransitiveLocalPreferences()
        .lastSuccessfulICloudSyncAt
        .get();

    final int iCloudBackupsToKeep =
        UserPreferencesService().iCloudBackupsToKeep ?? 5;

    final List<int?> options = [3, 5, 10, 20, 30, 100, -1];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: .start,
      spacing: 8.0,
      children: [
        if (ICloudSyncer.supported && !iCloudSyncWorkingFine)
          ICloudFailedErrorBox(),
        SwitchListTile(
          secondary: const Icon(Symbols.cloud_rounded),
          title: Text("preferences.sync.iCloud".t(context)),
          value: enableICloudSync,
          onChanged: updateEnableICloudSync,
          subtitle: lastSuccessfulICloudSyncAt != null
              ? Text(
                  "preferences.sync.iCloud.lastSyncedAt".t(
                    context,
                    lastSuccessfulICloudSyncAt.toMoment().lll,
                  ),
                  style: context.textTheme.bodySmall,
                )
              : null,
        ),
        Frame(
          child: InfoText(
            child: Text("preferences.sync.iCloud.privacyNotice".t(context)),
          ),
        ),
        const SizedBox(height: 16.0),
        ListHeader("preferences.sync.iCloud.noOfBackupsToKeep".t(context)),
        const SizedBox(height: 8.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Wrap(
            spacing: 12.0,
            runSpacing: 8.0,
            children: options
                .map(
                  (value) => FilterChip(
                    showCheckmark: false,
                    key: ValueKey(value),
                    label: Text(
                      value == -1
                          ? "preferences.sync.iCloud.noOfBackupsToKeep.infiniteBackups"
                                .t(context)
                          : "preferences.sync.iCloud.noOfBackupsToKeep.nBackups"
                                .t(context, value),
                    ),
                    onSelected: (bool selected) =>
                        selected ? updateICloudBackupsToKeep(value) : null,
                    selected: value == iCloudBackupsToKeep,
                  ),
                )
                .toList(),
          ),
        ),
        Frame(
          child: InfoText(
            child: Text(
              "preferences.sync.iCloud.noOfBackupsToKeep.description".t(
                context,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void updateICloudBackupsToKeep(int? newICloudBackupsToKeep) async {
    if (newICloudBackupsToKeep == null) return;

    UserPreferencesService().iCloudBackupsToKeep = newICloudBackupsToKeep;

    setState(() {});
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

  void _updateICloudSyncWorkingFine() {
    if (!ICloudSyncer.supported) return;
    if (!ICloudSyncer().syncing) return;

    iCloudSyncWorkingFine = TransitiveLocalPreferences().iCloudSyncWorkingFine
        .get();
    if (mounted) {
      setState(() {});
    }
  }
}
