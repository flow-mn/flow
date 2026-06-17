import "package:drift/drift.dart";
import "package:flow/drift/converters.dart";
import "package:powersync/powersync.dart" show uuid;

part "flow_database.g.dart";

/// Drift tables mirroring the PowerSync schema in `flow_schema.dart`.
///
/// Row classes are prefixed `Db…` via [DataClassName] so they don't collide
/// with Flow's existing ObjectBox entity classes (`Account`, `Transaction`, …),
/// which still coexist during the migration.
///
/// PowerSync owns the on-disk tables, so these definitions are purely for
/// type-safe Drift access — the database never runs `createAll()` (see
/// [FlowDatabase.migration]). Every table's `id` is the entity `uuid`.

@DataClassName("DbAccount")
class Accounts extends Table {
  @override
  String get tableName => "accounts";

  TextColumn get id => text().clientDefault(() => uuid.v4())();
  TextColumn get name => text()();
  TextColumn get currency => text()();
  RealColumn get creditLimit => real().named("credit_limit").nullable()();
  IntColumn get sortOrder =>
      integer().named("sort_order").withDefault(const Constant(-1))();
  TextColumn get type => text()();
  BoolColumn get excludeFromTotalBalance => boolean()
      .named("exclude_from_total_balance")
      .withDefault(const Constant(false))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  TextColumn get colorSchemeName =>
      text().named("color_scheme_name").nullable()();
  TextColumn get iconCode => text().named("icon_code")();
  TextColumn get createdDate =>
      text().named("created_date").map(const UtcDateTimeConverter())();
  TextColumn get updatedAt =>
      text().named("updated_at").map(const UtcDateTimeConverter()).nullable()();
  BoolColumn get isDeleted => boolean().named("is_deleted").nullable()();
  TextColumn get deletedDate => text()
      .named("deleted_date")
      .map(const UtcDateTimeConverter())
      .nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName("DbCategory")
class Categories extends Table {
  @override
  String get tableName => "categories";

  TextColumn get id => text().clientDefault(() => uuid.v4())();
  TextColumn get name => text()();
  TextColumn get iconCode => text().named("icon_code")();
  TextColumn get colorSchemeName =>
      text().named("color_scheme_name").nullable()();
  TextColumn get createdDate =>
      text().named("created_date").map(const UtcDateTimeConverter())();
  TextColumn get updatedAt =>
      text().named("updated_at").map(const UtcDateTimeConverter()).nullable()();
  BoolColumn get isDeleted => boolean().named("is_deleted").nullable()();
  TextColumn get deletedDate => text()
      .named("deleted_date")
      .map(const UtcDateTimeConverter())
      .nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName("DbTransaction")
class Transactions extends Table {
  @override
  String get tableName => "transactions";

  TextColumn get id => text().clientDefault(() => uuid.v4())();
  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();
  RealColumn get amount => real()();
  TextColumn get currency => text()();
  BoolColumn get isPending => boolean().named("is_pending").nullable()();
  TextColumn get subtype => text().nullable()();
  TextColumn get extra => text().nullable()();
  TextColumn get extraTags =>
      text().named("extra_tags").map(const StringListConverter()).nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get accountId => text().named("account_id").nullable()();
  TextColumn get categoryId => text().named("category_id").nullable()();
  TextColumn get transactionDate =>
      text().named("transaction_date").map(const UtcDateTimeConverter())();
  TextColumn get createdDate =>
      text().named("created_date").map(const UtcDateTimeConverter())();
  TextColumn get updatedAt =>
      text().named("updated_at").map(const UtcDateTimeConverter()).nullable()();
  BoolColumn get isDeleted => boolean().named("is_deleted").nullable()();
  TextColumn get deletedDate => text()
      .named("deleted_date")
      .map(const UtcDateTimeConverter())
      .nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName("DbTag")
class Tags extends Table {
  @override
  String get tableName => "tags";

  TextColumn get id => text().clientDefault(() => uuid.v4())();
  TextColumn get title => text()();
  TextColumn get iconCode => text().named("icon_code").nullable()();
  TextColumn get colorSchemeName =>
      text().named("color_scheme_name").nullable()();
  TextColumn get type => text().nullable()();
  TextColumn get payload => text().nullable()();
  TextColumn get createdDate =>
      text().named("created_date").map(const UtcDateTimeConverter())();
  TextColumn get updatedAt =>
      text().named("updated_at").map(const UtcDateTimeConverter()).nullable()();
  BoolColumn get isDeleted => boolean().named("is_deleted").nullable()();
  TextColumn get deletedDate => text()
      .named("deleted_date")
      .map(const UtcDateTimeConverter())
      .nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Junction for the transaction ↔ tag many-to-many relation.
@DataClassName("DbTransactionTag")
class TransactionTags extends Table {
  @override
  String get tableName => "transaction_tags";

