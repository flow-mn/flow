import "dart:async";

import "package:flow/data/transaction_filter.dart";
import "package:flow/entity/backup_entry.dart";
import "package:flow/objectbox.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/icloud_sync.dart";
import "package:flow/services/transactions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/sync/export.dart";
import "package:flow/widgets/utils/should_execute_scheduled_task.dart";
import "package:logging/logging.dart";
import "package:moment_dart/moment_dart.dart";
import "package:objectbox/objectbox.dart";
import "package:path/path.dart" as path;

final Logger _log = Logger("SyncService");

class SyncService {
  static SyncService? _instance;

  factory SyncService() => _instance ??= SyncService._internal();

  SyncService._internal() {
    triggerAutoBackup();
    unawaited(ICloudSyncService().gather());
  }

  Future<void> triggerAutoBackup() async {
    try {
      final int? intervalHours =
          UserPreferencesService().autoBackupIntervalInHours;

      if (intervalHours == null) {
        _log.info("Auto backup is disabled");
        return;
      }

      final DateTime? lastBackup =
          TransitiveLocalPreferences().lastAutoBackupRanAt.value;

      if (!shouldExecuteScheduledTask(
        Duration(hours: intervalHours),
        lastBackup,
      )) {
        _log.info(
          "Auto backup is not due yet (last ran at: ${lastBackup?.toIso8601String()})",
        );
        return;
      }

      if (TransactionsService().countMany(TransactionFilter.empty) == 0) {
        _log.info(
          "Auto backup is cancelled due to having no transactions (last ran at: ${lastBackup?.toIso8601String()})",
        );
        return;
      }

      final result = await export(
        type: BackupEntryType.automated,
        showShareDialog: false,
      );

      unawaited(saveToICloud(result));

      final Moment now = Moment.now();

      await TransitiveLocalPreferences().lastAutoBackupRanAt.set(now);
      await TransitiveLocalPreferences().lastAutoBackupPath.set(
        result.filePath,
      );
      _log.info("Auto backup successfully ran at $now");
    } catch (e, stackTrace) {
      _log.severe("Failed to perform auto-backup", e, stackTrace);
    }
  }

  Future<void> saveToICloud(ExportResult result) async {
    try {
      final String extension = path.extension(result.filePath);

      final String tempPath = await ICloudSyncService().upload(
        filePath: result.filePath,
        destinationRelativePath: "temp-autobackup-$extension",
      );

      final String iCloudRelativePath = await ICloudSyncService().move(
        from: tempPath,
        to: "autobackup-$extension",
      );

      _log.info(
        "Auto backup successfully uploaded to iCloud -> ${result.filePath}",
      );

      try {
        final int? objectBoxId = await result.objectBoxId;

        if (objectBoxId == null) {
          throw Exception("objectBoxId is null");
        }

        final BackupEntry? entry = ObjectBox().box<BackupEntry>().get(
          objectBoxId,
        );

        if (entry == null) {
          throw Exception(
            "BackupEntry not found for objectBoxId: $objectBoxId",
          );
        }

        entry.iCloudRelativePath = iCloudRelativePath;

        ObjectBox().box<BackupEntry>().put(entry, mode: PutMode.update);
      } catch (e, stackTrace) {
        _log.warning("Failed to amend BackupEntry", e, stackTrace);
      }
    } catch (e, stackTrace) {
      _log.severe("Failed to upload backup to iCloud", e, stackTrace);
      return;
    }
  }
}
