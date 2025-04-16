import "dart:async";
import "dart:io";

import "package:flow/constants.dart";
import "package:flow/objectbox.dart";
import "package:flutter/foundation.dart";
import "package:icloud_storage/icloud_storage.dart";
import "package:logging/logging.dart";
import "package:path/path.dart" as path;
import "package:path_provider/path_provider.dart";
import "package:uuid/uuid.dart";

final Logger _log = Logger("ICloudSyncService");

/// Requires [ObjectBox.appDataDirectory] to be set
class ICloudSyncService {
  static ICloudSyncService? _instance;

  static const String containerId = "iCloud.mn.flow.flow";

  bool _listeningToMetadataChanges = false;

  final ValueNotifier<List<ICloudFile>> _filesCache =
      ValueNotifier<List<ICloudFile>>([]);
  ValueListenable<List<ICloudFile>> get filesCache => _filesCache;

  factory ICloudSyncService() => _instance ??= ICloudSyncService._internal();

  dynamic lastError;

  ICloudSyncService._internal() {
    _listenToMetadataChanges();
  }

  static Future<void> initialize() async {
    if (_instance != null) return;

    _instance = ICloudSyncService._internal();
  }

  static bool get supported => Platform.isIOS || Platform.isMacOS;

  /// Updates the cache also
  void _listenToMetadataChanges() async {
    if (!supported) return;

    late final StreamSubscription<List<ICloudFile>> subscription;

    final List<ICloudFile> files = await ICloudStorage.gather(
      containerId: containerId,
      onUpdate: (Stream<List<ICloudFile>> stream) {
        _listeningToMetadataChanges = true;
        subscription = stream.listen(
          (data) => _filesCache.value = data,
          onDone: () {
            _log.info("ICloud metadata stream closed");
            subscription.cancel();
            _listeningToMetadataChanges = false;
          },
          onError: (error) {
            _log.severe("ICloud metadata stream error", error);
            subscription.cancel();
            _listeningToMetadataChanges = false;
          },
        );
      },
    ).catchError((e, stackTrace) {
      lastError = e;
      _log.warning("Error gathering iCloud files", e, stackTrace);
      return <ICloudFile>[];
    });

    _log.fine("Gathered iCloud files: ${files.length}");

    _filesCache.value = files;
    lastError = null;
    _listeningToMetadataChanges = true;
  }

  Future<List<ICloudFile>> gather() async {
    if (!supported) return <ICloudFile>[];

    try {
      if (_listeningToMetadataChanges) {
        return _filesCache.value;
      }

      final List<ICloudFile> files = await ICloudStorage.gather(
        containerId: containerId,
      );

      _filesCache.value = files;
      lastError = null;

      return files;
    } catch (e, stackTrace) {
      lastError = e;
      _log.severe("Failed to gather iCloud files", e, stackTrace);
      return <ICloudFile>[];
    }
  }

  Future<void> delete(ICloudFile file) async {
    return await ICloudStorage.delete(
      containerId: containerId,
      relativePath: file.relativePath,
    );
  }

  Future<File> download({
    required ICloudFile file,
    Function(Stream<double>)? onProgress,
  }) async {
    final Completer<File> completer = Completer<File>();
    late final StreamSubscription<double> subscription;

    final String destinationFilePath = path.join(
      ObjectBox.appDataDirectory,
      "iCloud",
      file.relativePath,
    );

    void finish([bool success = true]) {
      subscription.cancel();

      if (success) {
        completer.complete(File(destinationFilePath));
      } else {
        completer.completeError(
          Exception("Failed to download file: $destinationFilePath"),
        );
      }
    }

    await ICloudStorage.download(
      containerId: containerId,
      relativePath: file.relativePath,
      destinationFilePath: destinationFilePath,
      onProgress: (Stream<double> progress) {
        onProgress?.call(progress);
        subscription = progress.listen(
          (double progress) {
            if (progress >= 1.0) {
              finish();
            }
          },
          onError: (_) => finish(false),
          onDone: () => finish(),
          cancelOnError: true,
        );
      },
    );

    return completer.future;
  }

