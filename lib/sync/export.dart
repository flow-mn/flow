import "dart:async";
import "dart:io";
import "dart:math";

import "package:flow/entity/backup_entry.dart";
import "package:flow/logging.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/services/sync.dart";
import "package:flow/services/sync/icloud_syncer.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/sync/export/export_csv.dart";
import "package:flow/sync/export/export_pdf.dart";
import "package:flow/sync/export/export_v1.dart";
import "package:flow/sync/export/export_v2.dart";
import "package:flow/sync/export/mode.dart";
import "package:flow/sync/sync.dart";
import "package:flow/utils/utils.dart";
import "package:flutter/foundation.dart";
import "package:moment_dart/moment_dart.dart";
import "package:path/path.dart" as path;
import "package:path_provider/path_provider.dart";
import "package:share_plus/share_plus.dart";

const int _automatedBackupsToKeep = 5;

typedef ExportResult = ({
  bool shareDialogSucceeded,
  String filePath,
  Future<int?> objectBoxId,
});

/// Exports all user data (except for profile for now) in the format specified.
///
///
/// [mode] - defaults to `json`, see [ExportMode]
/// [subfolder] - Will put the backup in a subfolder. May be useful for
/// automated backups
Future<ExportResult> export({
  required BackupEntryType type,
  ExportMode mode = ExportMode.zip,
  bool showShareDialog = true,
  String? subfolder,
  dynamic options,
}) async {
  final Directory appSupportDirectory = await getApplicationSupportDirectory();

  final dynamic extra = switch (mode) {
    _ => null,
  };

  final backupContent = await switch (mode) {
    ExportMode.pdf => generatePDFContent(options: options),
    _ => compute(
      (_) => getBackupContent(
        mode: mode,
        options: options,
        appSupportDirectory: appSupportDirectory,
        extra: extra,
      ),
      null,
    ),
  };

  final savedFilePath = await saveBackupFile(
    backupContent,
    fileExt: mode.fileExt,
    subfolder: subfolder,
    type: type,
  );

  final BackupEntry entry = BackupEntry(
    filePath: savedFilePath,
    type: type.value,
    fileExt: mode.fileExt,
  );

  final Future<int> objectBoxId = ObjectBox()
      .box<BackupEntry>()
      .putAsync(entry)
      .catchError((error) {
        syncLogger.warning(
          "After a successful backup, failed to add BackupEntry for it",
          error,
        );
        return -1;
      });

  if (type == BackupEntryType.automated) {
    unawaited(
      objectBoxId.then((_) => _pruneAutomatedBackups()).catchError((error) {
        syncLogger.warning("Failed to prune automated backups", error);
      }),
    );
  }

  if (ICloudSyncer.supported && type == BackupEntryType.manual) {
    syncLogger.info("Trying to save manual backup to iCloud");

    try {
      if (!UserPreferencesService().enableICloudSync) {
        throw Exception("User has disabled iCloud sync");
      }

      syncLogger.info(
        "User has enabled iCloud sync, attempting to upload manual backup to iCloud (${entry.filePath})",
      );

      // Upload to iCloud if the user has enabled it
      unawaited(
        SyncService()
            .putToAll(entry)
            .then((_) {
              syncLogger.info(
                "Successfully uploaded manual backup to iCloud (${entry.filePath})",
              );
            })
            .catchError((e, stackTrace) {
              syncLogger.warning(
                "Failed to upload manual backup to iCloud (${entry.filePath})",
                e,
                stackTrace,
              );
            }),
      );
    } catch (e, stackTrace) {
      syncLogger.warning(
        "Failed to instantiate iCloud backups for manual",
        e,
        stackTrace,
      );
    }
  }

  if (!showShareDialog) {
    return (
      shareDialogSucceeded: false,
      filePath: savedFilePath,
      objectBoxId: objectBoxId,
    );
  }

  return await showFileSaveDialog(savedFilePath, objectBoxId);
}

Future<Object> getBackupContent({
  required ExportMode mode,
  required Directory appSupportDirectory,
  dynamic options,
  dynamic extra,
}) async {
  await ObjectBox.initialize(appSupportDirectory: appSupportDirectory);

  return await switch ((mode, latestSyncModelVersion)) {
    (ExportMode.csv, _) => generateCSVContent(),
    (ExportMode.json, 1) => generateBackupContentV1(),
    (ExportMode.json, 2) => generateBackupJSONContentV2(),
    (ExportMode.zip, 2) => generateBackupZipV2(),
    (ExportMode.pdf, _) => throw UnimplementedError(
      "Exporting PDF in a separate isolate isn't supported yet",
    ),
    _ => throw UnimplementedError(),
  };
}

