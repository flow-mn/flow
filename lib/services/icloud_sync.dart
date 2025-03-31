import "dart:async";
import "dart:io";

import "package:flow/constants.dart";
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

  static Future<void> initialize() async {
    if (_instance != null) return;

    _instance = ICloudSyncService._internal();

    _instance!._listenToMetadataChanges();
  }

  static bool get supported => Platform.isIOS || Platform.isMacOS;

  /// Updates the cache also
  void _listenToMetadataChanges() async {
    if (!supported) return;

    late final StreamSubscription<List<ICloudFile>> subscription;

    final List<ICloudFile> files = await ICloudStorage.gather(
      containerId: containerId,
      onUpdate: (Stream<List<ICloudFile>> stream) {
        subscription = stream.listen(
          (data) => _filesCache.value = data,
          onDone: () {
            _log.info("ICloud metadata stream closed");
            subscription.cancel();
          },
          onError: (error) {
            _log.severe("ICloud metadata stream error", error);
            subscription.cancel();
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
  }

  Future<List<ICloudFile>> gather() async {
    if (!supported) return <ICloudFile>[];

    try {
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

  Future<String> upload({
    required String filePath,
    required String destinationRelativePath,
    Function(Stream<double>)? onProgress,
  }) async {
    assert(filePath.isNotEmpty);
    assert(destinationRelativePath.isNotEmpty);
    assert(!destinationRelativePath.startsWith("/"));

    if (flowDebugMode) {
      destinationRelativePath = "debug/$destinationRelativePath";
    }

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

    lastError = null;

    return completer.future;
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
}
