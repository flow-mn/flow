import "package:flow/entity/transaction.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:logging/logging.dart";
import "package:shared_preferences/shared_preferences.dart";

final Logger _log = Logger("GracefulMigrations");

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

      Query<Transaction> untitleds =
          ObjectBox()
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
      Query<Transaction> withExtras =
          ObjectBox()
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
