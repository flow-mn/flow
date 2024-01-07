import 'dart:convert';

import 'package:flow/entity/account.dart';
import 'package:flow/entity/category.dart';
import 'package:flow/entity/transaction.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/sync/exception.dart';

import 'package:flow/sync/import/import_v1.dart';
import 'package:flow/sync/model/model_v1.dart';
import 'package:flow/utils.dart';

enum ImportMode {
  /// Erases current data, then writes the imported data
  eraseAndWrite,

  /// Merges items with matching `uuid` or `name`, adds everything else
  ///
  /// If `uuid` matches, it uses `name` from the newest object (`createDate`)
  merge,
}

/// We have to recover following models:
/// * Account
/// * Category
/// * Transactions
///
/// Because we need to resolve dependencies thru `UUID`s, we'll populate
/// [ObjectBox] in following order:
/// 1. [Category] (no dependency)
/// 2. [Account] (no dependency)
/// 3. [Transaction] (Account, Category)
Future<ImportV1> importBackupV1(
    [ImportMode mode = ImportMode.eraseAndWrite]) async {
  final file = await pickFile();

  if (file == null) {
    throw const ImportException(
      "No file was picked to proceed with the import",
    );
  }

  final Map<String, dynamic> parsed = await file.readAsString().then(
        (raw) => jsonDecode(raw),
      );

  return switch (parsed["versionCode"]) {
    1 => ImportV1(SyncModelV1.fromJson(parsed), mode: mode)..execute(),
    _ => throw UnimplementedError()
  };
}
