import 'dart:developer';
import 'dart:io';

import 'package:flow/l10n/extensions.dart';
import 'package:flow/sync/import.dart';
import 'package:flow/sync/import/base.dart';
import 'package:flow/utils/toast.dart';
import 'package:flow/widgets/general/spinner.dart';
import 'package:flow/widgets/import/backup_file_info_v1.dart';
import 'package:flow/widgets/import/file_select_area.dart';
import 'package:flow/widgets/import/import_progress_indicator_v1.dart';
import 'package:flutter/material.dart';
import 'package:cross_file/cross_file.dart';

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
        child: switch ((busy, importer)) {
          (true, null) => const Spinner.center(),
          (false, null) => FileSelectArea(
              onFileDropped: initiateImportFromDroppedFile,
              onTap: initiateImport,
            ),
          (false, ImportV1 importV1) =>
            BackupFileInfoV1(onTap: _start, importer: importV1),
          (true, ImportV1 importV1) => ImportProgressIndicatorV1(
              startFn: _start,
              importV1: importV1,
            ),
          (_, _) => const Text("Impossible state"),
        },
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

  void _start() async {
    if (importer == null) return;

    try {
      await importer!.execute();
    } catch (e) {
      error = e;
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }
}
