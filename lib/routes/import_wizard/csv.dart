import "dart:developer";

import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/sync/import/import_csv.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/import_wizard/backup_info.dart";
import "package:flow/widgets/import_wizard/import_error.dart";
import "package:flow/widgets/import_wizard/import_progress.dart";
import "package:flow/widgets/import_wizard/import_success.dart";
import "package:flutter/material.dart";

class CSVImportWizardPage extends StatefulWidget {
  final ImportCSV importer;
  final bool setupMode;

  const CSVImportWizardPage({
    super.key,
    required this.importer,
    this.setupMode = false,
  });

  @override
  State<CSVImportWizardPage> createState() => _CSVImportWizardPageState();
}

class _CSVImportWizardPageState extends State<CSVImportWizardPage> {
  ImportCSV get importer => widget.importer;

  dynamic error;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: importer.progressNotifier,
      builder: (context, value, child) => switch (value) {
        ImportCSVProgress.waitingConfirmation => BackupInfo(
          importer: importer,
          onClickStart: _start,
        ),
        ImportCSVProgress.error => ImportError(error),
        ImportCSVProgress.success => ImportSuccess(setupMode: widget.setupMode),
        _ => ImportProgressIndicator(value.localizedNameContext(context)),
      },
    );
  }

  void _start() async {
    if (!widget.setupMode) {
      final bool? confirm = await context.showConfirmationSheet(
        title: "sync.import.eraseWarning".t(context),
        isDeletionConfirmation: true,
        mainActionLabelOverride: "general.confirm".t(context),
      );

      if (confirm != true) return;
    }

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
