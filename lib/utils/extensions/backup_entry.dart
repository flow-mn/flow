import "package:flow/entity/backup_entry.dart";
import "package:flow/services/icloud_sync.dart";
import "package:flow/services/sync.dart";
import "package:flow/utils/utils.dart";
import "package:icloud_storage/icloud_storage.dart";
import "package:moment_dart/moment_dart.dart";
import "package:path/path.dart" as path;

extension BackupEntryExtension on BackupEntry {
  String get iCloudBackupFolder =>
      path.join(SyncService.cloudBackupsFolder, type);

  ICloudFile? get correspondingFile {
    if (iCloudChangeDate == null) return null;
    if (iCloudRelativePath == null) return null;

    try {
      final List<ICloudFile> files = ICloudSyncService().filesCache.value;

      return files.firstWhereOrNull(
        (file) =>
            file.relativePath == iCloudRelativePath &&
            file.contentChangeDate.startOfSecond() ==
                iCloudChangeDate?.startOfSecond(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Whether the file can be uploaded to iCloud.
  bool get canUploadToCloud {
    if (correspondingFile != null) return false;
    if (!ICloudSyncService.supported) return false;

    try {
      final List<ICloudFile> files = ICloudSyncService().filesCache.value;

      final ICloudFile? samePathFile = files.firstWhereOrNull(
        (file) => path.equals(
          file.relativePath,
          path.join(
            SyncService.cloudBackupsFolder,
            type,
            "${SyncService.cloudFileBaseName}.$fileExt",
          ),
        ),
      );

      if (samePathFile == null) return true;

      return samePathFile.contentChangeDate < createdDate;
    } catch (e) {
      return false;
    }
  }
}
