import "dart:io";

import "package:flow/constants.dart";
import "package:flow/data/flow_icon.dart";
import "package:flow/data/setup/default_accounts.dart";
import "package:flow/data/setup/default_categories.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/budget.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/profile.dart";
import "package:flow/entity/recurring_transaction.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction_filter_preset.dart";
import "package:flow/entity/user_preferences.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:logging/logging.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";
import "package:path/path.dart" as path;
import "package:path_provider/path_provider.dart";

final Logger _log = Logger("ObjectBox-Flow");

class ObjectBox {
  static ObjectBox? _instance;

  static late String appDataDirectory;

  static String get imagesDirectory => path.join(appDataDirectory, "images");

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
  }) async {
    if (subdirectory == null && flowDebugMode) {
      subdirectory = kDebugDefaultSubdirectory;
    }

    ObjectBox.subdirectory = subdirectory;
    ObjectBox.customDirectory = customDirectory;

    ObjectBox.appDataDirectory = await _appDataDirectory();

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

  static Future<String> _appDataDirectory() async {
    if (customDirectory != null) {
      return path.join(customDirectory!, subdirectory);
    }

    final appDataDir = await getApplicationSupportDirectory();

    return path.join(appDataDir.path, subdirectory);
  }

  Future<void> createAndPutDebugData() async {
    if (box<Account>().count(limit: 1) > 0 ||
        box<Category>().count(limit: 1) > 0) {
      return;
    }

    final categories = await box<Category>().putAndGetManyAsync(
      getCategoryPresets().map((e) {
        e.id = 0;
        return e;
      }).toList(),
    );

    final services = categories.firstWhere(
      (element) =>
          element.iconCode ==
          const IconFlowIcon(Symbols.cloud_circle_rounded).toString(),
    );
    final coffee = categories.firstWhere(
      (element) =>
          element.iconCode ==
          const IconFlowIcon(Symbols.local_cafe_rounded).toString(),
    );
    final gift = categories.firstWhere(
      (element) =>
          element.iconCode ==
          const IconFlowIcon(
            Symbols.featured_seasonal_and_gifts_rounded,
          ).toString(),
    );
    final paycheck = categories.firstWhere(
      (element) =>
          element.iconCode ==
          const IconFlowIcon(Symbols.wallet_rounded).toString(),
    );
    final rent = categories.firstWhere(
      (element) =>
          element.iconCode ==
          const IconFlowIcon(Symbols.request_quote_rounded).toString(),
    );

    final [main, cash, savings] =
        getAccountPresets("USD").map((e) {
          e.id = 0;
          return e;
        }).toList();

    main
      ..updateBalanceAndSave(
        420.69,
        title: "Initial balance",
        transactionDate: DateTime.now() - const Duration(days: 5),
      )
      ..createAndSaveTransaction(
        amount: -1.99,
        title: "iCloud",
        category: services,
        transactionDate: DateTime.now() - const Duration(days: 4),
      )
      ..createAndSaveTransaction(
        amount: -15.49,
        title: "Netflix",
        category: services,
        transactionDate: DateTime.now() - const Duration(days: 4),
      )
      ..createAndSaveTransaction(
        amount: -6.50,
        title: "Iced Mocha",
        category: coffee,
        transactionDate: DateTime.now() - const Duration(days: 4),
      )
      ..createAndSaveTransaction(
        amount: -6.50,
        title: "Iced Mocha",
        category: coffee,
        transactionDate: DateTime.now() - const Duration(days: 3),
      )
      ..createAndSaveTransaction(
        amount: -6.50,
        title: "Iced Mocha",
        category: coffee,
        transactionDate: DateTime.now() - const Duration(days: 2),
      )
      ..createAndSaveTransaction(
        amount: 680.98,
        title: "Paycheck (last month)",
        category: paycheck,
        transactionDate: DateTime.now() - const Duration(days: 1),
      )
      ..createAndSaveTransaction(
        amount: -99.01,
        title: "Gift for Stella",
        category: gift,
        transactionDate: DateTime.now() - const Duration(days: 1),
      );

    savings
      ..updateBalanceAndSave(
        69420,
        title: "Savings initial balance",
        transactionDate: DateTime.now() - const Duration(days: 6),
      )
      ..createAndSaveTransaction(
        amount: -1960,
        title: "Rent",
        category: rent,
        transactionDate: DateTime.now() - const Duration(days: 6),
      );

    final [main2, ..., savings2] = await box<Account>().putAndGetManyAsync([
      main,
      cash,
      savings,
    ]);

    main2.transferTo(
      amount: 250,
      targetAccount: savings2,
      transactionDate: DateTime.now() - const Duration(days: 1),
    );
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
        box<RecurringTransaction>().removeAllAsync(),
        box<TransactionFilterPreset>().removeAllAsync(),
      ]);
    } finally {}
  }
}
