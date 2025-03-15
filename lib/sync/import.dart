import "dart:convert";
import "dart:core";
import "dart:io";
import "dart:typed_data";

import "package:archive/archive_io.dart";
import "package:csv/csv.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/sync/exception.dart";
import "package:flow/sync/import/base.dart";
import "package:flow/sync/import/import_csv.dart";
import "package:flow/sync/import/import_v1.dart";
import "package:flow/sync/import/import_v2.dart";
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
Future<Importer> importBackup({File? backupFile}) async {
  final file = backupFile ?? await pickJsonOrZipFile();

  if (file == null) {
    throw const ImportException(
      "No file was picked to proceed with the import",
      l10nKey: "error.input.noFilePicked",
    );
  }

  final String ext = path.extension(file.path).toLowerCase();

  switch (ext.toLowerCase()) {
    case ".csv":
      return await _importCsv(file: file);
    case ".json":
      return await _importJson(file: file);
    case ".zip":
      return await _importZip(file: file);
    default:
      throw ImportException(
        "No file was picked to proceed with the import",
        l10nKey: "error.input.wrongFileType",
        l10nArgs: "JSON, ZIP, CSV",
      );
  }
}

Future<Importer> _importZip({required File file}) async {
  final Uint8List bytes = await file.readAsBytes();
  final Archive zip = ZipDecoder().decodeBytes(bytes);

  late final String? jsonRelativePath;

  try {
    jsonRelativePath =
        zip.files
            .singleWhere(
              (archiveFile) =>
                  archiveFile.isFile &&
                  !archiveFile.isSymbolicLink &&
                  path.extension(archiveFile.name).toLowerCase() == ".json",
            )
            .name;
  } catch (e) {
    jsonRelativePath = null;
    throw ImportException(
      "No JSON file was found in the ZIP archive",
      l10nKey: "error.input.invalidZip",
    );
  }

  final Directory tempDir = await getApplicationCacheDirectory();

  final String dir = path.join(
    tempDir.path,
    "flow_unzipped_${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}",
  );

  await Directory(dir).create();

  await extractArchiveToDisk(zip, dir);

  final File jsonFile = File(path.join(dir, jsonRelativePath));

  final String assetsRoot = path.join(dir, "assets");
  final String cleanupPath = dir;

  final parsed = await jsonFile.readAsString().then((raw) => jsonDecode(raw));

  return switch (parsed["versionCode"]) {
    1 => ImportV1(SyncModelV1.fromJson(parsed)),
    2 => ImportV2(
      SyncModelV2.fromJson(parsed),
      cleanupFolder: cleanupPath,
      assetsRoot: assetsRoot,
    ),
    _ => throw UnimplementedError(),
  };
}

Future<Importer> _importJson({required File file}) async {
  final parsed = await file.readAsString().then((raw) => jsonDecode(raw));

  return switch (parsed["versionCode"]) {
    1 => ImportV1(SyncModelV1.fromJson(parsed)),
    2 => ImportV2(SyncModelV2.fromJson(parsed)),
    _ => throw UnimplementedError(),
  };
}

Future<Importer> _importCsv({required File file}) async {
  final Stream<List<int>> readStream = file.openRead();
  final List<List<dynamic>> rows =
      await readStream
          .transform(utf8.decoder)
          .transform(CsvToListConverter())
          .toList();

  return ImportCSV(rows);
}
