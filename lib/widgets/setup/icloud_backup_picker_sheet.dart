import "package:flow/l10n/flow_localizations.dart";
import "package:flow/services/sync/syncer.dart";
import "package:flow/utils/extensions.dart";
import "package:flow/widgets/general/directional_chevron.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:moment_dart/moment_dart.dart";
import "package:path/path.dart" as path;

/// Pops with [SyncerItem] when a backup is selected.
class ICloudBackupPickerSheet extends StatefulWidget {
  final List<SyncerItem> backups;

  const ICloudBackupPickerSheet({super.key, required this.backups});

  @override
  State<ICloudBackupPickerSheet> createState() =>
      _ICloudBackupPickerSheetState();
}

class _ICloudBackupPickerSheetState extends State<ICloudBackupPickerSheet> {
  @override
  Widget build(BuildContext context) {
    final List<SyncerItem> eligibleItems = widget.backups
        .where((item) => item.inferredBackupDate != null)
        .toList();

    return ModalSheet.scrollable(
      title: Text("setup.onboarding.recoverICloudBackup".t(context)),
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: eligibleItems
                .map(
                  (backup) => ListTile(
                    leading: FlowIcon(backup.path.backupExtensionIcon),
                    title: Text(backup.inferredBackupDate!.toMoment().lll),
                    subtitle: Text(path.extension(backup.path).substring(1)),
                    onTap: () => context.pop(backup),
                    trailing: LeChevron(),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