/// Returns file path after successfully saving it
Future<String> saveBackupFile(
  dynamic backupContent, {
  required String fileExt,
  required BackupEntryType type,
  String? subfolder,
}) async {
  // Save to cache if it's possible to share later.
  // Otherwise, save to documents directory, and reveal the file on system.

  final Directory saveDir = Directory(
    path.join(ObjectBox.appDataDirectory, "backups"),
  );
  final String filename = generateBackupFileName(fileExt);

  syncLogger.fine("Writing to ${path.join(saveDir.path, filename)}");

  final File f = File(path.join(saveDir.path, subfolder ?? "", filename));
  f.createSync(recursive: true);
  switch (backupContent) {
    case String utf8:
      f.writeAsStringSync(utf8);
      break;
    case Uint8List bytes:
      f.writeAsBytesSync(bytes);
      break;
    case File file:
      await _moveFile(file, f.path);
      break;
    default:
      throw UnimplementedError();
  }

  syncLogger.fine("Write successful. See file at: ${f.path}");

  return f.path;
}

/// Renames when possible, otherwise copies and deletes [source].
Future<void> _moveFile(File source, String destination) async {
  try {
    await source.rename(destination);
  } on FileSystemException {
    try {
      await source.copy(destination);
    } finally {
      await source.delete().catchError((error) {
        syncLogger.warning("Failed to delete temporary backup file", error);
        return source;
      });
    }
  }
}

/// Keeps the [_automatedBackupsToKeep] most recent automated backups and
/// deletes the rest, so deleted data doesn't linger in old backups.
Future<void> _pruneAutomatedBackups() async {
  final Query<BackupEntry> query = ObjectBox()
      .box<BackupEntry>()
      .query(BackupEntry_.type.equals(BackupEntryType.automated.value))
      .order(BackupEntry_.createdDate, flags: Order.descending)
      .build();

  query.offset = _automatedBackupsToKeep;

  final List<BackupEntry> stale = query.find();
  query.close();

  for (final BackupEntry entry in stale) {
    if (!await entry.delete()) {
      syncLogger.warning("Failed to prune automated backup ${entry.filePath}");
    }
  }
}

/// Returns whether the file was saved/revealed successfully
Future<ExportResult> showFileSaveDialog(
  String savedFilePath,
  Future<int?> objectBoxId,
) async {
  // Sharing [XFile]s aren't supported yet on Linux.
  //
  // https://pub.dev/packages/share_plus#platform-support
  final bool isShareSupported = !(Platform.isLinux || Platform.isFuchsia);

  bool shareSuccess;

  if (isShareSupported) {
    final shareResult = await SharePlus.instance.share(
      ShareParams(
        files: [XFile(savedFilePath)],
        subject: path.basename(savedFilePath),
        text: "Backup for Flow",
      ),
    );

    shareSuccess = shareResult.status == ShareResultStatus.success;
  } else {
    shareSuccess = await openUrl(
      Uri(scheme: "file", path: path.dirname(savedFilePath)),
    );
  }

  final uri = Uri(scheme: "file", path: path.dirname(savedFilePath));

  syncLogger.fine("shareSuccess $shareSuccess $uri");

  return (
    shareDialogSucceeded: shareSuccess,
    filePath: savedFilePath,
    objectBoxId: objectBoxId,
  );
}

String generateBackupFileName(String fileExt) {
  final String dateTime = Moment.now().format("YYYY-MM-DD_HH-mm-ss");
  final String tag = tags[Random().nextInt(tags.length)];
  return "flow_backup_${tag}_$dateTime.$fileExt";
}

const List<String> tags = [
  "americano",
  "canadiano",
  "espresso",
  "latte",
  "cappuccino",
  "espresso_macchiato",
  "mocha",
  "flat_white",
  "cortado",
  "gibraltar",
  "ristretto",
  "lungo",
  "cold_brew",
  "affogato",
  "turkish",
  "vietnamese_iced",
  "irish",
  "vanilla_latte",
  "caramel_macchiato",
  "tiramisu",
  "creme_brulee",
  "coffee_cake",
  "biscotti",
  "with_ghee",
];
