import "dart:async";

import "package:flow/data/transaction_filter.dart";
import "package:flow/entity/backup_entry.dart";
import "package:flow/objectbox.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/sync/icloud_syncer.dart";
import "package:flow/services/transactions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/sync/export.dart";
import "package:flow/widgets/utils/should_execute_scheduled_task.dart";
import "package:logging/logging.dart";
import "package:moment_dart/moment_dart.dart";

final Logger _log = Logger("SyncService");

class SyncService {
  static const String cloudBackupsFolder = "backups";

  static const String cloudFileBaseName = "latest";

  static SyncService? _instance;

  factory SyncService() => _instance ??= SyncService._internal();

  int get activeSyncersCount {
    int value = 0;

    try {
      if (ICloudSyncer.supported &&
          ICloudSyncer().syncing &&
          UserPreferencesService().enableICloudSync) {
        value++;
      }
    } catch (e) {
      _log.warning("Failed to get active syncers count", e);
    }

    return value;
  }

  bool get working => activeSyncersCount > 0;

  SyncService._internal() {
    triggerAutoBackup().then((_) {
      if (ICloudSyncer.supported) {
        Future.delayed(const Duration(seconds: 2)).then((_) {
          ICloudSyncer().purge(
            keepCount: UserPreferencesService().iCloudBackupsToKeep ?? 5,
          );
        });
      }
    });
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

        unawaited(putToAll(entry));
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

  // TODO @sadespresso - enable multi-syncer support
  Future<bool> putToAll(
    BackupEntry entry, {
    Function(double)? onProgress,
  }) async {
    if (ICloudSyncer.supported) {
      final bool result = await ICloudSyncer().put(
        entry,
        onProgress: onProgress,
      );
      unawaited(
        TransitiveLocalPreferences().iCloudSyncWorkingFine
            .set(result)
            .catchError((e) {
              _log.warning("Failed to set iCloudSyncWorkingFine preference", e);
              return false;
            }),
      );
      _log.info("Uploaded backup to iCloud: ${entry.filePath}");
      return result;
    } else {
      _log.warning("ICloudSyncer is not supported, skipping upload");
      return false;
    }
  }
}
