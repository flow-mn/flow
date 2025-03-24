import "dart:io";

import "package:cross_file/cross_file.dart";
import "package:flow/constants.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/sync/import.dart";
import "package:flow/sync/import/base.dart";
import "package:flow/sync/import/import_csv.dart";
import "package:flow/sync/import/import_v2.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/import/file_select_area.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:logging/logging.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:simple_icons/simple_icons.dart";

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
                : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FileSelectArea(
                        onFileDropped: initiateImportFromDroppedFile,
                        onTap: initiateImport,
                      ),
                      const SizedBox(height: 16.0),
                      ListHeader("sync.import.other".t(context)),
                      const SizedBox(height: 8.0),
                      ListTile(
                        leading: Icon(SimpleIcons.googlesheets),
                        trailing: Icon(Symbols.chevron_right_rounded),
                        title: Text("sync.import.getCSVTemplate".t(context)),
                        onTap: () => openUrl(csvImportTemplateUrl),
                      ),
                    ],
                  ),
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
    } catch (e, stackTrace) {
      _log.severe("Importer error", e, stackTrace);
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