  TextColumn get id => text().clientDefault(() => uuid.v4())();
  TextColumn get transactionId => text().named("transaction_id")();
  TextColumn get tagId => text().named("tag_id")();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName("DbBudget")
class Budgets extends Table {
  @override
  String get tableName => "budgets";

  TextColumn get id => text().clientDefault(() => uuid.v4())();
  TextColumn get name => text()();
  TextColumn get range => text()();
  BoolColumn get renewAutomatically => boolean()
      .named("renew_automatically")
      .withDefault(const Constant(true))();
  RealColumn get amount => real()();
  TextColumn get currency => text()();
  TextColumn get createdDate =>
      text().named("created_date").map(const UtcDateTimeConverter())();
  TextColumn get updatedAt =>
      text().named("updated_at").map(const UtcDateTimeConverter()).nullable()();
  BoolColumn get isDeleted => boolean().named("is_deleted").nullable()();
  TextColumn get deletedDate => text()
      .named("deleted_date")
      .map(const UtcDateTimeConverter())
      .nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName("DbGoal")
class Goals extends Table {
  @override
  String get tableName => "goals";

  TextColumn get id => text().clientDefault(() => uuid.v4())();
  TextColumn get name => text()();
  TextColumn get range => text().nullable()();
  RealColumn get targetBalance => real().named("target_balance")();
  TextColumn get currency => text()();
  TextColumn get iconCode => text().named("icon_code").nullable()();
  TextColumn get accountId => text().named("account_id").nullable()();
  TextColumn get createdDate =>
      text().named("created_date").map(const UtcDateTimeConverter())();
  TextColumn get updatedAt =>
      text().named("updated_at").map(const UtcDateTimeConverter()).nullable()();
  BoolColumn get isDeleted => boolean().named("is_deleted").nullable()();
  TextColumn get deletedDate => text()
      .named("deleted_date")
      .map(const UtcDateTimeConverter())
      .nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName("DbRecurringTransaction")
class RecurringTransactions extends Table {
  @override
  String get tableName => "recurring_transactions";

  TextColumn get id => text().clientDefault(() => uuid.v4())();
  TextColumn get jsonTransactionTemplate =>
      text().named("json_transaction_template")();
  TextColumn get transferToAccountId =>
      text().named("transfer_to_account_id").nullable()();
  TextColumn get range => text()();
  TextColumn get rules => text().map(const StringListConverter())();
  TextColumn get lastGeneratedTransactionDate => text()
      .named("last_generated_transaction_date")
      .map(const UtcDateTimeConverter())
      .nullable()();
  BoolColumn get disabled => boolean().withDefault(const Constant(false))();
  TextColumn get createdDate =>
      text().named("created_date").map(const UtcDateTimeConverter())();
  TextColumn get updatedAt =>
      text().named("updated_at").map(const UtcDateTimeConverter()).nullable()();
  BoolColumn get isDeleted => boolean().named("is_deleted").nullable()();
  TextColumn get deletedDate => text()
      .named("deleted_date")
      .map(const UtcDateTimeConverter())
      .nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName("DbAttachment")
class Attachments extends Table {
  @override
  String get tableName => "attachments";

  TextColumn get id => text().clientDefault(() => uuid.v4())();
  TextColumn get name => text().nullable()();
  TextColumn get filePath => text().named("file_path")();
  TextColumn get createdDate =>
      text().named("created_date").map(const UtcDateTimeConverter())();
  TextColumn get updatedAt =>
      text().named("updated_at").map(const UtcDateTimeConverter()).nullable()();
  BoolColumn get isDeleted => boolean().named("is_deleted").nullable()();
  TextColumn get deletedDate => text()
      .named("deleted_date")
      .map(const UtcDateTimeConverter())
      .nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName("DbProfile")
class Profiles extends Table {
  @override
  String get tableName => "profiles";

  TextColumn get id => text().clientDefault(() => uuid.v4())();
  TextColumn get name => text()();
  TextColumn get createdDate =>
      text().named("created_date").map(const UtcDateTimeConverter())();
  TextColumn get updatedAt =>
      text().named("updated_at").map(const UtcDateTimeConverter()).nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The per-user settings singleton. No soft-delete; `updated_at` only.
@DataClassName("DbUserPreferences")
class UserPreferencesTable extends Table {
  @override
  String get tableName => "user_preferences";

