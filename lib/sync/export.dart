import "dart:async";
import "dart:io";
import "dart:math";
import "dart:typed_data";

import "package:flow/entity/backup_entry.dart";
import "package:flow/logging.dart";
import "package:flow/objectbox.dart";
import "package:flow/services/icloud_sync.dart";
import "package:flow/services/sync.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/sync/export/export_csv.dart";
import "package:flow/sync/export/export_v1.dart";
import "package:flow/sync/export/export_v2.dart";
import "package:flow/sync/export/mode.dart";
import "package:flow/sync/sync.dart";
import "package:flow/utils/utils.dart";
import "package:moment_dart/moment_dart.dart";
import "package:path/path.dart" as path;
import "package:share_plus/share_plus.dart";

typedef ExportResult =
    ({bool shareDialogSucceeded, String filePath, Future<int?> objectBoxId});

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
}) async {
  // Sharing [XFile]s aren't supported yet on Linux.
  //
  // https://pub.dev/packages/share_plus#platform-support
  final bool isShareSupported = !(Platform.isLinux || Platform.isFuchsia);

  final backupContent = switch ((mode, latestSyncModelVersion)) {
    (ExportMode.csv, _) => await generateCSVContent(),
    (ExportMode.json, 1) => await generateBackupContentV1(),
    (ExportMode.json, 2) => await generateBackupJSONContentV2(),
    (ExportMode.zip, 2) => await generateBackupZipV2(),
    _ => throw UnimplementedError(),
  };
  final savedFilePath = await saveBackupFile(
    backupContent,
    isShareSupported,
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

  if (ICloudSyncService.supported && type == BackupEntryType.manual) {
    syncLogger.info("Trying to save manual backup to iCloud");

    try {
      if (!UserPreferencesService().enableICloudSync) {
        throw Exception("User has disabled iCloud sync");
      }

      // Upload to iCloud if the user has enabled it
      await SyncService().saveBackupToICloud(
        entry: entry,
        parent: SyncService.cloudUserBackupsFolder,
        onProgress: (progress) {
          syncLogger.fine(
            "iCloud upload progress for manual backup: $progress",
          );
        },
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

  return await showFileSaveDialog(savedFilePath, isShareSupported, objectBoxId);
}

/// Returns file path after successfully saving it
Future<String> saveBackupFile(
  dynamic backupContent,
  bool isShareSupported, {
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
      file.copySync(f.path);
      break;
    default:
      throw UnimplementedError();
  }

  syncLogger.fine("Write successful. See file at: ${f.path}");

  return f.path;
}

/// Returns whether the file was saved/revealed successfully
Future<ExportResult> showFileSaveDialog(
  String savedFilePath,
  bool isShareSupported,
  Future<int?> objectBoxId,
) async {
  bool shareSuccess;

  if (isShareSupported) {
    final shareResult = await Share.shareXFiles(
      [XFile(savedFilePath)],
      subject: path.basename(savedFilePath),
      text: "Backup for Flow",
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
