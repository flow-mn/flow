import "dart:io";

import "package:flow/constants.dart";
import "package:flow/data/flow_icon.dart";
import "package:flow/data/setup/default_accounts.dart";
import "package:flow/data/setup/default_categories.dart";
import "package:flow/data/setup/demo_data.dart";
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
import "package:flow/objectbox/objectbox.g.dart";
import "package:flutter/widgets.dart";
import "package:logging/logging.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";
import "package:path/path.dart" as path;
import "package:path_provider/path_provider.dart";

final Logger _log = Logger("ObjectBox-Flow");

/// Realistic tags attached to the generated demo transactions. Kept short and
/// recognizable so they look good in screenshots (unlike random dictionary
/// words). Keys here must match the tag keys used by [DemoDataGenerator].
const List<String> _demoTagTitles = [
  "work",
  "subscription",
  "bills",
  "groceries",
  "dining",
  "coffee",
  "vacation",
  "family",
  "friends",
  "online",
  "health",
  "transport",
  "fun",
  "gifts",
  "charity",
  "pets",
  "reimbursable",
  "gadgets",
];

class ObjectBox {
  static ObjectBox? _instance;

  static late String appDataDirectory;

  static const String imagesDirectoryName = "images";
  static const String filesDirectoryName = "files";
  static String get imagesDirectory =>
      path.join(appDataDirectory, imagesDirectoryName);
  static String get filesDirectory =>
      path.join(appDataDirectory, filesDirectoryName);

  static String kDebugDefaultSubdirectory = "__debug";

  /// A subdirectory to store app data.
  ///
  /// This is useful if you want to separate multiple user data or just
  /// differentiate between debug data and production data.
  ///
  /// In debug mode, this is set to "__debug" if unspecified
  static late final String? subdirectory;

  /// A custom directory to store app data.
  ///
  /// By default, it uses [getApplicationSupportDirectory] (from path_provider)
  static late final String? customDirectory;

  /// The Store of this app.
  late final Store store;

  factory ObjectBox() {
    if (_instance == null) {
      _log.severe("You must initialize ObjectBox by calling initialize().");
      throw Exception("You must initialize ObjectBox by calling initialize().");
    }

    return _instance!;
  }

  Box<T> box<T>() => store.box<T>();

  ObjectBox._internal(this.store);

  static Future<ObjectBox> initialize({
    String? customDirectory,
    String? subdirectory,
    Directory? appSupportDirectory,
  }) async {
    if (subdirectory == null && flowDebugMode) {
      subdirectory = kDebugDefaultSubdirectory;
    }

    ObjectBox.subdirectory = subdirectory;
    ObjectBox.customDirectory = customDirectory;

    ObjectBox.appDataDirectory = await _appDataDirectory(
      supportDir: appSupportDirectory,
    );

    final dir = Directory(ObjectBox.appDataDirectory);
    if (!(await dir.exists())) {
      _log.fine("Creating app data directory at ${dir.path}");
      await dir.create(recursive: true);
    }

    late final Store store;

    if (Store.isOpen(appDataDirectory)) {
      _log.fine("Reusing existing ObjectBox store at $appDataDirectory");
      store = Store.attach(getObjectBoxModel(), appDataDirectory);
    } else {
      _log.fine("Opening ObjectBox store at $appDataDirectory");
      store = await openStore(
        directory: appDataDirectory,
        macosApplicationGroup: Platform.isMacOS ? "NJH37247C9.flow" : null,
      );
    }

    return _instance = ObjectBox._internal(store);
  }

  static Future<String> _appDataDirectory({Directory? supportDir}) async {
    if (customDirectory != null) {
      return path.join(customDirectory!, subdirectory);
    }

    final appDataDir = supportDir ?? await getApplicationSupportDirectory();

    return path.join(appDataDir.path, subdirectory);
  }

