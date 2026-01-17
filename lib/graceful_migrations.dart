import "dart:convert";

import "package:flow/data/flow_button_type.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction/extensions/default/geo.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/transactions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/utils/utils.dart";
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

      final List<FlowButtonType>? parsed = oldValue
          ?.map((value) => (jsonDecode(value) as Map)["value"])
          .map(
            (value) => FlowButtonType.values.firstWhere((e) => e.name == value),
          )
          .toList();

      UserPreferencesService().transactionButtonOrder =
          parsed ?? FlowButtonType.defaultOrder;

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

void migrateThemePrefsToDb() async {
  const String migrationUuid = "efdbace2-a642-4805-85e9-07a0b4d36488";

  try {
    final SharedPreferencesWithCache prefs =
        await SharedPreferencesWithCache.create(
          cacheOptions: SharedPreferencesWithCacheOptions(),
        );

    final ok = prefs.getString("flow.migration.$migrationUuid");

    if (ok != null) return;

    try {
      // ignore: deprecated_member_use_from_same_package

      final String? themeName = prefs.getString("flow.themeName");
      final bool themeChangesAppIcon =
          prefs.getBool("flow.themeChangesAppIcon") ?? true;

      UserPreferencesService().themeName = themeName;
      UserPreferencesService().themeChangesAppIcon = themeChangesAppIcon;

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

void migrateGeoExtensionToLocation() async {
  const String migrationUuid = "2d592b08-96e0-4ba7-b5de-3bc1a28edace";

  try {
    final SharedPreferencesWithCache prefs =
        await SharedPreferencesWithCache.create(
          cacheOptions: SharedPreferencesWithCacheOptions(),
        );

    final ok = prefs.getString("flow.migration.$migrationUuid");

    if (ok != null) return;

    try {
      final TransactionFilter filter = TransactionFilter(
        extraTag: "hasExtension:${Geo.keyName}",
      );

      final List<Transaction> transactions = await TransactionsService()
          .findMany(filter);

      final List<Transaction> updatedTransactions = transactions
          .map((transaction) => transaction.migrateGeoExtensionToLocation())
          .nonNulls
          .toList();

      final List<int> upserted = await TransactionsService().upsertMany(
        updatedTransactions,
      );

      await prefs.setString("flow.migration.$migrationUuid", "ok");
      _log.info("Migrated ${upserted.length}  for migration $migrationUuid");
    } catch (e) {
      _log.warning(
        "Failed to migrate transactions' geo extension to location for migration $migrationUuid",
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
