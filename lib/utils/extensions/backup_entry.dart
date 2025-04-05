import "package:flow/entity/backup_entry.dart";
import "package:flow/services/icloud_sync.dart";
import "package:flow/utils/utils.dart";
import "package:icloud_storage/icloud_storage.dart";
import "package:moment_dart/moment_dart.dart";

extension BackupEntryExtension on BackupEntry {
  ICloudFile? get correspondingFile {
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
}
