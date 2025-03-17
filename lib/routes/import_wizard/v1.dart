import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/sync/import/import_v1.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/import_wizard/backup_info.dart";
import "package:flow/widgets/import_wizard/import_success.dart";
import "package:flutter/material.dart";

class ImportWizardV1Page extends StatefulWidget {
  final ImportV1 importer;
  final bool setupMode;

  const ImportWizardV1Page({
    super.key,
    required this.importer,
    this.setupMode = false,
  });

  @override
  State<ImportWizardV1Page> createState() => _ImportWizardV1PageState();
}

class _ImportWizardV1PageState extends State<ImportWizardV1Page> {
  ImportV1 get importer => widget.importer;

  dynamic error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("sync.import".t(context))),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: importer.progressNotifier,
          builder:
              (context, value, child) => switch (value) {
                ImportV1Progress.waitingConfirmation => BackupInfo(
                  importer: importer,
                  onClickStart: _start,
                ),
                ImportV1Progress.error => Text(error.toString()),
                ImportV1Progress.success => ImportSuccess(
                  setupMode: widget.setupMode,
                ),
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
    final bool? confirm = await context.showConfirmationSheet(
      title: "sync.import.eraseWarning".t(context),
      isDeletionConfirmation: true,
      mainActionLabelOverride: "general.confirm".t(context),
    );

    if (confirm != true) return;

    try {
      await importer.execute();
    } catch (e) {
      error = e;
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }
}
