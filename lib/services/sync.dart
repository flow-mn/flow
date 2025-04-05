import "dart:async";

import "package:flow/data/transaction_filter.dart";
import "package:flow/entity/backup_entry.dart";
import "package:flow/objectbox.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/icloud_sync.dart";
import "package:flow/services/transactions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/sync/export.dart";
import "package:flow/utils/extensions/iterables.dart";
import "package:flow/widgets/utils/should_execute_scheduled_task.dart";
import "package:logging/logging.dart";
import "package:moment_dart/moment_dart.dart";
import "package:objectbox/objectbox.dart";
import "package:path/path.dart" as path;

final Logger _log = Logger("SyncService");

class SyncService {
  static const String cloudAutobackupsFolder = "autobackups";
  static const String cloudUserBackupsFolder = "userbackups";

  static const String cloudFileBaseName = "latest";

  static SyncService? _instance;

  factory SyncService() => _instance ??= SyncService._internal();

  SyncService._internal() {
    triggerAutoBackup();
    unawaited(ICloudSyncService.initialize());
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

      try {
        final int? id = await result.objectBoxId;

        if (id == null || id < 1) {
          throw Exception("Failed to get objectBoxId from export result");
        }

        final BackupEntry? entry = ObjectBox().box<BackupEntry>().get(id);

        if (entry == null) {
          throw Exception("Failed to get BackupEntry from objectBoxId: $id");
        }

        unawaited(
          saveBackupToICloud(entry: entry, parent: cloudAutobackupsFolder),
        );
      } catch (e, stackTrace) {
        _log.warning(
          "Failed to upload backup to iCloud: ${result.filePath}",
          e,
          stackTrace,
        );
      }

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

  Future<void> saveBackupToICloud({
    required BackupEntry entry,
    required String parent,
    Function(Stream<double>)? onProgress,
  }) async {
    if (!UserPreferencesService().enableICloudSync) {
      _log.info("Cancelling iCloud upload since user hasn't enabled it");
      return;
    }

    final bool hasNewerBackup = ICloudSyncService().filesCache.value.any((
      iCloudFile,
    ) {
      if (path.dirname(iCloudFile.relativePath) != "parent") return false;
      if (path.extension(iCloudFile.relativePath) !=
          path.extension(entry.filePath)) {
        return false;
      }

      return iCloudFile.contentChangeDate.isAfter(
        entry.createdDate.startOfSecond(),
      );
    });

    if (hasNewerBackup) {
      _log.info(
        "Cancelling iCloud upload since user has newer backup for this parent folder, and type.",
      );
      throw Exception(
        "User has newer backup for this parent folder, and type.",
      );
    }

    if (entry.iCloudRelativePath != null &&
        ICloudSyncService().filesCache.value.firstWhereOrNull(
              (file) =>
                  path.dirname(file.relativePath) == parent &&
                  path.extension(file.relativePath) ==
                      path.extension(entry.filePath) &&
                  file.contentChangeDate.startOfSecond() ==
                      entry.iCloudChangeDate?.startOfSecond(),
            ) !=
            null) {
      _log.info(
        "Backup (${entry.iCloudRelativePath}) already uploaded to iCloud",
      );
      return;
    }

    try {
      final DateTime now = DateTime.now();

      final String iCloudRelativePath = await ICloudSyncService().upload(
        filePath: entry.filePath,
        destinationRelativePath: "$parent/$cloudFileBaseName.${entry.fileExt}",
        onProgress: onProgress,
        modifiedDate: now,
      );

      _log.info(
        "Auto backup successfully uploaded to iCloud -> ${entry.filePath}",
      );

      try {
        unawaited(
          TransitiveLocalPreferences().lastSuccessfulICloudSyncAt.set(now),
        );
      } catch (e) {
        _log.warning("Failed to set lastSuccessfulICloudSyncAt", e);
      }

      try {
        entry.iCloudRelativePath = iCloudRelativePath;
        entry.iCloudChangeDate = now;

        _log.info(
          "BackupEntry updated with iCloud information: ${entry.iCloudRelativePath}",
        );

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
