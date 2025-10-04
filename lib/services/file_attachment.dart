import "dart:io";

import "package:flow/entity/file_attachment.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:logging/logging.dart";

final Logger _log = Logger("FileAttachmentService");

class FileAttachmentService {
  static FileAttachmentService? _instance;

  factory FileAttachmentService() =>
      _instance ??= FileAttachmentService._internal();

  FileAttachmentService._internal() {
    // Constructor
  }

  void upsertManySync(List<FileAttachment> fileAttachments) {
    try {
      final box = ObjectBox().box<FileAttachment>();
      box.putMany(fileAttachments);
    } catch (e, stackTrace) {
      _log.severe("Failed to upsert FileAttachments", e, stackTrace);
    }
  }

  Future<bool> delete(FileAttachment fileAttachment) async {
    try {
      final List<FileAttachment> attachments = await ObjectBox()
          .box<FileAttachment>()
          .query(FileAttachment_.filePath.equals(fileAttachment.filePath))
          .build()
          .findAsync();

      final bool hasMoreTiedAttachments = attachments
          .where((fa) => fa.id != fileAttachment.id)
          .isNotEmpty;

      await ObjectBox().box<FileAttachment>().removeAsync(fileAttachment.id);

      if (!hasMoreTiedAttachments) {
        try {
          await File(fileAttachment.filePath).delete();
        } catch (e, stackTrace) {
          _log.warning(
            "Failed to delete file at ${fileAttachment.filePath}",
            e,
            stackTrace,
          );
        }
      }

      // There are other attachments using the same file, do not delete the file.
      return true;
    } catch (e, stackTrace) {
      _log.severe("Failed to delete FileAttachment", e, stackTrace);
      return false;
    }
  }
}
