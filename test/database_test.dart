import "dart:io";

import "package:flow/entity/account.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/objectbox/objectbox.g.dart";
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
