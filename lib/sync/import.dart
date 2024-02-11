import 'dart:convert';
import 'dart:io';

import 'package:flow/entity/account.dart';
import 'package:flow/entity/category.dart';
import 'package:flow/entity/transaction.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/sync/exception.dart';

import 'package:flow/sync/import/import_v1.dart';
import 'package:flow/sync/import/mode.dart';
export 'package:flow/sync/import/import_v1.dart';

import 'package:flow/sync/model/model_v1.dart';
export 'package:flow/sync/model/model_v1.dart';

import 'package:flow/utils/utils.dart';

import 'package:path/path.dart' as path;

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
Future<ImportV1> importBackupV1({
  ImportMode mode = ImportMode.eraseAndWrite,
  File? backupFile,
}) async {
  final file = backupFile ?? await pickJsonFile();

  if (file == null) {
    throw const ImportException(
      "No file was picked to proceed with the import",
      l10nKey: "error.input.noFilePicked",
    );
  } else if (path.extension(file.path).toLowerCase() != ".json") {
    // We also might want to recover data from ObjectBox file, but not sure
    // how user friendly it'd be... Something to consider in the future.

    throw const ImportException(
      "No file was picked to proceed with the import",
      l10nKey: "error.input.wrongFileType",
      l10nArgs: "JSON",
    );
  }

  final Map<String, dynamic> parsed = await file.readAsString().then(
        (raw) => jsonDecode(raw),
      );

  return switch (parsed["versionCode"]) {
    1 => ImportV1(SyncModelV1.fromJson(parsed), mode: mode),
    _ => throw UnimplementedError()
  };
}
