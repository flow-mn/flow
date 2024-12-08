import "dart:convert";
import "dart:developer";
import "dart:io";
import "dart:typed_data";

import "package:flow/constants.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/profile.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs.dart";
import "package:flow/sync/export/export_v1.dart";
import "package:flow/sync/model/model_v2.dart";

Future<String> generateBackupJSONContentV2() async {
  const int versionCode = 2;
  log("[Flow Sync] Initiating export, version code = $versionCode");

  final List<Transaction> transactions =
      await ObjectBox().box<Transaction>().getAllAsync();
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

  final SyncModelV2 obj = SyncModelV2(
    versionCode: versionCode,
    exportDate: exportDate,
    username: username,
    appVersion: appVersion,
    transactions: transactions,
    accounts: accounts,
    categories: categories,
    profile: profile,
    primaryCurrency: LocalPreferences().getPrimaryCurrency(),
  );

  return jsonEncode(obj.toJson());
}

Future<File> generateBackupZipV2() async {
  final String jsonContent = await generateBackupJSONContentV2();

  final Directory tempDir = await Directory.systemTemp.createTemp("flow");
}

/// I mean what there is to say, it's the same thing.
Future<String> generateCSVContentV2() async => await generateCSVContentV1();
