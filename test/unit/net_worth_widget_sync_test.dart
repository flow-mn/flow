import "dart:io";

import "package:flow/entity/account.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/services/net_worth_widget_sync.dart";
import "package:flutter_test/flutter_test.dart";
import "package:path/path.dart" as path;
import "package:uuid/uuid.dart";

import "../objectbox_erase.dart";

/// The widget's 30-day history rolls recent transactions back from the
/// current balance instead of summing the whole history per day, so it must
/// agree with [Account.balanceAt] at every anchor.
void main() {
  late ObjectBox obx;

  final String directory = path.join(
    Directory.current.path,
    ".objectbox_test_net_worth_widget",
  );

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    obx = await ObjectBox.initialize(
      customDirectory: directory,
      subdirectory: "net_worth_widget",
    );
  });

  tearDownAll(() async {
    await testCleanupObject(
      instance: obx,
      directory: path.join(directory, "net_worth_widget"),
    );
  });

  setUp(() {
    obx.box<Transaction>().removeAll();
    obx.box<Account>().removeAll();
  });

  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final List<DateTime> anchors = [
    for (int i = 29; i >= 1; i--)
      DateTime(today.year, today.month, today.day - i),
    now,
  ];

  void add(
    Account account,
    double amount,
    DateTime on, {
    bool pending = false,
    bool deleted = false,
  }) {
    final Transaction transaction = Transaction(
      amount: amount,
      currency: account.currency,
      uuid: const Uuid().v4(),
      transactionDate: on,
    )..isPending = pending;
    transaction.isDeleted = deleted;
    transaction.account.target = account;
    obx.box<Transaction>().put(transaction);
  }

  test("matches balanceAt at every anchor", () {
    final Account account = Account(
      name: "Checking",
      currency: "USD",
      iconCode: "",
    );
    obx.box<Account>().put(account);

    add(account, 1000, today.subtract(const Duration(days: 90)));
    add(account, -40, anchors.first);
    add(account, 250, anchors[5].add(const Duration(hours: 3)));
    add(account, -75.5, anchors[12]);
    add(account, -20, anchors[20].add(const Duration(minutes: 1)));
    add(account, 999, anchors[25], pending: true);
    add(account, -999, anchors[26], deleted: true);
    add(account, 500, now.add(const Duration(days: 3)));

    final List<double> rolled = NetWorthWidgetSync.balancesAt(account, anchors);

    expect(rolled, [
      for (final DateTime anchor in anchors) account.balanceAt(anchor).amount,
    ]);
  });
}