  TextColumn get id => text().clientDefault(() => uuid.v4())();
  BoolColumn get combineTransfers =>
      boolean().named("combine_transfers").withDefault(const Constant(true))();
  BoolColumn get excludeTransfersFromFlow => boolean()
      .named("exclude_transfers_from_flow")
      .withDefault(const Constant(true))();
  IntColumn get trashBinRetentionDays =>
      integer().named("trash_bin_retention_days").nullable()();
  TextColumn get defaultFilterPreset =>
      text().named("default_filter_preset").nullable()();
  TextColumn get homePendingTransactionsTimeRangeSerialized => text()
      .named("home_pending_transactions_time_range_serialized")
      .nullable()();
  IntColumn get remindDailyAtRelativeSeconds =>
      integer().named("remind_daily_at_relative_seconds").nullable()();
  BoolColumn get useCategoryNameForUntitledTransactions => boolean()
      .named("use_category_name_for_untitled_transactions")
      .withDefault(const Constant(false))();
  BoolColumn get transactionListTileShowCategoryName => boolean()
      .named("transaction_list_tile_show_category_name")
      .withDefault(const Constant(false))();
  BoolColumn get transactionListTileShowAccountForLeading => boolean()
      .named("transaction_list_tile_show_account_for_leading")
      .withDefault(const Constant(false))();
  BoolColumn get transactionListTileShowExternalSource => boolean()
      .named("transaction_list_tile_show_external_source")
      .withDefault(const Constant(true))();
  BoolColumn get transactionListTileRelaxedDensity => boolean()
      .named("transaction_list_tile_relaxed_density")
      .withDefault(const Constant(false))();
  BoolColumn get createTransactionsPerItemInScans => boolean()
      .named("create_transactions_per_item_in_scans")
      .withDefault(const Constant(true))();
  IntColumn get scansPendingThresholdInHours =>
      integer().named("scans_pending_threshold_in_hours").nullable()();
  BoolColumn get privacyModeUponLaunch => boolean()
      .named("privacy_mode_upon_launch")
      .withDefault(const Constant(false))();
  BoolColumn get privacyModeUponShaking => boolean()
      .named("privacy_mode_upon_shaking")
      .withDefault(const Constant(false))();
  TextColumn get icuCurrencyFormattingPattern =>
      text().named("icu_currency_formatting_pattern").nullable()();
  TextColumn get primaryCurrency =>
      text().named("primary_currency").nullable()();
  TextColumn get primaryAccountId =>
      text().named("primary_account_id").nullable()();
  IntColumn get autoBackupIntervalInHours =>
      integer().named("auto_backup_interval_in_hours").nullable()();
  BoolColumn get enableICloudSync => boolean()
      .named("enable_icloud_sync")
      .withDefault(const Constant(false))();
  IntColumn get iCloudBackupsToKeep =>
      integer().named("icloud_backups_to_keep").nullable()();
  TextColumn get transactionButtonOrderJoined =>
      text().named("transaction_button_order_joined").nullable()();
  TextColumn get themeName => text().named("theme_name").nullable()();
  BoolColumn get themeChangesAppIcon => boolean()
      .named("theme_changes_app_icon")
      .withDefault(const Constant(true))();
  TextColumn get changeVisuals => text().named("change_visuals").nullable()();
  TextColumn get transactionEntryFlowJson =>
      text().named("transaction_entry_flow_json").nullable()();
  TextColumn get updatedAt =>
      text().named("updated_at").map(const UtcDateTimeConverter()).nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName("DbTransactionFilterPreset")
class TransactionFilterPresets extends Table {
  @override
  String get tableName => "transaction_filter_presets";

  TextColumn get id => text().clientDefault(() => uuid.v4())();
  TextColumn get name => text()();
  TextColumn get jsonTransactionFilter =>
      text().named("json_transaction_filter")();
  TextColumn get createdDate =>
      text().named("created_date").map(const UtcDateTimeConverter())();
  TextColumn get updatedAt =>
      text().named("updated_at").map(const UtcDateTimeConverter()).nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Junction for the transaction ↔ attachment many-to-many relation.
@DataClassName("DbTransactionAttachment")
class TransactionAttachments extends Table {
  @override
  String get tableName => "transaction_attachments";

  TextColumn get id => text().clientDefault(() => uuid.v4())();
  TextColumn get transactionId => text().named("transaction_id")();
  TextColumn get attachmentId => text().named("attachment_id")();

  @override
  Set<Column> get primaryKey => {id};
}

/// Junction for the budget ↔ category many-to-many relation.
@DataClassName("DbBudgetCategory")
class BudgetCategories extends Table {
  @override
  String get tableName => "budget_categories";

  TextColumn get id => text().clientDefault(() => uuid.v4())();
  TextColumn get budgetId => text().named("budget_id")();
  TextColumn get categoryId => text().named("category_id")();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Accounts,
    Categories,
    Transactions,
    Tags,
    TransactionTags,
    Budgets,
    Goals,
    RecurringTransactions,
    Attachments,
    Profiles,
    UserPreferencesTable,
    TransactionFilterPresets,
    TransactionAttachments,
    BudgetCategories,
  ],
)
class FlowDatabase extends _$FlowDatabase {
  FlowDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      // Intentionally empty. PowerSync creates these tables (as views over its
      // internal storage) during PowerSyncDatabase.initialize(); calling
      // m.createAll() here would clash with the PowerSync-managed schema.
    },
  );
}
