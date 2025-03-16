import "dart:io";

import "package:cross_file/cross_file.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/sync/import.dart";
import "package:flow/sync/import/base.dart";
import "package:flow/sync/import/import_csv.dart";
import "package:flow/sync/import/import_v2.dart";
import "package:flow/utils/extensions/toast.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/import/file_select_area.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:logging/logging.dart";

final Logger _log = Logger("ImportPage");

class ImportPage extends StatefulWidget {
  final bool? setupMode;

  const ImportPage({this.setupMode = false, super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  Importer? importer;

  bool busy = false;

  dynamic error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("sync.import".t(context))),
      body: SafeArea(
        child:
            busy
                ? const Spinner.center()
                : FileSelectArea(
                  onFileDropped: initiateImportFromDroppedFile,
                  onTap: initiateImport,
                ),
      ),
    );
  }

  Future<void> initiateImport([File? backupFile]) async {
    if (busy) return;

    setState(() {
      busy = true;
    });

    try {
      importer = await importBackup(backupFile: backupFile);

      if (mounted) {
        switch (importer) {
          case ImportV1 importV1:
            context.pushReplacement(
              "/import/wizard/v1?setupMode=${widget.setupMode}",
              extra: importV1,
            );
            break;
          case ImportV2 importV2:
            context.pushReplacement(
              "/import/wizard/v2?setupMode=${widget.setupMode}",
              extra: importV2,
            );
            break;
          case ImportCSV importCSV:
            context.pushReplacement(
              "/import/wizard/csv?setupMode=${widget.setupMode}",
              extra: importCSV,
            );
            break;
          case null:
            context.showErrorToast(
              error: "error.input.noFilePicked".t(context),
            );
            break;
          default:
            context.showErrorToast(
              error: "error.sync.invalidBackupFile".t(context),
            );
            break;
        }
      }
    } catch (e) {
      _log.severe("Importer error", e);
      if (mounted) {
        context.showErrorToast(error: e);
      }
    } finally {
      busy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> initiateImportFromDroppedFile(XFile? file) async {
    if (file == null) {
      context.showErrorToast(error: "error.input.noFilePicked".t(context));
      return;
    }

    _log.fine("Trying to import from dragged file: ${file.path}");

    final backupFile = File(file.path);

    if (!(await backupFile.exists())) {
      if (mounted) {
        context.showErrorToast(error: "error.input.noFilePicked".t(context));
      }
      return;
    }

    return initiateImport(backupFile);
  }
}
