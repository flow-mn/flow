import 'dart:math';

import 'package:flow/data/flow_icon.dart';
import 'package:flow/entity/account.dart';
import 'package:flow/entity/category.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/actions.dart';
import 'package:flow/objectbox/objectbox.g.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:moment_dart/moment_dart.dart';

Future<void> populateDummyData([int entryCount = 100]) async {
  final Query<Account> firstAccountQuery =
      ObjectBox().box<Account>().query(Account_.name.equals("Alpha")).build();

  final firstAccount = firstAccountQuery.findFirst();

  firstAccountQuery.close();

  if (firstAccount != null) {
    await addDummyData();
    return;
  }

  await _createAndPutDebugData();
  for (int i = 0; i < entryCount; i++) {
    await addDummyData();
  }
}

Future<void> _createAndPutDebugData() async {
  Category categoryServices = Category(
    iconCode: const IconFlowIcon(Symbols.electrical_services).toString(),
    name: "Online subscriptions",
  );
  Category categoryPaychecks = Category(
    iconCode: const IconFlowIcon(Symbols.payments_rounded).toString(),
    name: "Paycheck",
  );
  Category categoryEducation = Category(
    iconCode: const IconFlowIcon(Symbols.school_rounded).toString(),
    name: "Education",
  );
  Category categoryShopping = Category(
    iconCode: const IconFlowIcon(Symbols.shopping_bag_rounded).toString(),
    name: "Shopping",
  );
  Category categoryEatOut = Category(
    iconCode: const IconFlowIcon(Symbols.restaurant_rounded).toString(),
    name: "Eating out",
  );
  Category categoryBeverages = Category(
    iconCode: const IconFlowIcon(Symbols.coffee_rounded).toString(),
    name: "Coffee & tea",
  );

  ObjectBox().box<Category>().putMany([
    categoryServices,
    categoryPaychecks,
    categoryEducation,
    categoryShopping,
    categoryEatOut,
    categoryBeverages,
  ]);

  Account accountAlpha = Account(
    name: "Alpha",
    currency: "MNT",
    iconCode: const IconFlowIcon(Symbols.variables_rounded).toString(),
  )
    ..updateBalanceAndSave(
      384500,
      title: "Balance Nov 2023",
    )
    ..createAndSaveTransaction(
      amount: -5241,
      title: "iCould",
      category: categoryServices,
      transactionDate: DateTime.now() - const Duration(days: 7),
    )
    ..createAndSaveTransaction(
      amount: -27500,
      title: "Netflix",
      category: categoryServices,
      transactionDate: DateTime.now() - const Duration(days: 4),
    )
    ..createAndSaveTransaction(
      amount: 20000,
      title: "Translation work pay",
      category: categoryPaychecks,
      transactionDate: DateTime.now() - const Duration(days: 4),
    );

  Account accountBeta = Account(
    name: "Beta",
    currency: "MNT",
    iconCode: const IconFlowIcon(Symbols.bento_rounded).toString(),
  )
    ..updateBalanceAndSave(36850000, title: "Savings starting balance")
    ..createAndSaveTransaction(
      amount: -3875000,
      title: "Tuition for Fall",
      category: categoryEducation,
      transactionDate: DateTime.now() - const Duration(days: 21),
    )
    ..createAndSaveTransaction(
      amount: -12690000,
      title: "Macbook pro",
      category: categoryShopping,
      transactionDate: DateTime.now() - const Duration(days: 21),
    )
    ..createAndSaveTransaction(
      amount: 512000,
      title: "Salary portion",
      category: categoryPaychecks,
      transactionDate: DateTime.now() - const Duration(days: 21),
    );

  await ObjectBox().box<Account>().putManyAsync([accountAlpha, accountBeta]);
}

Future<void> addDummyData() async {
  Account account = await ObjectBox()
      .box<Account>()
      .getAllAsync()
      .then((value) => value[Random().nextInt(value.length)]);

  Category category = await ObjectBox()
      .box<Category>()
      .getAllAsync()
      .then((value) => value[Random().nextInt(value.length)]);

  final ({double min, double max, double multiplier}) randomVal =
      switch (category.name) {
    "Online subscriptions" => (min: 4.0, max: 12.0, multiplier: -3500.0),
    "Paycheck" => (min: 30.0, max: 1500.0, multiplier: 3500.0),
    "Education" => (min: 25.0, max: 75.0, multiplier: -3500.0),
    "Shopping" => (min: 8.0, max: 100.0, multiplier: -3500.0),
    "Eating out" => (min: 8.0, max: 128.0, multiplier: -3500.0),
    "Coffee & tea" => (min: 6.0, max: 20.0, multiplier: -3500.0),
    _ => (min: 4.0, max: 100.0, multiplier: -3500.0),
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
