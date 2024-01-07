import 'package:flow/sync/sync.dart';

class ImportException implements Exception {
  final String message;

  /// Sync Model version
  final int versionCode;

  const ImportException(
    this.message, {
    this.versionCode = latestSyncModelVersion,
  });

  @override
  String toString() {
    return "[Flow Sync Import v$versionCode] $message";
  }
}
