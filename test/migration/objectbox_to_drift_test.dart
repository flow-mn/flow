import "dart:io";

import "package:flow/drift/flow_database.dart";
import "package:flow/drift/flow_drift.dart";
import "package:flow/drift/migration/objectbox_to_drift.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/budget.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/goal.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/objectbox.dart";
import "package:flutter/widgets.dart" show Locale;
import "package:flutter_test/flutter_test.dart";
import "package:path/path.dart" as path;

import "../objectbox_erase.dart";

/// End-to-end check of the ObjectBox → Drift/PowerSync migration harness:
/// seeds a realistic ObjectBox dataset, runs the copy against a real (local-
/// only) PowerSync database, and asserts counts, field fidelity, junction
/// links, and that a re-run is idempotent (no duplicates) — which is the part
/// that exercises PowerSync's view-write path.
void main() {
  late ObjectBox obx;
  late FlowDrift flow;
  late Map<String, int> counts;

  final String rootDir = path.join(
    Directory.current.path,
    ".objectbox_test_migration",
  );

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Demo account/category presets are localized; load English so their names
    // aren't empty.
    await FlowLocalizations(const Locale("en")).load();

    obx = await ObjectBox.initialize(
      customDirectory: rootDir,
      subdirectory: "main",
    );
    await obx.createAndPutDebugData();

    flow = await FlowDrift.initialize(
      customPath: path.join(rootDir, "flow_powersync_test.db"),
    );
    counts = await ObjectBoxToDriftMigration(flow.db).run();
  });

  tearDownAll(() async {
    await flow.close();
    await testCleanupObject(instance: obx, directory: rootDir);
  });

  test("source, reported, and destination row counts all agree", () async {
    final FlowDatabase db = flow.db;

    expect(counts["accounts"], obx.box<Account>().count());
    expect(counts["accounts"], greaterThan(0));
    expect((await db.select(db.accounts).get()).length, counts["accounts"]);

    expect(counts["categories"], obx.box<Category>().count());
    expect((await db.select(db.categories).get()).length, counts["categories"]);

    expect(counts["transactions"], obx.box<Transaction>().count());
    expect(counts["transactions"], greaterThan(1500));
    expect(
      (await db.select(db.transactions).get()).length,
      counts["transactions"],
    );

    expect(counts["budgets"], obx.box<Budget>().count());
    expect((await db.select(db.budgets).get()).length, counts["budgets"]);

    expect(counts["goals"], obx.box<Goal>().count());
    expect((await db.select(db.goals).get()).length, counts["goals"]);
  });

  test("account and transaction field values survive the copy", () async {
    final FlowDatabase db = flow.db;

    final Account srcAccount = obx.box<Account>().getAll().first;
    final DbAccount dstAccount = await (db.select(
      db.accounts,
    )..where((t) => t.id.equals(srcAccount.uuid))).getSingle();

    expect(dstAccount.name, srcAccount.name);
    expect(dstAccount.currency, srcAccount.currency);
    expect(
      dstAccount.createdDate.toUtc().millisecondsSinceEpoch,
      srcAccount.createdDate.toUtc().millisecondsSinceEpoch,
    );

    final Transaction srcTxn = obx.box<Transaction>().getAll().first;
    final DbTransaction dstTxn = await (db.select(
      db.transactions,
    )..where((t) => t.id.equals(srcTxn.uuid))).getSingle();

    expect(dstTxn.amount, srcTxn.amount);
    expect(dstTxn.currency, srcTxn.currency);
    expect(dstTxn.accountId, srcTxn.accountUuid);
    expect(
      dstTxn.transactionDate.toUtc().millisecondsSinceEpoch,
      srcTxn.transactionDate.toUtc().millisecondsSinceEpoch,
    );
  });

  test("transaction↔tag junction links are rebuilt one-to-one", () async {
    final FlowDatabase db = flow.db;

    final int expectedLinks = obx.box<Transaction>().getAll().fold<int>(
      0,
      (sum, t) => sum + (t.tagsUuids?.length ?? 0),
    );
    final int actualLinks = (await db.select(db.transactionTags).get()).length;

    expect(actualLinks, greaterThan(0));
    expect(actualLinks, expectedLinks);
  });

  test("re-running the migration is idempotent (no duplicate rows)", () async {
    final FlowDatabase db = flow.db;

    final int accountsBefore = (await db.select(db.accounts).get()).length;
    final int txnsBefore = (await db.select(db.transactions).get()).length;
    final int linksBefore = (await db.select(db.transactionTags).get()).length;

    await ObjectBoxToDriftMigration(db).run();

    expect((await db.select(db.accounts).get()).length, accountsBefore);
    expect((await db.select(db.transactions).get()).length, txnsBefore);
    expect((await db.select(db.transactionTags).get()).length, linksBefore);
  });
}