  /// Uploads a file to iCloud
  ///
  /// Uses [uploadTemporary] to upload the file, and then moves it to the final location.
  Future<String> upload({
    required String filePath,
    required String destinationRelativePath,
    Function(Stream<double>)? onProgress,
    DateTime? modifiedDate,
  }) async {
    final String tempLocation = await uploadTemporary(
      filePath: filePath,
      destinationRelativePath: destinationRelativePath,
      onProgress: onProgress,
      modifiedDate: modifiedDate,
    );

    await move(from: tempLocation, to: destinationRelativePath);

    return destinationRelativePath;
  }

  Future<String> move({required String from, required String to}) async {
    assert(from.isNotEmpty);
    assert(to.isNotEmpty);
    assert(!from.startsWith("/"));
    assert(!to.startsWith("/"));
    assert(from != to);

    if (flowDebugMode) {
      to = "debug/$to";
    }

    try {
      _log.info("Attempting to move $from to $to");

      await ICloudStorage.move(
        containerId: containerId,
        fromRelativePath: from,
        toRelativePath: to,
      );

      _log.info("Successfully moved $from to $to");

      lastError = null;

      return to;
    } catch (e, stackTrace) {
      _log.severe("Failed to move $from to $to", e, stackTrace);
      rethrow;
    }
  }

  Future<void> debugPurge() async {
    final List<ICloudFile> files = await gather();
    final List<ICloudFile> debugFiles =
        files.where((file) => file.relativePath.startsWith("debug/")).toList();

    _log.info("Deleting ${debugFiles.length} debug files");
    for (ICloudFile file in debugFiles) {
      await delete(file);
    }
    _log.info("Debug files deleted successfully.");
  }

  /// It does:
  /// * Copy file into a temporary location
  /// * Set the temp file's last modified and last accessed date to now
  /// * Upload the file to iCloud with the `.tmp` suffix
  /// * Delete the temporary file
  /// * Return the final relative path (still with ".tmp" suffix)
  ///
  /// You should move the file to the final location after uploading to avoid
  /// potential corruption.
  Future<String> uploadTemporary({
    required String filePath,
    required String destinationRelativePath,
    Function(Stream<double>)? onProgress,
    DateTime? modifiedDate,
  }) async {
    assert(filePath.isNotEmpty);
    assert(destinationRelativePath.isNotEmpty);
    assert(!destinationRelativePath.startsWith("/"));

    final Directory tempDir = await getTemporaryDirectory();
    final String tempFilePath = path.join(tempDir.path, Uuid().v4());

    modifiedDate ??= DateTime.now();

    final File tempFile = await File(filePath).copy(tempFilePath);
    await tempFile.setLastModified(modifiedDate);
    await tempFile.setLastAccessed(modifiedDate);

    if (flowDebugMode) {
      destinationRelativePath = "debug/$destinationRelativePath";
    }

    destinationRelativePath += ".tmp";

    final Completer<String> completer = Completer<String>();
    late final StreamSubscription<double> subscription;

    void finish([bool success = true]) {
      subscription.cancel();

      if (success) {
        completer.complete(destinationRelativePath);
        _log.info("Upload has been completed: $destinationRelativePath");
      } else {
        completer.completeError(Exception("Failed to upload file: $filePath"));
        _log.severe("Failed to upload file: $filePath");
      }
    }

    try {
      await ICloudStorage.upload(
        containerId: containerId,
        filePath: tempFile.path,
        destinationRelativePath: destinationRelativePath,
        onProgress: (Stream<double> progress) {
          onProgress?.call(progress);
          subscription = progress.listen(
            (double progress) {
              _log.finer("Upload progress for ($progress): $progress");

              if (progress >= 1.0) {
                finish();
              }
            },
            onError: (_) => finish(false),
            onDone: () => finish(),
            cancelOnError: true,
          );
        },
      );

      lastError = null;

      return completer.future;
    } catch (e) {
      lastError = e;
      _log.severe("Failed to upload file: $filePath", e);
      try {
        completer.completeError(e);
      } catch (e) {
        // Silent fail
      }
      return completer.future;
    } finally {
      try {
        await tempFile.delete();
      } catch (e) {
        _log.warning("Failed to delete temporary file: $tempFile", e);
      }
    }
  }
}
