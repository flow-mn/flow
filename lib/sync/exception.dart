import 'package:flow/l10n/localized_exception.dart';
import 'package:flow/sync/sync.dart';

class ImportException extends LocalizedException implements Exception {
  final String message;

  /// Sync Model version
  final int versionCode;

  const ImportException(
    this.message, {
    this.versionCode = latestSyncModelVersion,
    super.l10nKey = "error.unknown",
    super.l10nArgs,
  });

  @override
  String toString() {
    return "[Flow Sync Import v$versionCode] $message";
  }
}
