import "dart:async";
import "dart:io";

import "package:flow/constants.dart";
import "package:flow/entity/backup_entry.dart";
import "package:flow/prefs/transitive.dart";
import "package:flow/services/sync/syncer.dart";
import "package:flow/utils/utils.dart";
import "package:flutter/foundation.dart";
import "package:icloud_storage/icloud_storage.dart";
import "package:logging/logging.dart";
import "package:moment_dart/moment_dart.dart";
import "package:path/path.dart" as path;
import "package:path_provider/path_provider.dart";
import "package:uuid/uuid.dart";

final Logger _log = Logger("ICloudSyncer");

class ICloudSyncer implements Syncer {
  static ICloudSyncer? _instance;

  static const String containerId = "iCloud.mn.flow.flow";

  static bool get supported => Platform.isIOS || Platform.isMacOS;

  bool _listeningToMetadataChanges = false;

  dynamic lastError;

  final ValueNotifier<List<ICloudFile>> _filesCache =
      ValueNotifier<List<ICloudFile>>([]);
  ValueListenable<List<ICloudFile>> get filesCache => _filesCache;

  final ValueNotifier<bool> _initialUpdateReceived = ValueNotifier<bool>(false);
  ValueListenable<bool> get initialUpdateReceived => _initialUpdateReceived;

  ICloudSyncer._internal() {
    _listenToMetadataChanges();
  }

  factory ICloudSyncer() => _instance ??= ICloudSyncer._internal();

