import "package:flutter/material.dart";

abstract class Importer<T> {
  T get data;
  ValueNotifier get progressNotifier;

  /// Before starting the import, it'll perform a safety backup, stored in
  /// `automated_backups` subfolder. If safety backups fails, will immediately
  /// halt, without making any changes to the state. You can alter this
  /// behaviour by setting [ignoreSafetyBackupFail] to true.
  ///
  /// Returns the path of the safety backup file.
  ///
  /// [ignoreSafetyBackupFail] - Forces to proceed in the import if safety
  /// backup fails
  Future<String?> execute({bool ignoreSafetyBackupFail = false});
}
