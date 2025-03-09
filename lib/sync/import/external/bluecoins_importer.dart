import "dart:io";

import "package:flow/sync/import/base.dart";
import "package:flow/sync/import/external/external_import_progress.dart";
import "package:flutter/foundation.dart";
import "package:sqlite3/sqlite3.dart";

class BluecoinsImporter extends Importer {
  @override
  final File data;

  BluecoinsImporter(this.data);

  @override
  Future<String?> execute({bool ignoreSafetyBackupFail = false}) {
    final Database db = sqlite3.open(data.path);

    final result = db.select("SELECT * FROM accounts");

    for (final row in result) {
      print(row);
    }

    return Future.value(null);
  }

  @override
  ValueNotifier<ExternalImportProgress> get progressNotifier =>
      ValueNotifier(ExternalImportProgress.waitingConfirmation);
}
