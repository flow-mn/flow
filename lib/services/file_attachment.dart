import "dart:io";

import "package:cross_file/cross_file.dart";
import "package:flow/entity/file_attachment.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:logging/logging.dart";
import "package:path/path.dart" as path;
import "package:uuid/uuid.dart";

final Logger _log = Logger("FileAttachmentService");

class FileAttachmentService {
  static FileAttachmentService? _instance;

  final List<FileAttachment> _markedForCleanupCheck = [];

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

  void markForCleanupCheck(FileAttachment fileAttachment) {
    _markedForCleanupCheck.add(fileAttachment);
  }

  void performCleanupCheck() {
    for (final fileAttachment in _markedForCleanupCheck) {
      try {
        deleteIfOrphan(fileAttachment);
      } catch (e) {
        _log.warning(
          "Failed to perform cleanup check for FileAttachment ${fileAttachment.id}",
          e,
        );
      }
    }
    _markedForCleanupCheck.clear();
  }

  Future<int> deleteAllOrphans() async {
    int totalDeleted = 0;

    final Set<String> registeredFilePaths = {};

    try {
      final box = ObjectBox().box<FileAttachment>();
      final allAttachments = box.getAll();

      registeredFilePaths.addAll(allAttachments.map((x) => x.filePath));

      final List<bool> results = await Future.wait(
        allAttachments.map(
          (attachment) => deleteIfOrphan(attachment).catchError((_) => false),
        ),
      );

      totalDeleted = results.where((result) => result).length;
    } catch (e, stackTrace) {
      _log.severe(
        "Failed to delete all orphaned FileAttachments",
        e,
        stackTrace,
      );
    }

    try {
      final Directory parent = Directory(ObjectBox.filesDirectory);
      final List<File> fileEntries = parent
          .listSync(recursive: true)
          .whereType<File>()
          .toList();

      for (final File file in fileEntries) {
        if (!file.path.startsWith(ObjectBox.filesDirectory)) {
          // TODO @sadespresso check if this check is valid for every os
          continue;
        }

        final String relativePath = path.relative(
          file.path,
          from: ObjectBox.appDataDirectory,
        );

        if (!registeredFilePaths.contains(relativePath)) {
          try {
            await file.delete();
            totalDeleted += 1;
          } catch (e, stackTrace) {
            _log.warning(
              "Failed to delete unregistered file at ${file.path}",
              e,
              stackTrace,
            );
          }
        }
      }
    } catch (e, stackTrace) {
      _log.severe("Failed to cleanup unregistered files", e, stackTrace);
    }

    return totalDeleted;
  }

  Future<bool> delete(FileAttachment fileAttachment) async {
    try {
      await ObjectBox().box<FileAttachment>().removeAsync(fileAttachment.id);

      try {
        await File(fileAttachment.filePath).delete();
      } catch (e, stackTrace) {
        _log.warning(
          "Failed to delete file at ${fileAttachment.filePath}",
          e,
          stackTrace,
        );
      }

      return true;
    } catch (e, stackTrace) {
      _log.severe("Failed to delete FileAttachment", e, stackTrace);
      return false;
    }
  }

  Future<bool> deleteIfOrphan(FileAttachment fileAttachment) async {
    try {
      final qb = ObjectBox().box<Transaction>().query();
      qb.linkMany(
        Transaction_.attachments,
        FileAttachment_.uuid.equals(fileAttachment.uuid),
      );
      final query = qb.build();

      final int count = query.count();
      query.close();

      if (count > 0) {
        return false;
      }

      return await delete(fileAttachment);
    } catch (e, stackTrace) {
      _log.severe("Failed to delete FileAttachment", e, stackTrace);
      return false;
    }
  }

  /// Returns the path for [ImageFlowIcon]
  Future<FileAttachment?> createFromXFile(XFile xFile) async {
    try {
      final String fileName = "${const Uuid().v4()}/${xFile.name}";
      final File file = File(path.join(ObjectBox.filesDirectory, fileName));
      await file.create(recursive: true);
      await File(xFile.path).copy(file.path);

      final fileAttachment = FileAttachment(
        filePath: "${ObjectBox.filesDirectoryName}/$fileName",
      );
      markForCleanupCheck(fileAttachment);
      return fileAttachment;
    } catch (e, stackTrace) {
      _log.warning(
        "Couldn't create file attachment from $xFile",
        e,
        stackTrace,
      );
      return null;
    }
  }
}