  /// Updates the cache also
  void _listenToMetadataChanges() async {
    if (!supported) return;

    late final StreamSubscription<List<ICloudFile>> subscription;

    final List<ICloudFile> files =
        await ICloudStorage.gather(
          containerId: containerId,
          onUpdate: (Stream<List<ICloudFile>> stream) {
            _listeningToMetadataChanges = true;
            subscription = stream.listen(
              (data) {
                _initialUpdateReceived.value = true;
                _filesCache.value = data;
              },
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

  String resolvePath(String lePath) {
    final String file = path.basename(lePath);

    return ["backups", if (flowDebugMode) "debug", file].join("/");
  }

  @override
  bool get syncing => true;

  @override
  Future<bool> delete(String path) async {
    try {
      await ICloudStorage.delete(
        containerId: containerId,
        relativePath: resolvePath(path),
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<File?> download(
    SyncerItem item, {
    Function(double)? onProgress,
  }) async {
    if (!supported) throw UnimplementedError();

    StreamSubscription<double>? subscription;

    final Completer<File?> completer = Completer<File?>();

    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String tempFile = path.join(
        tempDir.path,
        path.basename("${Uuid().v4()}.tmp${path.extension(item.path)}"),
      );

      _log.fine(
        "Downloading iCloud file: ${resolvePath(item.path)} to $tempFile",
      );

      await ICloudStorage.download(
        containerId: containerId,
        relativePath: resolvePath(item.path),
        destinationFilePath: tempFile,
        onProgress: (progressStream) => {
          subscription = progressStream.listen(
            (value) {
              if (onProgress != null) {
                onProgress(value);
              }
              _log.fine("ICloud download progress: $value");
            },
            onDone: () {
              completer.complete(File(tempFile));
            },
            cancelOnError: true,
            onError: (error) {
              completer.completeError("Failed to download iCloud file: $error");
            },
          ),
        },
      );

      unawaited(
        completer.future
            .then((_) {
              if (onProgress != null) {
                onProgress(1.0);
              }
            })
            .catchError((error) {
              // silent fail
            }),
      );

      return await completer.future;
    } catch (e) {
      _log.severe("Failed to download iCloud file", e);
      rethrow;
    } finally {
      unawaited(
        subscription?.cancel().catchError((error) {
          _log.warning(
            "Failed to cancel iCloud download progress subscription",
            error,
          );
        }),
      );
    }
  }

  @override
  Future<SyncerItem?> get(String name) async {
    if (!supported) return null;

    if (_listeningToMetadataChanges) {
      try {
        final ICloudFile? file = _filesCache.value.firstWhereOrNull(
          (file) => file.relativePath == resolvePath(name),
        );

        if (file == null) {
          throw StateError("File not found");
        }

        return SyncerItem(
          path: file.relativePath,
          updatedAt: file.contentChangeDate,
        );
      } catch (e) {
        _log.warning("Unable to find the file from the cache", e);
      }
    }
    return null;
  }

  @override
  Future<List<SyncerItem>> list() async {
    if (!supported) return <SyncerItem>[];

    if (_listeningToMetadataChanges) {
      try {
        return _filesCache.value
            .map(
              (file) => SyncerItem(
                path: file.relativePath,
                updatedAt: file.contentChangeDate,
              ),
            )
            .toList();
      } catch (e) {
        _log.warning("Error putting iCloud files into cache", e);
      }
    }

    try {
      final List<ICloudFile> files = await ICloudStorage.gather(
        containerId: containerId,
      );

      try {
        _filesCache.value = files;
      } catch (e) {
        _log.warning("Error putting iCloud files into cache", e);
      }

      return files
          .map(
            (file) => SyncerItem(
              path: file.relativePath,
              updatedAt: file.contentChangeDate,
            ),
          )
          .toList();
    } catch (e) {
      _log.warning("Error gathering iCloud files", e);

      return <SyncerItem>[];
    }
  }

  @override
  Future<int> purge({Duration? maxAge, int? keepCount}) async {
    _log.fine("Purging iCloud files, maxAge: $maxAge, keepCount: $keepCount");

    final List<SyncerItem> items = await list();

    int success = 0;

    await Future.wait(
      items
          .where((item) => item.inferredBackupDate == null)
          .map((item) => delete(item.path).then((_) => success++)),
    );

    final List<SyncerItem> remaining =
        items.where((item) => item.inferredBackupDate != null).toList()..sort(
          (a, b) => a.inferredBackupDate!.compareTo(b.inferredBackupDate!),
        );

    if (keepCount != null) {
      if (keepCount <= 0) {
        _log.info("keepCount is 0 or negative, skipping purge");
        return 0;
      }

      final int deleteCount = remaining.length - keepCount;

      if (deleteCount > 0) {
        await Future.wait(
          remaining
              .take(deleteCount)
              .map((item) => delete(item.path).then((_) => success++)),
        );
      }

      _log.info(
        "Deleted $success out of $deleteCount stale iCloud files (keepCount $keepCount)",
      );

      return success;
    } else if (maxAge != null) {
      try {
        final List<SyncerItem> items = await list();

        await Future.wait(
          items
              .where(
                (item) =>
                    item.inferredBackupDate == null ||
                    DateTime.now().difference(item.inferredBackupDate!) >
                        maxAge,
              )
              .map((item) => delete(item.path).then((_) => success++)),
        );

        _log.info(
          "Deleted $success stale iCloud files (max age: ${maxAge.toDurationString(dropPrefixOrSuffix: true)})",
        );

        return success;
      } catch (e) {
        _log.warning("Error listing iCloud files", e);
      }
    }

    return success;
  }

  Future<int> debugPurge() async {
    final List<SyncerItem> items = await list();

    int success = 0;

    await Future.wait(
      items
          .where((item) => item.path.contains("/debug/"))
          .map((item) => delete(item.path).then((_) => success++)),
    );

    return success;
  }

  Future<bool> debugDelete(String path) async {
    try {
      await ICloudStorage.delete(containerId: containerId, relativePath: path);

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> put(BackupEntry entry, {Function(double p1)? onProgress}) async {
    final Completer<bool> completer = Completer<bool>();

    StreamSubscription<double>? subscription;

    final String destinationRelativePath = resolvePath(entry.filePath);

    final bool fileCurrentlyExists = _filesCache.value.any(
      (file) => file.relativePath == destinationRelativePath,
    );

    final Timer timeoutTimer = Timer(const Duration(seconds: 300), () {
      if (!completer.isCompleted) {
        completer.completeError("ICloud upload timed out after 5 minutes");
      }
    });

    void listener() {
      if (_filesCache.value.any(
        (file) => file.relativePath == destinationRelativePath,
      )) {
        _filesCache.removeListener(listener);
        _log.fine(
          "File $destinationRelativePath already exists, skipping upload",
        );
        completer.complete(true);
      }
    }

    if (!fileCurrentlyExists) {
      _filesCache.addListener(listener);
    }

    try {
      await ICloudStorage.upload(
        containerId: containerId,
        filePath: entry.filePath,
        destinationRelativePath: destinationRelativePath,
        onProgress: (progressStream) => {
          subscription = progressStream.listen(
            (value) {
              if (onProgress != null) {
                onProgress(value);
              }
              _log.fine("ICloud upload progress: $value");
              if (value >= 100.0) {
                completer.complete(true);
              }
            },
            onDone: () {
              _log.fine("ICloud upload completed");
              completer.complete(true);
            },
            onError: (error) => completer.completeError(error),
            cancelOnError: true,
          ),
        },
      );

      unawaited(
        completer.future.then((_) {
          if (timeoutTimer.isActive) {
            timeoutTimer.cancel();
          }

          TransitiveLocalPreferences().lastSuccessfulICloudSyncAt
              .set(entry.createdDate)
              .then((_) {})
              .catchError((e) {
                _log.finest(
                  "Failed to set last successful iCloud sync time",
                  e,
                );
              });
        }),
      );

      return await completer.future;
    } catch (e) {
      _log.severe("Failed to upload iCloud file", e);

      return false;
    } finally {
      unawaited(
        subscription?.cancel().catchError(
          (error) => _log.warning(
            "Failed to cancel iCloud upload progress subscription",
            error,
          ),
        ),
      );

      if (fileCurrentlyExists) {
        try {
          _filesCache.removeListener(listener);
        } catch (e) {
          _log.fine("Failed to remove listener", e);
        }
      }
    }
  }
}
