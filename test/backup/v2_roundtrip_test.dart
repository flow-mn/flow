import "dart:convert";
import "dart:io";

import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/sync/export/export_v2.dart";
import "package:flow/sync/model/model_v2.dart";
import "package:flutter_test/flutter_test.dart";
import "package:path/path.dart" as path;

import "../database_test.dart" show objectboxTestRootDir;
import "../objectbox_erase.dart";
import "v1_populate.dart";

/// Roundtrip the v2 export through `generateBackupJSONContentV2` →
/// `SyncModelV2.fromJson` and assert that every account, category, and
/// transaction survives serialization. Catches the common regression where
/// an entity field is added but `JsonSerializable` codegen isn't re-run,
/// or where the export pipeline forgets to include a new field.
void main() async {
  group("Sync V2: JSON export/import roundtrip", () {
    const int dummyTransactionCount = 50;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();

      // Pre-clean so a crashed prior run doesn't bias the dataset.
      // `populateDummyData` short-circuits when an "Alpha" account already
      // exists; without the wipe, re-runs would append on top of stale data
      // and the test would still pass for the wrong reason.
      final Directory previous = Directory(
        path.join(objectboxTestRootDir().path, "sync/v2"),
      );
      if (previous.existsSync()) {
        previous.deleteSync(recursive: true);
      }

      await ObjectBox.initialize(
        customDirectory: objectboxTestRootDir().path,
        subdirectory: "sync/v2",
      );

      await populateDummyData(dummyTransactionCount);
    });

    test("Generated JSON parses back into SyncModelV2", () async {
      final String jsonContent = await generateBackupJSONContentV2();
      final Map<String, dynamic> decoded =
          jsonDecode(jsonContent) as Map<String, dynamic>;

      expect(decoded["versionCode"], 2);
      expect(decoded.containsKey("transactions"), isTrue);
      expect(decoded.containsKey("accounts"), isTrue);
      expect(decoded.containsKey("categories"), isTrue);

      // The actual deserialization — this is what import_v2 will do.
      final SyncModelV2 parsed = SyncModelV2.fromJson(decoded);

      expect(parsed.versionCode, 2);
      expect(parsed.accounts, isNotEmpty);
      expect(parsed.categories, isNotEmpty);
      expect(parsed.transactions, isNotEmpty);
    });

    test(
      "Exported entity counts match what's in the ObjectBox store",
      () async {
        final int expectedAccounts = ObjectBox().box<Account>().count();
        final int expectedCategories = ObjectBox().box<Category>().count();
        final int expectedTransactions = ObjectBox().box<Transaction>().count();

        final SyncModelV2 parsed = SyncModelV2.fromJson(
          jsonDecode(await generateBackupJSONContentV2())
              as Map<String, dynamic>,
        );

        expect(parsed.accounts.length, expectedAccounts);
        expect(parsed.categories.length, expectedCategories);
        expect(parsed.transactions.length, expectedTransactions);
      },
    );

    test(
      "Every account uuid + name + currency survives roundtrip",
      () async {
        final List<Account> originals = await ObjectBox()
            .box<Account>()
            .getAllAsync();
        final SyncModelV2 parsed = SyncModelV2.fromJson(
          jsonDecode(await generateBackupJSONContentV2())
              as Map<String, dynamic>,
        );

        final Map<String, Account> byUuid = {
          for (final a in parsed.accounts) a.uuid: a,
        };

        for (final original in originals) {
          final Account? roundtripped = byUuid[original.uuid];
          expect(
            roundtripped,
            isNotNull,
            reason: "Account ${original.uuid} (${original.name}) lost",
          );
          expect(roundtripped!.name, original.name);
          expect(roundtripped.currency, original.currency);
        }
      },
    );

    test(
      "Every category uuid + name survives roundtrip",
      () async {
        final List<Category> originals = await ObjectBox()
            .box<Category>()
            .getAllAsync();
        final SyncModelV2 parsed = SyncModelV2.fromJson(
          jsonDecode(await generateBackupJSONContentV2())
              as Map<String, dynamic>,
        );

        final Map<String, Category> byUuid = {
          for (final c in parsed.categories) c.uuid: c,
        };

        for (final original in originals) {
          final Category? roundtripped = byUuid[original.uuid];
          expect(
            roundtripped,
            isNotNull,
            reason: "Category ${original.uuid} (${original.name}) lost",
          );
          expect(roundtripped!.name, original.name);
        }
      },
    );

    test(
      "Every transaction uuid + amount + currency + date survives roundtrip",
      () async {
        final List<Transaction> originals = await ObjectBox()
            .box<Transaction>()
            .getAllAsync();
        final SyncModelV2 parsed = SyncModelV2.fromJson(
          jsonDecode(await generateBackupJSONContentV2())
              as Map<String, dynamic>,
        );

        final Map<String, Transaction> byUuid = {
          for (final t in parsed.transactions) t.uuid: t,
        };

        for (final original in originals) {
          final Transaction? roundtripped = byUuid[original.uuid];
          expect(
            roundtripped,
            isNotNull,
            reason: "Transaction ${original.uuid} lost",
          );
          expect(roundtripped!.amount, original.amount);
          expect(roundtripped.currency, original.currency);
          // Compare ISO 8601 strings to avoid microsecond drift across JSON
          // boundaries.
          expect(
            roundtripped.transactionDate.toUtc().toIso8601String(),
            original.transactionDate.toUtc().toIso8601String(),
          );
        }
      },
    );

    tearDownAll(() async {
      await testCleanupObject(
        instance: ObjectBox(),
        directory: ObjectBox.appDataDirectory,
        cleanUp: true,
      );
    });
  });
}
