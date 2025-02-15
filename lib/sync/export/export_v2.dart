import "dart:convert";
import "dart:developer";
import "dart:io";

import "package:archive/archive_io.dart";
import "package:flow/constants.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/profile.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction_filter_preset.dart";
import "package:flow/entity/user_preferences.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/transactions.dart";
import "package:flow/sync/export.dart";
import "package:flow/sync/export/export_v1.dart";
import "package:flow/sync/model/model_v2.dart";
import "package:path/path.dart" as path;

Future<String> generateBackupJSONContentV2() async {
  const int versionCode = 2;
  log("[Flow Sync] Initiating export, version code = $versionCode");

  final List<Transaction> transactions = await TransactionsService().findMany(
    TransactionFilter.all,
  );
  log("[Flow Sync] Finished fetching transactions");

  final List<Account> accounts = await ObjectBox().box<Account>().getAllAsync();
  log("[Flow Sync] Finished fetching accounts");

  final List<Category> categories =
      await ObjectBox().box<Category>().getAllAsync();
  log("[Flow Sync] Finished fetching categories");

  final DateTime exportDate = DateTime.now().toUtc();

  final Query<Profile> firstProfileQuery =
      ObjectBox().box<Profile>().query().build();

  final Profile? profile = firstProfileQuery.findFirst();

  final String username = profile?.name ?? "Default Profile";

  firstProfileQuery.close();

  final Query<UserPreferences> firstUserPreferencesQuery =
      ObjectBox().box<UserPreferences>().query().build();

  final UserPreferences? userPreferences =
      firstUserPreferencesQuery.findFirst();

  firstUserPreferencesQuery.close();

  final Query<TransactionFilterPreset> firstTransactionFilterPresetQuery =
      ObjectBox().box<TransactionFilterPreset>().query().build();

  final List<TransactionFilterPreset> transactionFilterPresets =
      firstTransactionFilterPresetQuery.find();

  firstTransactionFilterPresetQuery.close();

  final SyncModelV2 obj = SyncModelV2(
    versionCode: versionCode,
    exportDate: exportDate,
    username: username,
    appVersion: appVersion,
    transactions: transactions,
    accounts: accounts,
    categories: categories,
    transactionFilterPresets: transactionFilterPresets,
    profile: profile,
    userPreferences: userPreferences,
    primaryCurrency: LocalPreferences().getPrimaryCurrency(),
  );

  return jsonEncode(obj.toJson());
}

Future<File> generateBackupZipV2({Function(double)? onProgress}) async {
  final String jsonFileName = generateBackupFileName("json");
  final String zipFileName = generateBackupFileName("zip");

  final String jsonContent = await generateBackupJSONContentV2();

  final Directory tempDir =
      await Directory.systemTemp.createTemp("flow_export_v2");

  await File(path.join(tempDir.path, jsonFileName)).writeAsString(jsonContent);

  final Directory imagesDir =
      Directory(path.join(tempDir.path, "assets", "images"));

  try {
    await imagesDir.create(recursive: true);

    final List<FileSystemEntity> filesList =
        Directory(ObjectBox.imagesDirectory)
            .listSync(followLinks: false, recursive: false);
    final List<File> pngsList = filesList
        .where((file) => path.extension(file.path).toLowerCase() == ".png")
        .map((file) => File(file.path))
        .toList();

    await Future.wait(pngsList.map((png) =>
            png.copy(path.join(imagesDir.path, path.basename(png.path)))))
        .catchError((error) {
      log("[Flow Sync] Failed to copy some or all of the images to temp directory",
          error: error);
      return <File>[];
    });
  } catch (e) {
    log("[Flow Sync] Failed to copy some or all of the images to temp directory",
        error: e);
  }

  final File result = File(path.join(Directory.systemTemp.path, zipFileName));

  final ZipFileEncoder encoder = ZipFileEncoder();
  await encoder.zipDirectory(tempDir,
      filename: result.path, onProgress: onProgress);

  return result;
}

/// I mean what there is to say, it's the same thing.
Future<String> generateCSVContentV2() async => await generateCSVContentV1();
