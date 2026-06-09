import "package:flow/data/flow_icon.dart";
import "package:flow/data/legacy_simple_icons_codepoints.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/data/transactions_filter/pending_time_range.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
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
import "package:simple_icons_flow/simple_icons_flow.dart";

final Logger _log = Logger("GracefulMigrations");

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

void migratePrivacyPreferencesToUserPreferences() async {
  const String migrationUuid = "c2c3473a-ea23-4a3d-a247-952861a7435e";

  try {
    final SharedPreferencesWithCache prefs =
        await SharedPreferencesWithCache.create(
          cacheOptions: SharedPreferencesWithCacheOptions(),
        );

    final ok = prefs.getString("flow.migration.$migrationUuid");

    if (ok != null) return;

    try {
      // ignore: deprecated_member_use_from_same_package
      final bool privacyMode = LocalPreferences().privacyMode.get();

      UserPreferencesService().privacyModeUponLaunch = privacyMode;

      await prefs.setString("flow.migration.$migrationUuid", "ok");
    } catch (e) {
      _log.warning(
        "Failed to migrate privacy preferences for migration $migrationUuid",
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

Future<void> migrateExtraKeyIndexing() async {
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

Future<void> migrateGeoExtensionToLocation() async {
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

void migrateHomePendingTransactionsRange() async {
  const String migrationUuid = "2130fe7d-6cdc-45c2-9632-56ba9de56c08";

  try {
    final SharedPreferencesWithCache prefs =
        await SharedPreferencesWithCache.create(
          cacheOptions: SharedPreferencesWithCacheOptions(),
        );

    final ok = prefs.getString("flow.migration.$migrationUuid");

    if (ok != null) return;

    try {
      final int? old = LocalPreferences().pendingTransactions.homeTimeframe
          .get();

      if (old != null) {
        final PendingTimeRange newRange = PendingTimeRange.duration(
          Duration(days: old.abs()),
        );

        UserPreferencesService().homePendingTransactionsTimeRange = newRange;
      } else {
        UserPreferencesService().homePendingTransactionsTimeRange =
            PendingTimeRange.followHome();
      }

      await prefs.setString("flow.migration.$migrationUuid", "ok");
      _log.info(
        "Migrated home pending transactions range for migration $migrationUuid",
      );
    } catch (e) {
      _log.warning(
        "Failed to migrate home pending transactions range for migration $migrationUuid",
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

/// Converts Simple Icons brand icons stored as a code-point [IconFlowIcon] into
/// the slug-based [SimpleIconFlowIcon].
///
/// Simple Icons reassigns code points every release, so a stored code point is
/// only meaningful for the version it was saved with. Flow shipped
/// simple_icons 14.6.1; [legacySimpleIconsCodepoints] maps those code points
/// forward to the bundled 16.20.0 build, from which we recover the stable slug.
/// This is the *only* remaining use of that table — once this migration has
/// propagated, the migration and the table can both be deleted.
Future<void> migrateSimpleIconsToSlug() async {
  const String migrationUuid = "598a1c1d-1d53-44e0-9035-e005c5420538";

  try {
    final SharedPreferencesWithCache prefs =
        await SharedPreferencesWithCache.create(
          cacheOptions: SharedPreferencesWithCacheOptions(),
        );

    final ok = prefs.getString("flow.migration.$migrationUuid");

    if (ok != null) return;

    try {
      // 16.20.0 code point -> slug, built once from the bundled font.
      final Map<int, String> codePointToSlug = {
        for (final entry in SimpleIcons.values.entries)
          entry.value.codePoint: entry.key,
      };

      String? slugForIconCode(String iconCode) {
        final FlowIconData? parsed = FlowIconData.tryParse(iconCode);
        if (parsed is! IconFlowIcon) return null;
        if (parsed.iconData.fontFamily != "SimpleIcons") return null;

        // Stored code points are 14.6.1; map them forward before resolving.
        // A value already at 16.20.0 isn't a table key, so it passes through.
        final int codePoint =
            legacySimpleIconsCodepoints[parsed.iconData.codePoint] ??
            parsed.iconData.codePoint;
        return codePointToSlug[codePoint];
      }

      final List<Account> changedAccounts = [];
      for (final Account account in ObjectBox().box<Account>().getAll()) {
        final String? slug = slugForIconCode(account.iconCode);
        if (slug == null) continue;
        account.iconCode = SimpleIconFlowIcon(slug).toString();
        changedAccounts.add(account);
      }

      final List<Category> changedCategories = [];
      for (final Category category in ObjectBox().box<Category>().getAll()) {
        final String? slug = slugForIconCode(category.iconCode);
        if (slug == null) continue;
        category.iconCode = SimpleIconFlowIcon(slug).toString();
        changedCategories.add(category);
      }

      if (changedAccounts.isNotEmpty) {
        await ObjectBox().box<Account>().putManyAsync(changedAccounts);
      }
      if (changedCategories.isNotEmpty) {
        await ObjectBox().box<Category>().putManyAsync(changedCategories);
      }

      await prefs.setString("flow.migration.$migrationUuid", "ok");
      _log.info(
        "Migrated ${changedAccounts.length} account(s) and "
        "${changedCategories.length} category(ies) to slug-based brand icons "
        "for migration $migrationUuid",
      );
    } catch (e) {
      _log.warning(
        "Failed to migrate Simple Icons to slugs for migration $migrationUuid",
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
