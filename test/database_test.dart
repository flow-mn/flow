import "dart:io";

import "package:flow/data/money.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/services/transactions.dart";
import "package:flutter_test/flutter_test.dart";

import "package:path/path.dart" as path;

import "objectbox_erase.dart";

void main() {
  group("ObjectBox data insertion", () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();

      await ObjectBox.initialize(
        customDirectory: objectboxTestRootDir().path,
        subdirectory: "main",
      );

      await ObjectBox().box<Account>().putManyAsync([
        Account(
          name: "Tugrik",
          currency: "MNT",
          iconCode: "@@@@@irrelevant_here@@@@@",
        ),
        Account(
          name: "Dollars US",
          currency: "USD",
          iconCode: "@@@@@irrelevant_here@@@@@",
        ),
        Account(
          name: "Tugrik Account 2",
          currency: "MNT",
          iconCode: "@@@@@irrelevant_here@@@@@",
        ),
      ]);

      final Query<Account> tugrikAccountQuery = ObjectBox()
          .box<Account>()
          .query(Account_.name.equals("Tugrik"))
          .build();

      try {
        final Account accMNT = (await tugrikAccountQuery.findFirstAsync())!;
        accMNT.createAndSaveTransaction(amount: 420.69, title: "t1");
      } finally {
        tugrikAccountQuery.close();
      }
    });

    test("Adding account with duplicate name should fail", () async {
      final Query<Account> accountQuery =
          ObjectBox().box<Account>().query().build();

      late final String firstAccountName;

      try {
        firstAccountName = (await accountQuery.findFirstAsync())!.name;
      } finally {
        accountQuery.close();
      }

      expect(
        () async => await ObjectBox().box<Account>().putAsync(
              Account(
                name: firstAccountName,
                currency: "MNT",
                iconCode: "iconCode",
              ),
            ),
        throwsA(isA<UniqueViolationException>()),
      );
    });

    test("Changing transaction account to different currency should fail",
        () async {
      final Query<Account> mntAccountQuery = ObjectBox()
          .box<Account>()
          .query(Account_.currency.equals("MNT"))
          .build();
      final Query<Account> usdAccountQuery = ObjectBox()
          .box<Account>()
          .query(Account_.currency.equals("USD"))
          .build();

      final Account? mntAccount = await mntAccountQuery.findFirstAsync();
      final Account? usdAccount = await usdAccountQuery.findFirstAsync();

      mntAccountQuery.close();
      usdAccountQuery.close();

      final txnId = mntAccount!.createAndSaveTransaction(
        amount: 216363.53,
        title: "Impossible intercurrency transaction",
      );

      final txn = await ObjectBox().box<Transaction>().getAsync(txnId);

      expect(() => txn!.setAccount(usdAccount), throwsException);
    });

    test("Creating an income should increase account balance", () async {
      final Query<Account> accountQuery =
          ObjectBox().box<Account>().query().build();

      late Account account;

      account = (await accountQuery.findFirstAsync())!;

      final Money initialBalance = account.balance;

      final int txnId = account.createAndSaveTransaction(
        amount: 1000.0,
        title: "Income",
      );

      try {
        account = (await accountQuery.findFirstAsync())!;
      } finally {
        accountQuery.close();
      }

      expect(
        account.balance,
        equals(
          initialBalance + Money(1000.0, initialBalance.currency),
        ),
      );

      final Transaction txn = (await TransactionsService().getOne(txnId))!;

      expect(txn.amount, equals(1000.0));
      expect(txn.type, equals(TransactionType.income));
      expect(txn.uuid, isNotNull);
    });

    test("Creating an expense should decrease account balance", () async {
      final Query<Account> accountQuery =
          ObjectBox().box<Account>().query().build();

      late Account account;

      account = (await accountQuery.findFirstAsync())!;

      final Money initialBalance = account.balance;

      final int txnId = account.createAndSaveTransaction(
        amount: -1000.0,
        title: "Expense",
      );

      try {
        account = (await accountQuery.findFirstAsync())!;
      } finally {
        accountQuery.close();
      }

      expect(
        account.balance,
        equals(
          initialBalance - Money(1000.0, initialBalance.currency),
        ),
      );

      final Transaction txn = (await TransactionsService().getOne(txnId))!;

      expect(txn.amount, equals(-1000.0));
      expect(txn.type, equals(TransactionType.expense));
      expect(txn.uuid, isNotNull);
    });

    test(
      "Creating a transfer should move money from one account to another",
      () async {
        final Query<Account> accountQuery = ObjectBox()
            .box<Account>()
            .query(Account_.currency.equals("MNT"))
            .build();

        late Account mntAccount1;
        late Account mntAccount2;

        final mntAccounts = await accountQuery.findAsync();

        mntAccount1 = mntAccounts[0];
        mntAccount2 = mntAccounts[1];

        final Money initialBalanceAccount1 = mntAccount1.balance;
        final Money initialBalanceAccount2 = mntAccount2.balance;

        final (fromTxnId, toTxnId) =
            mntAccount1.transferTo(targetAccount: mntAccount2, amount: 1000.0);

        final Transaction? fromTxn =
            await TransactionsService().getOne(fromTxnId);
        final Transaction? toTxn = await TransactionsService().getOne(toTxnId);

        expect(fromTxn!.amount, equals(-1000.0));
        expect(fromTxn.type, equals(TransactionType.transfer));
        expect(fromTxn.uuid, isNotNull);

        expect(toTxn!.amount, equals(1000.0));
        expect(toTxn.type, equals(TransactionType.transfer));
        expect(toTxn.uuid, isNotNull);

        expect(toTxn.amount, equals(-fromTxn.amount));

        final mntAccountsUpdated = await accountQuery.findAsync();
        accountQuery.close();

        mntAccount1 = mntAccountsUpdated[0];
        mntAccount2 = mntAccountsUpdated[1];

        expect(
          mntAccount1.balance,
          equals(
            initialBalanceAccount1 - Money(1000, "MNT"),
          ),
        );
        expect(
          mntAccount2.balance,
          equals(
            initialBalanceAccount2 + Money(1000, "MNT"),
          ),
        );
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

Directory objectboxTestRootDir() {
  return Directory(path.join(Directory.current.path, ".objectbox_test"));
}
