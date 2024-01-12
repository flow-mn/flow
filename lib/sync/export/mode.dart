enum ExportMode {
  /// Cannot be recovered from
  ///
  /// Intended for using in more complex software like Google Sheets
  csv(fileExt: "csv"),

  /// Can be fully recovered from
  ///
  /// Intended for full backups. Will be versioned, we plan to support
  /// importing older backups to newer versions.
  ///
  /// More about versioning [here]
  json(fileExt: "json");

  final String fileExt;

  const ExportMode({required this.fileExt});
}
