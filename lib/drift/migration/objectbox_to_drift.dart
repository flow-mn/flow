import "package:drift/drift.dart";
import "package:flow/drift/flow_database.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/budget.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/file_attachment.dart";
import "package:flow/entity/goal.dart";
import "package:flow/entity/profile.dart";
import "package:flow/entity/recurring_transaction.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction_filter_preset.dart";
import "package:flow/entity/transaction_tag.dart";
import "package:flow/entity/user_preferences.dart";
import "package:flow/objectbox.dart";
import "package:logging/logging.dart";

final Logger _log = Logger("ObjectBoxToDriftMigration");

/// One-time, transparent copy of every ObjectBox record into the Drift +
/// PowerSync database.
///
/// **Read-only against ObjectBox** — it never mutates the live database, so it
/// is zero-risk to existing data and the user does nothing manually.
///
/// **Idempotent / re-runnable** — every row is keyed by the entity `uuid`
/// (= the Drift row `id`) and written with [InsertMode.insertOrReplace], and
/// junction rows use a deterministic `"<parentUuid>:<childUuid>"` id, so a
/// re-run (e.g. after a partial failure) upserts in place and never duplicates.
///
/// Soft-deleted rows are copied too, so tombstones carry over.
class ObjectBoxToDriftMigration {
  final FlowDatabase db;

  ObjectBoxToDriftMigration(this.db);

  /// Copies everything. Returns per-table row counts for logging.
  Future<Map<String, int>> run() async {
    final ObjectBox ob = ObjectBox();
    final Map<String, int> counts = <String, int>{};

    // One transaction so the copy is all-or-nothing: a failure rolls the whole
    // thing back, leaving no half-populated DB for the next run to reconcile.
    await db.transaction(() async {
      counts["accounts"] = await _migrateAccounts(ob);
      counts["categories"] = await _migrateCategories(ob);
      counts["tags"] = await _migrateTags(ob);
      counts["attachments"] = await _migrateAttachments(ob);
      counts["profiles"] = await _migrateProfiles(ob);
      counts["user_preferences"] = await _migrateUserPreferences(ob);
      counts["transaction_filter_presets"] =
          await _migrateTransactionFilterPresets(ob);
      counts["transactions"] = await _migrateTransactions(ob);
      counts["budgets"] = await _migrateBudgets(ob);
      counts["goals"] = await _migrateGoals(ob);
      counts["recurring_transactions"] = await _migrateRecurringTransactions(
        ob,
      );
    });

    _log.info("Migration row counts: $counts");
    return counts;
  }

  Future<int> _migrateAccounts(ObjectBox ob) async {
    final List<Account> rows = ob.box<Account>().getAll();
    if (rows.isEmpty) return 0;
    await db.batch((Batch b) {
      b.insertAll(
        db.accounts,
        rows.map(
          (Account a) => AccountsCompanion.insert(
            id: Value(a.uuid),
            name: a.name,
            currency: a.currency,
            type: a.type,
            iconCode: a.iconCode,
            createdDate: a.createdDate,
            creditLimit: Value(a.creditLimit),
            sortOrder: Value(a.sortOrder),
            excludeFromTotalBalance: Value(a.excludeFromTotalBalance),
            archived: Value(a.archived),
            colorSchemeName: Value(a.colorSchemeName),
            updatedAt: Value(a.updatedAt),
            isDeleted: Value(a.isDeleted),
            deletedDate: Value(a.deletedDate),
          ),
        ),
        mode: InsertMode.insertOrReplace,
      );
    });
    return rows.length;
  }

  Future<int> _migrateCategories(ObjectBox ob) async {
    final List<Category> rows = ob.box<Category>().getAll();
    if (rows.isEmpty) return 0;
    await db.batch((Batch b) {
      b.insertAll(
        db.categories,
        rows.map(
          (Category c) => CategoriesCompanion.insert(
            id: Value(c.uuid),
            name: c.name,
            iconCode: c.iconCode,
            createdDate: c.createdDate,
            colorSchemeName: Value(c.colorSchemeName),
            updatedAt: Value(c.updatedAt),
            isDeleted: Value(c.isDeleted),
            deletedDate: Value(c.deletedDate),
          ),
        ),
        mode: InsertMode.insertOrReplace,
      );
    });
    return rows.length;
  }

  Future<int> _migrateTags(ObjectBox ob) async {
    final List<TransactionTag> rows = ob.box<TransactionTag>().getAll();
    if (rows.isEmpty) return 0;
    await db.batch((Batch b) {
      b.insertAll(
        db.tags,
        rows.map(
          (TransactionTag t) => TagsCompanion.insert(
            id: Value(t.uuid),
            title: t.title,
            createdDate: t.createdDate,
            iconCode: Value(t.iconCode),
            colorSchemeName: Value(t.colorSchemeName),
            type: Value(t.type),
            payload: Value(t.payload),
            updatedAt: Value(t.updatedAt),
            isDeleted: Value(t.isDeleted),
            deletedDate: Value(t.deletedDate),
          ),
        ),
        mode: InsertMode.insertOrReplace,
      );
    });
    return rows.length;
  }

