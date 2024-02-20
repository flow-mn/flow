import 'dart:io';
import 'dart:math' hide log;

import 'package:flow/constants.dart';
import 'package:flow/data/flow_icon.dart';
import 'package:flow/data/setup/default_accounts.dart';
import 'package:flow/data/setup/default_categories.dart';
import 'package:flow/entity/account.dart';
import 'package:flow/entity/category.dart';
import 'package:flow/entity/transaction.dart';
import 'package:flow/objectbox/actions.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flow/objectbox/objectbox.g.dart';

class ObjectBox {
  static ObjectBox? _instance;

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
      throw Exception(
        "You must initialize ObjectBox by calling initialize().",
      );
    }

    return _instance!;
  }

  Box<T> box<T>() => store.box<T>();

  ObjectBox._internal(this.store);

  static Future<String> _appDataDirectory() async {
    if (customDirectory != null) {
      return path.join(customDirectory!, subdirectory);
    }

    final appDataDir = await getApplicationSupportDirectory();

    return path.join(appDataDir.path, subdirectory);
  }

  static late String appDataDirectory;

  static Future<ObjectBox> initialize({
    String? customDirectory,
    String? subdirectory,
  }) async {
    if (subdirectory == null && flowDebugMode) {
      subdirectory = "__debug";
    }

    ObjectBox.subdirectory = subdirectory;
    ObjectBox.customDirectory = customDirectory;

    ObjectBox.appDataDirectory = await _appDataDirectory();

    final dir = Directory(ObjectBox.appDataDirectory);
    if (!(await dir.exists())) {
      await dir.create(recursive: true);
    }

    final store = await openStore(directory: appDataDirectory);

    return _instance = ObjectBox._internal(store);
  }

  Future<void> populateDummyData() async {
    final Query<Account> firstAccountQuery =
        box<Account>().query(Account_.name.equals("Alpha")).build();

    final Account? firstAccount = firstAccountQuery.findFirst();

    firstAccountQuery.close();

    if (firstAccount != null) {
      await addDummyData();
    } else {
      await _createAndPutDebugData();
    }
  }

  Future<void> _createAndPutDebugData() async {
    if (box<Transaction>().count(limit: 1) > 0) {
      addDummyData();
      return;
    }

    final categories =
        await box<Category>().putAndGetManyAsync(getCategoryPresets().map((e) {
      e.id = 0;
      return e;
    }).toList());

    final services = categories.firstWhere((element) =>
        element.iconCode ==
        const IconFlowIcon(Symbols.cloud_circle_rounded).toString());
    final coffee = categories.firstWhere((element) =>
        element.iconCode ==
        const IconFlowIcon(Symbols.local_cafe_rounded).toString());
    final gift = categories.firstWhere((element) =>
        element.iconCode ==
        const IconFlowIcon(Symbols.featured_seasonal_and_gifts_rounded)
            .toString());
    final paycheck = categories.firstWhere((element) =>
        element.iconCode ==
        const IconFlowIcon(Symbols.wallet_rounded).toString());
    final rent = categories.firstWhere((element) =>
        element.iconCode ==
        const IconFlowIcon(Symbols.request_quote_rounded).toString());

    final [main, cash, savings] = getAccountPresets('USD').map((e) {
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

    final [main2, ..., savings2] =
        await box<Account>().putAndGetManyAsync([main, cash, savings]);

    main2.transferTo(
      amount: 250,
      targetAccount: savings2,
      transactionDate: DateTime.now() - const Duration(days: 1),
    );
  }

  Future<void> addDummyData() async {
    Account account = await box<Account>()
        .getAllAsync()
        .then((value) => value[Random().nextInt(value.length)]);

    Category category = await box<Category>()
        .getAllAsync()
        .then((value) => value[Random().nextInt(value.length)]);

    final ({double min, double max, double multiplier}) randomVal =
        switch (category.name) {
      "Online subscriptions" => (min: 4.0, max: 12.0, multiplier: -1.0),
      "Paycheck" => (min: 30.0, max: 1500.0, multiplier: 1.0),
      "Education" => (min: 25.0, max: 75.0, multiplier: -1.0),
      "Shopping" => (min: 8.0, max: 100.0, multiplier: -1.0),
      "Eating out" => (min: 8.0, max: 128.0, multiplier: -1.0),
      "Coffee & tea" => (min: 6.0, max: 20.0, multiplier: -1.0),
      _ => (min: 4.0, max: 100.0, multiplier: -1.0),
    };

    account.createAndSaveTransaction(
      amount: (Random().nextDouble() * (randomVal.max - randomVal.min) +
              randomVal.min) *
          randomVal.multiplier,
      category: category,
      title: "R_${[
        "turkey",
        "rock",
        "end",
        "hydrant",
        "stove",
        "act",
        "laugh",
        "team",
        "zebra",
        "rose",
        "nose",
        "friends",
        "channel",
        "tree",
        "root",
        "increase",
        "trousers",
        "school",
        "tin",
        "egg",
        "fact",
        "cherry",
        "laborer",
        "hall",
        "chance",
        "addition",
        "request",
        "wrist",
        "pipe",
        "war",
        "size",
        "rice",
        "stem",
        "toad",
        "twig",
        "event",
        "silver",
        "rings",
        "grass",
        "development",
        "hill",
        "pickle",
        "carpenter",
        "view",
        "cave",
        "test",
        "hose",
        "education",
        "worm",
        "trouble",
        "cap",
        "quilt",
        "lumber",
        "baby",
        "hour",
        "sack",
        "quiet",
        "chin",
        "thread",
        "servant",
        "animal",
        "song",
        "babies",
        "walk",
        "woman",
        "gold",
        "soap",
        "lake",
        "spot",
        "example",
        "rest",
        "glass",
        "minute",
        "hand",
        "thrill",
        "reason",
        "pocket",
        "thumb",
        "road",
        "ticket",
        "lock",
        "magic",
        "collar",
        "middle",
        "grandmother",
        "nerve",
        "passenger",
        "basketball",
        "bridge",
        "veil",
        "bikes",
        "friend",
        "hope",
        "coal",
        "duck",
        "edge",
        "flame",
        "page",
        "grape",
        "smoke"
      ][Random().nextInt(100)]}",
    );
  }

  /// Deletes everything except for
  ///
  /// * Profile
  /// * BackupEntry
  Future<void> eraseMainData() async {
    final Query<Transaction> allTransactionsQuery =
        box<Transaction>().query().build();
    final Query<Category> allCategorysQuery = box<Category>().query().build();
    final Query<Account> allAccountsQuery = box<Account>().query().build();

    try {
      await Future.wait([
        allTransactionsQuery.removeAsync(),
        allCategorysQuery.removeAsync(),
        allAccountsQuery.removeAsync(),
      ]);
    } finally {
      allTransactionsQuery.close();
      allCategorysQuery.close();
      allAccountsQuery.close();
    }
  }
}
