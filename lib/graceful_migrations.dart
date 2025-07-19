import "dart:convert";

import "package:flow/entity/transaction.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/user_preferences.dart";
import "package:logging/logging.dart";
import "package:shared_preferences/shared_preferences.dart";

final Logger _log = Logger("GracefulMigrations");

void migrateButtonOrder() async {
  const String migrationUuid = "be216298-efca-4d93-85c2-6809ebd34dff";

  try {
    final SharedPreferencesWithCache prefs =
        await SharedPreferencesWithCache.create(
          cacheOptions: SharedPreferencesWithCacheOptions(),
        );

    final ok = prefs.getString("flow.migration.$migrationUuid");

    if (ok != null) return;

    try {
      final List<String>? oldValue = prefs.getStringList(
        "flow.transactionButtonOrder",
      );

      final List<TransactionType>? parsed = oldValue
          ?.map((value) => (jsonDecode(value) as Map)["value"])
          .map(
            (value) =>
                TransactionType.values.firstWhere((e) => e.name == value),
          )
          .toList();

      UserPreferencesService().transactionButtonOrder =
          parsed ?? TransactionType.values.toList();

      await prefs.setString("flow.migration.$migrationUuid", "ok");
    } catch (e) {
      _log.warning(
        "Failed to migrate transactions for migration $migrationUuid",
        e,
      );
    }
  } catch (e) {
    _log.warning(
      "Failed to read migration status for migration $migrationUuid",
      e,
    );
  }
}

void migratePrimaryCurrencyToDb() async {
  const String migrationUuid = "3fa20881-f866-4b11-943e-dd645bc8b3d5";

  try {
    final SharedPreferencesWithCache prefs =
        await SharedPreferencesWithCache.create(
          cacheOptions: SharedPreferencesWithCacheOptions(),
        );

    final ok = prefs.getString("flow.migration.$migrationUuid");

    if (ok != null) return;

    try {
      // ignore: deprecated_member_use_from_same_package
      final String primaryCurrency = LocalPreferences().getPrimaryCurrency();

      UserPreferencesService().primaryCurrency = primaryCurrency;

      await prefs.setString("flow.migration.$migrationUuid", "ok");
    } catch (e) {
      _log.warning(
        "Failed to migrate transactions for migration $migrationUuid",
        e,
      );
    }
  } catch (e) {
    _log.warning(
      "Failed to read migration status for migration $migrationUuid",
      e,
    );
  }
}

void migrateRemoveTitleFromUntitledTransactions() async {
  const String migrationUuid = "1504cb1e-2dff-4912-8f1a-04a83d83c32a";

  try {
    final SharedPreferencesWithCache prefs =
        await SharedPreferencesWithCache.create(
          cacheOptions: SharedPreferencesWithCacheOptions(),
        );

    final ok = prefs.getString("flow.migration.$migrationUuid");

    if (ok != null) return;

    try {
      final String exactUntitled = "transaction.fallbackTitle".tr();

      Query<Transaction> untitleds = ObjectBox()
          .box<Transaction>()
          .query(Transaction_.title.equals(exactUntitled))
          .build();

      final List<Transaction> transactions = untitleds.find();

      _log.info(
        "Migrating ${transactions.length} transactions for migration $migrationUuid",
      );

      await ObjectBox().box<Transaction>().putManyAsync(
        transactions.map((t) {
          t.title = null;
          return t;
        }).toList(),
      );

      await prefs.setString("flow.migration.$migrationUuid", "ok");
    } catch (e) {
      _log.warning(
        "Failed to migrate transactions for migration $migrationUuid",
        e,
      );
    }
  } catch (e) {
    _log.warning(
      "Failed to read migration status for migration $migrationUuid",
      e,
    );
  }
}

void migrateExtraKeyIndexing() async {
  const String migrationUuid = "80323fa8-861c-4483-86db-4b66be64a499";

  try {
    final SharedPreferencesWithCache prefs =
        await SharedPreferencesWithCache.create(
          cacheOptions: SharedPreferencesWithCacheOptions(),
        );

    final ok = prefs.getString("flow.migration.$migrationUuid");

    if (ok != null) return;

    try {
      Query<Transaction> withExtras = ObjectBox()
          .box<Transaction>()
          .query(Transaction_.extra.notNull())
          .build();

      final List<Transaction> transactions = withExtras.find();

      _log.info(
        "Migrating ${transactions.length} transactions for migration $migrationUuid",
      );

      await ObjectBox().box<Transaction>().putManyAsync(
        transactions.map((t) {
          t.extraTags = [
            ...t.extensions.data.map((ext) => ext.extensionIdentifierTag),
            ...t.extensions.data.map((ext) => ext.extensionExistenceTag),
          ];
          return t;
        }).toList(),
      );

      await prefs.setString("flow.migration.$migrationUuid", "ok");
    } catch (e) {
      _log.warning(
        "Failed to migrate transactions for migration $migrationUuid",
        e,
      );
    }
  } catch (e) {
    _log.warning(
      "Failed to read migration status for migration $migrationUuid",
      e,
    );
  }
}