  Future<int> _migrateAttachments(ObjectBox ob) async {
    final List<FileAttachment> rows = ob.box<FileAttachment>().getAll();
    if (rows.isEmpty) return 0;
    await db.batch((Batch b) {
      b.insertAll(
        db.attachments,
        rows.map(
          (FileAttachment f) => AttachmentsCompanion.insert(
            id: Value(f.uuid),
            filePath: f.filePath,
            createdDate: f.createdDate,
            name: Value(f.name),
            updatedAt: Value(f.updatedAt),
            isDeleted: Value(f.isDeleted),
            deletedDate: Value(f.deletedDate),
          ),
        ),
        mode: InsertMode.insertOrReplace,
      );
    });
    return rows.length;
  }

  Future<int> _migrateProfiles(ObjectBox ob) async {
    final List<Profile> rows = ob.box<Profile>().getAll();
    if (rows.isEmpty) return 0;
    await db.batch((Batch b) {
      b.insertAll(
        db.profiles,
        rows.map(
          (Profile p) => ProfilesCompanion.insert(
            id: Value(p.uuid),
            name: p.name,
            createdDate: p.createdDate,
            updatedAt: Value(p.updatedAt),
          ),
        ),
        mode: InsertMode.insertOrReplace,
      );
    });
    return rows.length;
  }

  Future<int> _migrateUserPreferences(ObjectBox ob) async {
    final List<UserPreferences> rows = ob.box<UserPreferences>().getAll();
    if (rows.isEmpty) return 0;
    await db.batch((Batch b) {
      b.insertAll(
        db.userPreferencesTable,
        rows.map(
          (UserPreferences u) => UserPreferencesTableCompanion.insert(
            id: Value(u.uuid),
            combineTransfers: Value(u.combineTransfers),
            excludeTransfersFromFlow: Value(u.excludeTransfersFromFlow),
            trashBinRetentionDays: Value(u.trashBinRetentionDays),
            defaultFilterPreset: Value(u.defaultFilterPreset),
            homePendingTransactionsTimeRangeSerialized: Value(
              u.homePendingTransactionsTimeRangeSerialized,
            ),
            remindDailyAtRelativeSeconds: Value(u.remindDailyAtRelativeSeconds),
            useCategoryNameForUntitledTransactions: Value(
              u.useCategoryNameForUntitledTransactions,
            ),
            transactionListTileShowCategoryName: Value(
              u.transactionListTileShowCategoryName,
            ),
            transactionListTileShowAccountForLeading: Value(
              u.transactionListTileShowAccountForLeading,
            ),
            transactionListTileShowExternalSource: Value(
              u.transactionListTileShowExternalSource,
            ),
            transactionListTileRelaxedDensity: Value(
              u.transactionListTileRelaxedDensity,
            ),
            createTransactionsPerItemInScans: Value(
              u.createTransactionsPerItemInScans,
            ),
            scansPendingThresholdInHours: Value(u.scansPendingThresholdInHours),
            privacyModeUponLaunch: Value(u.privacyModeUponLaunch),
            privacyModeUponShaking: Value(u.privacyModeUponShaking),
            icuCurrencyFormattingPattern: Value(u.icuCurrencyFormattingPattern),
            primaryCurrency: Value(u.primaryCurrency),
            primaryAccountId: Value(u.primaryAccountUuid),
            autoBackupIntervalInHours: Value(u.autoBackupIntervalInHours),
            enableICloudSync: Value(u.enableICloudSync),
            iCloudBackupsToKeep: Value(u.iCloudBackupsToKeep),
            transactionButtonOrderJoined: Value(u.transactionButtonOrderJoined),
            themeName: Value(u.themeName),
            themeChangesAppIcon: Value(u.themeChangesAppIcon),
            changeVisuals: Value(u.changeVisuals),
            transactionEntryFlowJson: Value(u.transactionEntryFlowJson),
            updatedAt: Value(u.updatedAt),
          ),
        ),
        mode: InsertMode.insertOrReplace,
      );
    });
    return rows.length;
  }

  Future<int> _migrateTransactionFilterPresets(ObjectBox ob) async {
    final List<TransactionFilterPreset> rows = ob
        .box<TransactionFilterPreset>()
        .getAll();
    if (rows.isEmpty) return 0;
    await db.batch((Batch b) {
      b.insertAll(
        db.transactionFilterPresets,
        rows.map(
          (TransactionFilterPreset p) =>
              TransactionFilterPresetsCompanion.insert(
                id: Value(p.uuid),
                name: p.name,
                jsonTransactionFilter: p.jsonTransactionFilter,
                createdDate: p.createdDate,
                updatedAt: Value(p.updatedAt),
              ),
        ),
        mode: InsertMode.insertOrReplace,
      );
    });
    return rows.length;
  }

