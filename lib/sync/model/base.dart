abstract class SyncModelBase {
  /// Version code for backup package. Useful for backwards-compatibility.
  /// We will increment this every time we make major changes to the structure.
  ///
  /// For example, let's say we changed the field name of two properties on
  /// [Transaction] entity. Now suddenly all the backups we made before this
  /// change couldn't be imported.
  ///
  /// We will ensure old data will be imported without any hassle.
  final int versionCode;

  /// Date and time of the export
  final DateTime exportDate;

  /// Current user's name
  final String username;

  /// Version of the app performed this backup
  final String appVersion;

  const SyncModelBase({
    required this.versionCode,
    required this.exportDate,
    required this.username,
    required this.appVersion,
  });
}
