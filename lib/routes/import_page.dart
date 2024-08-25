import "dart:developer";
import "dart:io";

import "package:flow/l10n/extensions.dart";
import "package:flow/sync/import.dart";
import "package:flow/sync/import/base.dart";
import "package:flow/utils/toast.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/import/file_select_area.dart";
import "package:flutter/material.dart";
import "package:cross_file/cross_file.dart";
import "package:go_router/go_router.dart";

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

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
      appBar: AppBar(
        title: Text("sync.import".t(context)),
      ),
      body: SafeArea(
        child: busy
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
      importer = await importBackupV1(
        backupFile: backupFile,
      );

      if (mounted) {
        switch (importer) {
          case ImportV1 importV1:
            context.pushReplacement("/import/wizard/v1", extra: importV1);
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
      log("[Flow Import Page] An error was thrown from `importBackupV1`:\n $e");
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
    log("file: $file");

    if (file == null) {
      context.showErrorToast(error: "error.input.noFilePicked".t(context));
      return;
    }

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
