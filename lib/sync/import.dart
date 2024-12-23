import "dart:convert";
import "dart:core";
import "dart:io";
import "dart:typed_data";

import "package:archive/archive_io.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/sync/exception.dart";
import "package:flow/sync/import/base.dart";
import "package:flow/sync/import/import_v1.dart";
import "package:flow/sync/import/import_v2.dart";
import "package:flow/sync/import/mode.dart";
import "package:flow/sync/model/model_v1.dart";
import "package:flow/sync/model/model_v2.dart";
import "package:flow/utils/utils.dart";
import "package:path/path.dart" as path;
import "package:path_provider/path_provider.dart";

export "package:flow/sync/import/import_v1.dart";
export "package:flow/sync/model/model_v1.dart";

/// We have to recover following models:
/// * Account
/// * Category
/// * Transactions
/// * Profile
///
/// We need to resolve [Transaction]s last cause it references both [Account] and
/// [Category] UUID.
Future<Importer> importBackup({
  ImportMode mode = ImportMode.eraseAndWrite,
  File? backupFile,
}) async {
  final file = backupFile ?? await pickJsonFile();

  if (file == null) {
    throw const ImportException(
      "No file was picked to proceed with the import",
      l10nKey: "error.input.noFilePicked",
    );
  }

  final String ext = path.extension(file.path).toLowerCase();
  final bool isSupportedExtension = [".json", ".zip"].contains(ext);

  if (!isSupportedExtension) {
    throw const ImportException(
      "No file was picked to proceed with the import",
      l10nKey: "error.input.wrongFileType",
      l10nArgs: "JSON, ZIP",
    );
  }

  late final Map<String, dynamic> parsed;
  String? assetsRoot;
  String? cleanupPath;

  if (ext == ".zip") {
    final Uint8List bytes = await file.readAsBytes();
    final Archive zip = ZipDecoder().decodeBytes(bytes);

    late final String? jsonRelativePath;

    try {
      jsonRelativePath = zip.files
          .singleWhere((archiveFile) =>
              archiveFile.isFile &&
              !archiveFile.isSymbolicLink &&
              path.extension(archiveFile.name).toLowerCase() == ".json")
          .name;
    } catch (e) {
      jsonRelativePath = null;
      throw ImportException(
        "No JSON file was found in the ZIP archive",
        l10nKey: "error.input.invalidZip",
      );
    }

    final Directory tempDir = await getTemporaryDirectory();

    final String dir = path.join(tempDir.path,
        "flow_unzipped_${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}");

    await Directory(dir).create();

    await extractArchiveToDisk(zip, dir);

    final File jsonFile = File(path.join(dir, jsonRelativePath));

    assetsRoot = path.join(dir, "assets");
    cleanupPath = dir;

    parsed = await jsonFile.readAsString().then(
          (raw) => jsonDecode(raw),
        );
  } else if (ext == ".json") {
    parsed = await file.readAsString().then(
          (raw) => jsonDecode(raw),
        );
  }

  return switch (parsed["versionCode"]) {
    1 => ImportV1(SyncModelV1.fromJson(parsed), mode: mode),
    2 => ImportV2(
        SyncModelV2.fromJson(parsed),
        mode: mode,
        cleanupFolder: cleanupPath,
        assetsRoot: assetsRoot,
      ),
    _ => throw UnimplementedError()
  };
}
