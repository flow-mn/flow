import 'dart:convert';
import 'dart:developer';

import 'package:csv/csv.dart';
import 'package:flow/constants.dart';
import 'package:flow/entity/account.dart';
import 'package:flow/entity/category.dart';
import 'package:flow/entity/profile.dart';
import 'package:flow/entity/transaction.dart';
import 'package:flow/l10n/named_enum.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/objectbox.g.dart';
import 'package:flow/sync/export/headers/header_v1.dart';
import 'package:flow/sync/model/model_v1.dart';
import 'package:intl/intl.dart';
import 'package:moment_dart/moment_dart.dart';

Future<String> generateBackupContentV1() async {
  const int versionCode = 1;
  log("[Flow Sync] Initiating export, version code = $versionCode");

  // TODO (sadespresso) use [Future.wait] if it's more performant

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

  final String username =
      firstProfileQuery.findFirst()?.name ?? "Default Profile";

  firstProfileQuery.close();

  final SyncModelV1 obj = SyncModelV1(
    versionCode: versionCode,
    exportDate: exportDate,
    username: username,
    appVersion: appVersion,
    transactions: transactions,
    accounts: accounts,
    categories: categories,
  );

  return jsonEncode(obj.toJson());
}

Future<String> generateCSVContentV1() async {
  final transaction = await ObjectBox().box<Transaction>().getAllAsync();

  final headers = [
    CSVHeadersV1.uuid.localizedName,
    CSVHeadersV1.title.localizedName,
    CSVHeadersV1.amount.localizedName,
    CSVHeadersV1.currency.localizedName,
    CSVHeadersV1.account.localizedName,
    CSVHeadersV1.accountUuid.localizedName,
    CSVHeadersV1.category.localizedName,
    CSVHeadersV1.categoryUuid.localizedName,
    CSVHeadersV1.subtype.localizedName,
    CSVHeadersV1.createdDate.localizedName,
    CSVHeadersV1.transactionDate.localizedName,
    CSVHeadersV1.extra.localizedName,
  ];

  final Map<String, int> numberOfDecimalsToKeep = {};

  final transformed = transaction
      .map(
        (e) => [
          e.uuid,
          e.title ?? "",
          e.amount.toStringAsFixed(
            numberOfDecimalsToKeep[e.currency] ??=
                NumberFormat.currency(name: e.currency).decimalDigits ?? 2,
          ),
          e.currency,
          e.account.target?.name,
          e.account.target?.uuid,
          e.category.target?.name,
          e.category.target?.uuid,
          e.transactionSubtype?.localizedName,
          e.createdDate.format(
            payload: "LLL",
            forceLocal: true,
          ),
          e.transactionDate.format(
            payload: "LLL",
            forceLocal: true,
          ),
          e.extra,
        ],
      )
      .toList()
    ..insert(0, headers);

  return const ListToCsvConverter().convert(transformed);
}