  /// Transactions plus their tag/attachment junction links.
  Future<int> _migrateTransactions(ObjectBox ob) async {
    final List<Transaction> rows = ob.box<Transaction>().getAll();
    if (rows.isEmpty) return 0;
    await db.batch((Batch b) {
      for (final Transaction t in rows) {
        final List<double>? location = t.location;
        final bool hasLocation = location != null && location.length == 2;

        b.insert(
          db.transactions,
          TransactionsCompanion.insert(
            id: Value(t.uuid),
            amount: t.amount,
            currency: t.currency,
            transactionDate: t.transactionDate,
            createdDate: t.createdDate,
            title: Value(t.title),
            description: Value(t.description),
            isPending: Value(t.isPending),
            subtype: Value(t.subtype),
            extra: Value(t.extra),
            extraTags: Value(t.extraTags),
            latitude: Value(hasLocation ? location[0] : null),
            longitude: Value(hasLocation ? location[1] : null),
            accountId: Value(t.accountUuid),
            categoryId: Value(t.categoryUuid),
            updatedAt: Value(t.updatedAt),
            isDeleted: Value(t.isDeleted),
            deletedDate: Value(t.deletedDate),
          ),
          mode: InsertMode.insertOrReplace,
        );

        for (final String tagUuid in t.tagsUuids ?? const <String>[]) {
          b.insert(
            db.transactionTags,
            TransactionTagsCompanion.insert(
              id: Value("${t.uuid}:$tagUuid"),
              transactionId: t.uuid,
              tagId: tagUuid,
            ),
            mode: InsertMode.insertOrReplace,
          );
        }

        for (final String attachmentUuid
            in t.attachmentsUuids ?? const <String>[]) {
          b.insert(
            db.transactionAttachments,
            TransactionAttachmentsCompanion.insert(
              id: Value("${t.uuid}:$attachmentUuid"),
              transactionId: t.uuid,
              attachmentId: attachmentUuid,
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      }
    });
    return rows.length;
  }

  /// Budgets plus their budget↔category junction links.
  Future<int> _migrateBudgets(ObjectBox ob) async {
    final List<Budget> rows = ob.box<Budget>().getAll();
    if (rows.isEmpty) return 0;
    await db.batch((Batch b) {
      for (final Budget budget in rows) {
        b.insert(
          db.budgets,
          BudgetsCompanion.insert(
            id: Value(budget.uuid),
            name: budget.name,
            range: budget.range,
            amount: budget.amount,
            currency: budget.currency,
            createdDate: budget.createdDate,
            renewAutomatically: Value(budget.renewAutomatically),
            updatedAt: Value(budget.updatedAt),
            isDeleted: Value(budget.isDeleted),
            deletedDate: Value(budget.deletedDate),
          ),
          mode: InsertMode.insertOrReplace,
        );

        for (final String categoryUuid
            in budget.categoriesUuids ?? const <String>[]) {
          b.insert(
            db.budgetCategories,
            BudgetCategoriesCompanion.insert(
              id: Value("${budget.uuid}:$categoryUuid"),
              budgetId: budget.uuid,
              categoryId: categoryUuid,
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      }
    });
    return rows.length;
  }

  Future<int> _migrateGoals(ObjectBox ob) async {
    final List<Goal> rows = ob.box<Goal>().getAll();
    if (rows.isEmpty) return 0;
    await db.batch((Batch b) {
      b.insertAll(
        db.goals,
        rows.map(
          (Goal g) => GoalsCompanion.insert(
            id: Value(g.uuid),
            name: g.name,
            targetBalance: g.targetBalance,
            currency: g.currency,
            createdDate: g.createdDate,
            range: Value(g.range),
            iconCode: Value(g.iconCode),
            accountId: Value(g.accountUuid),
            updatedAt: Value(g.updatedAt),
            isDeleted: Value(g.isDeleted),
            deletedDate: Value(g.deletedDate),
          ),
        ),
        mode: InsertMode.insertOrReplace,
      );
    });
    return rows.length;
  }

  Future<int> _migrateRecurringTransactions(ObjectBox ob) async {
    final List<RecurringTransaction> rows = ob
        .box<RecurringTransaction>()
        .getAll();
    if (rows.isEmpty) return 0;
    await db.batch((Batch b) {
      b.insertAll(
        db.recurringTransactions,
        rows.map(
          (RecurringTransaction r) => RecurringTransactionsCompanion.insert(
            id: Value(r.uuid),
            jsonTransactionTemplate: r.jsonTransactionTemplate,
            range: r.range,
            rules: r.rules,
            createdDate: r.createdDate,
            transferToAccountId: Value(r.transferToAccountUuid),
            lastGeneratedTransactionDate: Value(r.lastGeneratedTransactionDate),
            disabled: Value(r.disabled),
            updatedAt: Value(r.updatedAt),
            isDeleted: Value(r.isDeleted),
            deletedDate: Value(r.deletedDate),
          ),
        ),
        mode: InsertMode.insertOrReplace,
      );
    });
    return rows.length;
  }
}
