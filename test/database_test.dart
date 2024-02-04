import 'dart:io';

import 'package:flow/entity/account.dart';
import 'package:flow/entity/transaction.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/objectbox.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group("ObjectBox data insertion", () {
    setUpAll(() async {
      await ObjectBox.initialize(
        customDirectory:
            await objectboxTestRootDir().then((value) => value.path),
        subdirectory: "main",
      );

      await ObjectBox().box<Account>().putManyAsync([
        Account(
          name: "Tugrik",
          currency: "MNT",
          iconCode: '@@@@@irrelevant_here@@@@@',
        ),
        Account(
          name: "Dollars US",
          currency: "USD",
          iconCode: '@@@@@irrelevant_here@@@@@',
        ),
        Account(
          name: "Tugrik Account 2",
          currency: "MNT",
          iconCode: '@@@@@irrelevant_here@@@@@',
        ),
      ]);

      final Account accMNT = (await ObjectBox()
          .box<Account>()
          .query(Account_.name.equals("Tugrik"))
          .build()
          .findFirstAsync())!;

      accMNT.createTransaction(amount: 420.69, title: "t1");
    });

    test("Adding account with duplicate name should fail", () async {
      final firstAccountName =
          (await ObjectBox().box<Account>().query().build().findFirstAsync())!
              .name;

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
      final mntAccount = await ObjectBox()
          .box<Account>()
          .query(Account_.currency.equals("MNT"))
          .build()
          .findFirstAsync();
      final usdAccount = await ObjectBox()
          .box<Account>()
          .query(Account_.currency.equals("USD"))
          .build()
          .findFirstAsync();

      final txnId = mntAccount!.createTransaction(
        amount: 216363.53,
        title: "Impossible intercurrency transaction",
      );

      final txn = await ObjectBox().box<Transaction>().getAsync(txnId);

      expect(() => txn!.setAccount(usdAccount), throwsException);
    });

    tearDownAll(() async {
      await ObjectBox().eraseAllData();
      // ignore: avoid_print
      print(
        "[Flow] Deleting directory used for testing: ${ObjectBox.customDirectory}",
      );
      await Directory(ObjectBox.customDirectory!).delete();
    });
  });
}

Future<Directory> objectboxTestRootDir() async {
  return await Directory.systemTemp.createTemp("__objectbox_test__");
}