  /// Seeds a rich, multi-year demo history for screenshots and presentations.
  ///
  /// Creates realistic tags, the preset categories, the preset accounts plus a
  /// credit card, ~3 years of generated transactions, and a few budgets/goals
  /// so every screen looks populated. See [DemoDataGenerator].
  ///
  /// The generated data is **non-deterministic** — each run produces a
  /// different (but plausible) history.
  Future<void> createAndPutDebugData() async {
    if (box<Account>().count(limit: 1) > 0 ||
        box<Category>().count(limit: 1) > 0) {
      return;
    }

    final List<TransactionTag> tags = await box<TransactionTag>()
        .putAndGetManyAsync(
          _demoTagTitles
              .map((title) => TransactionTag(title: title))
              .toList(),
        );
    final Map<String, TransactionTag> tagsByTitle = {
      for (final tag in tags) tag.title: tag,
    };

    final List<Category> categories = await box<Category>()
        .putAndGetManyAsync(
          getCategoryPresets().map((e) {
            e.id = 0;
            return e;
          }).toList(),
        );

    final List<Account> presets = getAccountPresets("USD").map((e) {
      e.id = 0;
      return e;
    }).toList();
    final Account creditCardPreset =
        Account.preset(
          name: "Credit Card",
          currency: "USD",
          iconCode: FlowIconData.icon(Symbols.credit_card_rounded).toString(),
          uuid: "1f3c9d2e-8a47-4b6e-9c21-7d5f0a2b6e41",
          type: AccountType.creditLineValue,
          creditLimit: 5000,
          excludeFromTotalBalance: true,
        )..id = 0;

    final List<Account> accounts = await box<Account>().putAndGetManyAsync([
      ...presets,
      creditCardPreset,
    ]);
    final [main, cash, savings, creditCard] = accounts;

    final DemoDataGenerator generator = DemoDataGenerator(
      main: main,
      cash: cash,
      savings: savings,
      creditCard: creditCard,
      categories: categories,
      tags: tagsByTitle,
    );

    await box<Transaction>().putManyAsync(generator.generate());

    _createDemoBudgetsAndGoals(categories: categories, savings: savings);
  }

  /// Populates the budgets and goals screens with a handful of realistic
  /// entries tied to the demo data.
  void _createDemoBudgetsAndGoals({
    required List<Category> categories,
    required Account savings,
  }) {
    final Map<String, Category> byCode = {
      for (final category in categories) category.iconCode: category,
    };
    Category? cat(IconData icon) => byCode[IconFlowIcon(icon).toString()];

    final String monthlyRange = MonthTimeRange.fromDateTime(
      DateTime.now(),
    ).toString();

    final Budget groceries = Budget(
      name: "Groceries",
      amount: 450,
      currency: "USD",
      range: monthlyRange,
    )..setCategories([?cat(Symbols.grocery_rounded)]);

    final Budget eatingOut = Budget(
      name: "Eating out",
      amount: 300,
      currency: "USD",
      range: monthlyRange,
    )..setCategories([
      ?cat(Symbols.restaurant_rounded),
      ?cat(Symbols.local_cafe_rounded),
      ?cat(Symbols.bakery_dining_rounded),
    ]);

    final Budget shopping = Budget(
      name: "Shopping",
      amount: 400,
      currency: "USD",
      range: monthlyRange,
    )..setCategories([?cat(Symbols.shopping_cart_rounded)]);

    box<Budget>().putMany([groceries, eatingOut, shopping]);

    // One goal already reached, one still in progress — shows both states.
    final Goal emergencyFund = Goal(
      name: "Emergency fund",
      targetBalance: 20000,
      currency: "USD",
      range: null,
      iconCode: FlowIconData.icon(Symbols.savings_rounded).toString(),
    )..setAccount(savings);

    final Goal house = Goal(
      name: "House down payment",
      targetBalance: 90000,
      currency: "USD",
      range: null,
      iconCode: FlowIconData.icon(Symbols.home_rounded).toString(),
    )..setAccount(savings);

    box<Goal>().putMany([emergencyFund, house]);
  }

  /// Deletes everything except for
  ///
  /// * Profile
  /// * BackupEntry
  Future<void> eraseMainData() async {
    _log.severe("Erasing all data, except for Profile and BackupEntry");

    try {
      await Future.wait([
        box<Transaction>().removeAllAsync(),
        box<Category>().removeAllAsync(),
        box<Account>().removeAllAsync(),
        box<Profile>().removeAllAsync(),
        box<UserPreferences>().removeAllAsync(),
        box<Budget>().removeAllAsync(),
        box<Goal>().removeAllAsync(),
        box<TransactionTag>().removeAllAsync(),
        box<FileAttachment>().removeAllAsync(),
        box<RecurringTransaction>().removeAllAsync(),
        box<TransactionFilterPreset>().removeAllAsync(),
      ]);
    } finally {}
  }
}
