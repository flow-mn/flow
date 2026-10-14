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
import "package:flow/sync/import/external/ivy_wallet_csv.dart";
import "package:flow/sync/import/import_csv.dart";
import "package:flow/sync/import/import_v1.dart";
import "package:flow/sync/import/import_v2.dart";
import "package:flow/sync/model/csv/parsed_data.dart";
import "package:flow/sync/model/external/ivy/ivy_wallet_csv.dart";
import "package:flow/sync/model/model_v1.dart";
import "package:flow/sync/model/model_v2.dart";
import "package:flow/utils/utils.dart";
import "package:logging/logging.dart";
import "package:path/path.dart" as path;
import "package:path_provider/path_provider.dart";

export "package:flow/sync/import/import_v1.dart";
export "package:flow/sync/model/model_v1.dart";

final Logger _log = Logger("Import Backup");

enum ImportExternalFormat {
  ivyWallet("Ivy Wallet");

  final String name;

  const ImportExternalFormat(this.name);
}

/// We have to recover following models:
/// * Account
/// * Category
/// * Transactions
/// * Profile
///
/// We need to resolve [Transaction]s last cause it references both [Account] and
/// [Category] UUID.
Future<Importer> importBackup({
  File? backupFile,
  ImportExternalFormat? externalFormat,
}) async {
  final file = backupFile ?? await pickImportFile();

  if (file == null) {
    throw const ImportException(
      "No file was picked to proceed with the import",
      l10nKey: "error.input.noFilePicked",
    );
  }

  try {
    return await _importFile(file, externalFormat);
  } finally {
    if (backupFile == null) {
      await _discardPickedCopy(file);
    }
  }
}

/// File pickers on mobile hand over a plaintext copy in the cache directory
Future<void> _discardPickedCopy(File file) async {
  try {
    final List<String> tempRoots = [
      (await getTemporaryDirectory()).path,
      (await getApplicationCacheDirectory()).path,
    ];

    if (tempRoots.any((root) => path.isWithin(root, file.path))) {
      await file.delete();
    }
  } catch (e) {
    _log.warning("Failed to delete picked file copy", e);
  }
}

Future<Importer> _importFile(
  File file,
  ImportExternalFormat? externalFormat,
) async {
  if (externalFormat == null) {
    final String baseName = path.basename(file.path);

    if (baseName.startsWith("Ivy Wallet")) {
      externalFormat = ImportExternalFormat.ivyWallet;
    }
  }

  if (externalFormat != null) {
    return switch (externalFormat) {
      ImportExternalFormat.ivyWallet => IvyWalletCsvImporter(
        await IvyWalletCsv.fromFile(file),
      ),
    };
  }

  final String ext = path.extension(file.path).toLowerCase();

  _log.info("Importing backup from file: ${file.path}");

  try {
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
  } catch (e) {
    _log.severe("Error importing backup: $e");
    rethrow;
  } finally {
    _log.info("Import process finished");
  }
}

const int _maxUncompressedZipSize = 4 * 1024 * 1024 * 1024;

Future<Importer> _importZip({required File file}) async {
  final Uint8List bytes = await file.readAsBytes();
  final Archive zip = ZipDecoder().decodeBytes(bytes);

  late final String? jsonRelativePath;

  try {
    jsonRelativePath = zip.files
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

  // Flow never exports symlinks, and they can be chained to write outside
  // of the extraction directory
  if (zip.files.any((archiveFile) => archiveFile.isSymbolicLink)) {
    throw ImportException(
      "ZIP archive contains symbolic links",
      l10nKey: "error.input.invalidZip",
    );
  }

  final int uncompressedSize = zip.files.fold(
    0,
    (sum, archiveFile) => sum + archiveFile.size,
  );

  if (uncompressedSize > _maxUncompressedZipSize) {
    throw ImportException(
      "ZIP archive is too large when uncompressed ($uncompressedSize bytes)",
      l10nKey: "error.input.invalidZip",
    );
  }

  final Directory tempDir = await getApplicationCacheDirectory();

  final String dir = path.join(
    tempDir.path,
    "flow_unzipped_${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}",
  );

  await Directory(dir).create();

  try {
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
  } catch (e) {
    try {
      await Directory(dir).delete(recursive: true);
    } catch (_) {
      //
    }
    rethrow;
  }
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
  return ImportCSV(await CSVParsedData.fromFile(file));
}
