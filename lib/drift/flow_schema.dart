import "package:powersync/powersync.dart";

/// PowerSync schema for Flow's SQLite database.
///
/// PowerSync owns the on-disk tables (it creates them as views over its
/// internal storage when [PowerSyncDatabase.initialize] runs), so this is the
/// single source of truth for table/column shape — the Drift tables in
/// `flow_database.dart` mirror it for type-safe access.
///
/// Conventions, dictated by PowerSync + Flow's Phase 0 sync prep:
/// * Every table is keyed by an implicit text `id` (the entity `uuid`); never
///   declare it here — PowerSync adds it automatically.
/// * Dates are `text` (ISO-8601 UTC), booleans are `integer` (0/1), money/
///   coordinates are `real`. Drift is configured (build.yaml) to store dates as
///   text so both sides agree.
/// * Relations are foreign-key text columns holding the referenced `uuid`
///   (e.g. `account_id`), matching Flow's existing `accountUuid` strings.
///   Many-to-many links live in their own junction tables.
///
/// Covers all 11 synced entities (BackupEntry is local-only and excluded) plus
/// three junction tables for the many-to-many relations: transaction↔tag,
/// transaction↔attachment, and budget↔category.
const Schema flowSchema = Schema([
  Table("accounts", [
    Column.text("name"),
    Column.text("currency"),
    Column.real("credit_limit"),
    Column.integer("sort_order"),
    Column.text("type"),
    Column.integer("exclude_from_total_balance"),
    Column.integer("archived"),
    Column.text("color_scheme_name"),
    Column.text("icon_code"),
    Column.text("created_date"),
    Column.text("updated_at"),
    Column.integer("is_deleted"),
    Column.text("deleted_date"),
  ]),
  Table("categories", [
    Column.text("name"),
    Column.text("icon_code"),
    Column.text("color_scheme_name"),
    Column.text("created_date"),
    Column.text("updated_at"),
    Column.integer("is_deleted"),
    Column.text("deleted_date"),
  ]),
  Table(
    "transactions",
    [
      Column.text("title"),
      Column.text("description"),
      Column.real("amount"),
      Column.text("currency"),
      Column.integer("is_pending"),
      Column.text("subtype"),
      Column.text("extra"),
      Column.text("extra_tags"),
      Column.real("latitude"),
      Column.real("longitude"),
      Column.text("account_id"),
      Column.text("category_id"),
      Column.text("transaction_date"),
      Column.text("created_date"),
      Column.text("updated_at"),
      Column.integer("is_deleted"),
      Column.text("deleted_date"),
    ],
    indexes: [
      Index("tx_account", [IndexedColumn("account_id")]),
      Index("tx_category", [IndexedColumn("category_id")]),
      Index("tx_date", [IndexedColumn("transaction_date")]),
    ],
  ),
  Table("tags", [
    Column.text("title"),
    Column.text("icon_code"),
    Column.text("color_scheme_name"),
    Column.text("type"),
    Column.text("payload"),
    Column.text("created_date"),
    Column.text("updated_at"),
    Column.integer("is_deleted"),
    Column.text("deleted_date"),
  ]),
  // Junction for the transaction ↔ tag many-to-many relation.
  Table(
    "transaction_tags",
    [Column.text("transaction_id"), Column.text("tag_id")],
    indexes: [
      Index("tt_transaction", [IndexedColumn("transaction_id")]),
      Index("tt_tag", [IndexedColumn("tag_id")]),
    ],
  ),
  Table("budgets", [
    Column.text("name"),
    Column.text("range"),
    Column.integer("renew_automatically"),
    Column.real("amount"),
    Column.text("currency"),
    Column.text("created_date"),
    Column.text("updated_at"),
    Column.integer("is_deleted"),
    Column.text("deleted_date"),
  ]),
  Table(
    "goals",
    [
      Column.text("name"),
      Column.text("range"),
      Column.real("target_balance"),
      Column.text("currency"),
      Column.text("icon_code"),
      Column.text("account_id"),
      Column.text("created_date"),
      Column.text("updated_at"),
      Column.integer("is_deleted"),
      Column.text("deleted_date"),
    ],
    indexes: [
      Index("goal_account", [IndexedColumn("account_id")]),
    ],
  ),
  Table("recurring_transactions", [
    Column.text("json_transaction_template"),
    Column.text("transfer_to_account_id"),
    Column.text("range"),
    Column.text("rules"),
    Column.text("last_generated_transaction_date"),
    Column.integer("disabled"),
    Column.text("created_date"),
    Column.text("updated_at"),
    Column.integer("is_deleted"),
    Column.text("deleted_date"),
  ]),
  Table("attachments", [
    Column.text("name"),
    Column.text("file_path"),
    Column.text("created_date"),
    Column.text("updated_at"),
    Column.integer("is_deleted"),
    Column.text("deleted_date"),
  ]),
  Table("profiles", [
    Column.text("name"),
    Column.text("created_date"),
    Column.text("updated_at"),
  ]),
  // Singleton-ish per-user settings. No soft-delete; `updated_at` only.
  Table("user_preferences", [
    Column.integer("combine_transfers"),
    Column.integer("exclude_transfers_from_flow"),
    Column.integer("trash_bin_retention_days"),
    Column.text("default_filter_preset"),
    Column.text("home_pending_transactions_time_range_serialized"),
    Column.integer("remind_daily_at_relative_seconds"),
    Column.integer("use_category_name_for_untitled_transactions"),
    Column.integer("transaction_list_tile_show_category_name"),
    Column.integer("transaction_list_tile_show_account_for_leading"),
    Column.integer("transaction_list_tile_show_external_source"),
    Column.integer("transaction_list_tile_relaxed_density"),
    Column.integer("create_transactions_per_item_in_scans"),
    Column.integer("scans_pending_threshold_in_hours"),
    Column.integer("privacy_mode_upon_launch"),
    Column.integer("privacy_mode_upon_shaking"),
    Column.text("icu_currency_formatting_pattern"),
    Column.text("primary_currency"),
    Column.text("primary_account_id"),
    Column.integer("auto_backup_interval_in_hours"),
    Column.integer("enable_icloud_sync"),
    Column.integer("icloud_backups_to_keep"),
    Column.text("transaction_button_order_joined"),
    Column.text("theme_name"),
    Column.integer("theme_changes_app_icon"),
    Column.text("change_visuals"),
    Column.text("transaction_entry_flow_json"),
    Column.text("updated_at"),
  ]),
  Table("transaction_filter_presets", [
    Column.text("name"),
    Column.text("json_transaction_filter"),
    Column.text("created_date"),
    Column.text("updated_at"),
  ]),
  // Junction for the transaction ↔ attachment many-to-many relation.
  Table(
    "transaction_attachments",
    [Column.text("transaction_id"), Column.text("attachment_id")],
    indexes: [
      Index("ta_transaction", [IndexedColumn("transaction_id")]),
      Index("ta_attachment", [IndexedColumn("attachment_id")]),
    ],
  ),
  // Junction for the budget ↔ category many-to-many relation.
  Table(
    "budget_categories",
    [Column.text("budget_id"), Column.text("category_id")],
    indexes: [
      Index("bc_budget", [IndexedColumn("budget_id")]),
      Index("bc_category", [IndexedColumn("category_id")]),
    ],
  ),
]);
