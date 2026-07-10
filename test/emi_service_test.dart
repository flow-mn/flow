import "dart:io";

import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/emi.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/services/emi.dart";
import "package:flutter_test/flutter_test.dart";
import "package:path/path.dart" as path;
import "objectbox_erase.dart";

void main() {
  group("EmiService tests", () {
    late Account testAccount;
    late Category testCategory;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();

      await ObjectBox.initialize(
        customDirectory: objectboxTestRootDir().path,
        subdirectory: "emi_tests",
      );

      // Create test account
      testAccount = Account(
        name: "Test Bank",
        currency: "USD",
        iconCode: "icon",
      );
      testAccount.id = ObjectBox().box<Account>().put(testAccount);

      // Create test category
      testCategory = Category(
        name: "Shopping",
        iconCode: "shopping_bag",
        colorSchemeName: "Green",
      );
      testCategory.id = ObjectBox().box<Category>().put(testCategory);
    });

    tearDownAll(() async {
      await testCleanupObject(
        instance: ObjectBox(),
        directory: ObjectBox.appDataDirectory,
        cleanUp: true,
      );
    });

    test("Create and Pay EMI tracker flow", () async {
      // 1. Create Emi record
      final emi = Emi(
        title: "MacBook Financing",
        totalAmount: 1200.0,
        installmentAmount: 100.0,
        totalInstallments: 12,
        remainingInstallments: 12,
        remainingAmount: 1200.0,
        startDate: DateTime(2026, 1, 1),
        nextDueDate: DateTime(2026, 1, 1),
      );
      emi.account.target = testAccount;
      emi.category.target = testCategory;

      final emiId = await EmiService().upsertOne(emi);
      expect(emiId, greaterThan(0));

      // Retrieve and verify
      final createdEmi = EmiService().getOneSync(emiId)!;
      expect(createdEmi.title, equals("MacBook Financing"));
      expect(createdEmi.totalAmount, equals(1200.0));
      expect(createdEmi.paidInstallments, equals(0));
      expect(createdEmi.status, equals("active"));

      // 2. Pay first installment
      await EmiService().payInstallment(createdEmi);

      final updatedEmi1 = EmiService().getOneSync(emiId)!;
      expect(updatedEmi1.paidInstallments, equals(1));
      expect(updatedEmi1.remainingInstallments, equals(11));
      expect(updatedEmi1.paidAmount, equals(100.0));
      expect(updatedEmi1.remainingAmount, equals(1100.0));
      expect(updatedEmi1.status, equals("active"));
      expect(updatedEmi1.nextDueDate, equals(DateTime(2026, 2, 1)));

      // Verify transaction was created
      final query = ObjectBox()
          .box<Transaction>()
          .query(Transaction_.extra.contains(createdEmi.uuid))
          .build();
      final transactions = query.find();
      query.close();

      expect(transactions.length, equals(1));
      final tx = transactions.first;
      expect(tx.title, equals("MacBook Financing (1/12)"));
      expect(tx.amount, equals(-100.0)); // Expenses are negative
      expect(tx.account.target?.id, equals(testAccount.id));
      expect(tx.category.target?.id, equals(testCategory.id));
      expect(tx.extensions.emi?.emiUuid, equals(createdEmi.uuid));

      // 3. Pay all remaining installments to verify completion
      for (int i = 2; i <= 12; i++) {
        await EmiService().payInstallment(updatedEmi1);
      }

      final completedEmi = EmiService().getOneSync(emiId)!;
      expect(completedEmi.paidInstallments, equals(12));
      expect(completedEmi.remainingInstallments, equals(0));
      expect(completedEmi.paidAmount, equals(1200.0));
      expect(completedEmi.remainingAmount, equals(0.0));
      expect(completedEmi.status, equals("completed"));
      expect(completedEmi.nextDueDate, isNull);

      final queryAll = ObjectBox()
          .box<Transaction>()
          .query(Transaction_.extra.contains(createdEmi.uuid))
          .build();
      final allTransactions = queryAll.find();
      queryAll.close();
      expect(allTransactions.length, equals(12));

      // 4. Delete EMI tracking record
      await EmiService().deleteOne(emiId);
      final deletedEmi = EmiService().getOneSync(emiId);
      expect(deletedEmi, isNull);

      // Verify that transactions remain unchanged (only tracking is deleted)
      final queryAfterDelete = ObjectBox()
          .box<Transaction>()
          .query(Transaction_.extra.contains(createdEmi.uuid))
          .build();
      final postDeleteTransactions = queryAfterDelete.find();
      queryAfterDelete.close();
      expect(postDeleteTransactions.length, equals(12));
    });
  });
}

Directory objectboxTestRootDir() {
  return Directory(path.join(Directory.current.path, ".objectbox_test"));
}
