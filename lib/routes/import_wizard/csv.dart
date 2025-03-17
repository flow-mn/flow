import "dart:developer";

import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/sync/import/import_csv.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/import_wizard/backup_info.dart";
import "package:flow/widgets/import_wizard/import_success.dart";
import "package:flutter/material.dart";

class ImportWizardCSVPage extends StatefulWidget {
  final ImportCSV importer;
  final bool setupMode;

  const ImportWizardCSVPage({
    super.key,
    required this.importer,
    this.setupMode = false,
  });

  @override
  State<ImportWizardCSVPage> createState() => _ImportWizardCSVPageState();
}

class _ImportWizardCSVPageState extends State<ImportWizardCSVPage> {
  ImportCSV get importer => widget.importer;

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
                ImportCSVProgress.waitingConfirmation => BackupInfo(
                  importer: importer,
                  onClickStart: _start,
                ),
                ImportCSVProgress.error => Text(error.toString()),
                ImportCSVProgress.success => ImportSuccess(
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
    } catch (e, stackTrace) {
      error = e;
      log("[Flow Sync CSV] Import failed", error: e, stackTrace: stackTrace);
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }
}
