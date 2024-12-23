import "dart:developer";

import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/sync/import/import_v2.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/import_wizard/backup_info.dart";
import "package:flow/widgets/import_wizard/import_success.dart";
import "package:flutter/material.dart";

class ImportWizardV2Page extends StatefulWidget {
  final ImportV2 importer;

  const ImportWizardV2Page({super.key, required this.importer});

  @override
  State<ImportWizardV2Page> createState() => _ImportWizardV2PageState();
}

class _ImportWizardV2PageState extends State<ImportWizardV2Page> {
  ImportV2 get importer => widget.importer;

  dynamic error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("sync.import".t(context)),
      ),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: importer.progressNotifier,
          builder: (context, value, child) => switch (value) {
            ImportV2Progress.waitingConfirmation => BackupInfo(
                importer: importer,
                onClickStart: _start,
              ),
            ImportV2Progress.error => Text(error.toString()),
            ImportV2Progress.success => const ImportSuccess(),
            _ => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Spinner.center(),
                    Center(
                      child: Text(
                        value.localizedNameContext(context),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
          },
        ),
      ),
    );
  }

  void _start() async {
    final bool? confirm = await context.showConfirmDialog(
      title: "sync.import.eraseWarning".t(context),
      isDeletionConfirmation: true,
      mainActionLabelOverride: "general.confirm".t(context),
    );

    if (confirm != true) return;

    try {
      await importer.execute();
    } catch (e) {
      error = e;
      log("[Flow Sync V2] Import failed", error: e);
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }
}
