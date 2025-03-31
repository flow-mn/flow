import "dart:async";
import "dart:io";

import "package:flow/objectbox.dart";
import "package:flow/utils/extensions/iterables.dart";
import "package:flutter/foundation.dart";
import "package:icloud_storage/icloud_storage.dart";
import "package:logging/logging.dart";
import "package:path/path.dart" as path;

final Logger _log = Logger("ICloudSyncService");

/// Requires [ObjectBox.appDataDirectory] to be set
class ICloudSyncService {
  static ICloudSyncService? _instance;

  static const String containerId = "iCloud.mn.flow.flow";

  final ValueNotifier<List<ICloudFile>> _filesCache =
      ValueNotifier<List<ICloudFile>>([]);
  ValueListenable<List<ICloudFile>> get filesCache => _filesCache;

  factory ICloudSyncService() => _instance ??= ICloudSyncService._internal();

  dynamic lastError;

  ICloudSyncService._internal();

  /// Updates the cache also
  Future<List<ICloudFile>> gather() async {
    final List<ICloudFile> files = await ICloudStorage.gather(
      containerId: containerId,
    ).catchError((e, stackTrace) {
      lastError = e;
      _log.warning("Error gathering iCloud files", e, stackTrace);
      return <ICloudFile>[];
    });

    _log.fine("Gathered iCloud files: ${files.length}");

    _filesCache.value = files;

    return files;
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

  Future<String> upload({
    required String filePath,
    required String destinationRelativePath,
    Function(Stream<double>)? onProgress,
  }) async {
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

    await ICloudStorage.upload(
      containerId: containerId,
      filePath: filePath,
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

    return completer.future;
  }

  Future<String> move({required String from, required String to}) async {
    try {
      await gather();

      ICloudFile? file = _filesCache.value.firstWhereOrNull(
        (file) => file.relativePath == from,
      );

      if (file == null) {
        _log.severe("Cannot move $from to $to; file not found");
        throw Exception("Cannot move $from to $to; file not found");
      }

      await ICloudStorage.move(
        containerId: containerId,
        fromRelativePath: from,
        toRelativePath: to,
      );

      _log.info("Moved $from to $to");

      return to;
    } catch (e, stackTrace) {
      _log.severe("Failed to move $from to $to", e, stackTrace);
      rethrow;
    }
  }
}
