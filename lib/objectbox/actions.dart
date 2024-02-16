import 'dart:developer';

import 'package:flow/data/prefs/frecency_group.dart';
import 'package:flow/entity/account.dart';
import 'package:flow/entity/category.dart';
import 'package:flow/entity/transaction.dart';
import 'package:flow/entity/transaction/extensions/base.dart';
import 'package:flow/entity/transaction/extensions/default/transfer.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/objectbox.g.dart';
import 'package:flow/prefs.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:uuid/uuid.dart';

extension MainActions on ObjectBox {
  List<Account> getAccounts([bool sortByFrecency = true]) {
    final List<Account> accounts = box<Account>().getAll();

    if (sortByFrecency) {
      final FrecencyGroup frecencyGroup = FrecencyGroup(accounts
          .map((account) =>
              LocalPreferences().getFrecencyData("account", account.uuid))
          .nonNulls
          .toList());

      accounts.sort((a, b) => frecencyGroup
          .getScore(b.uuid)
          .compareTo(frecencyGroup.getScore(a.uuid)));
    }

    return accounts;
  }

  List<Category> getCategories([bool sortByFrecency = true]) {
    final List<Category> categories = box<Category>().getAll();

    if (sortByFrecency) {
      final FrecencyGroup frecencyGroup = FrecencyGroup(categories
          .map((category) =>
              LocalPreferences().getFrecencyData("category", category.uuid))
          .nonNulls
          .toList());

      categories.sort((a, b) => frecencyGroup
          .getScore(b.uuid)
          .compareTo(frecencyGroup.getScore(a.uuid)));
    }

    return categories;
  }
}

extension TransactionActions on Transaction {
  Transaction? findTransferOriginalOrThis() {
    if (!isTransfer) return this;

    final Transfer transfer = extensions.transfer!;

    if (amount.isNegative) return this;

    final Query<Transaction> query = ObjectBox()
        .box<Transaction>()
        .query(Transaction_.uuid.equals(transfer.relatedTransactionUuid))
        .build();

    try {
      return query.findFirst();
    } catch (e) {
      return this;
    } finally {
      query.close();
    }
  }

  bool delete() {
    if (isTransfer) {
      final Transfer? transfer = extensions.transfer;

      if (transfer == null) {
        log("Couldn't delete transfer transaction properly due to missing transfer data");
      } else {
        final Query<Transaction> relatedTransactionQuery = ObjectBox()
            .box<Transaction>()
            .query(Transaction_.uuid.equals(transfer.relatedTransactionUuid))
            .build();

        final Transaction? relatedTransaction =
            relatedTransactionQuery.findFirst();

        relatedTransactionQuery.close();

        try {
          final bool removedRelated = ObjectBox()
              .box<Transaction>()
              .remove(relatedTransaction?.id ?? -1);

          if (!removedRelated) {
            throw Exception("Failed to remove related transaction");
          }
        } catch (e) {
          log("Couldn't delete transfer transaction properly due to: $e");
        }
      }
    }

    return ObjectBox().box<Transaction>().remove(id);
  }
}

extension TransactionListActions on List<Transaction> {
  double get incomeSum => where((transaction) => transaction.amount >= 0)
      .map((transaction) => transaction.amount)
      .fold(0, (value, element) => value + element);
  double get expenseSum => where((transaction) => transaction.amount < 0)
      .map((transaction) => transaction.amount)
      .fold(0, (value, element) => value + element);
  double get sum =>
      map((transaction) => transaction.amount).fold(0, (a, b) => a + b);

  Map<DateTime, List<Transaction>> groupByDate() {
    final Map<DateTime, List<Transaction>> value = {};

    int? lastTransferIndex;
    Transaction? lastTransferFrom;

    for (final (index, transaction) in indexed) {
      final date = transaction.transactionDate.toLocal().startOfDay();

      if (LocalPreferences().combineTransferTransactions.get() &&
          transaction.isTransfer) {
        if (lastTransferIndex == null) {
          lastTransferIndex = index;
          lastTransferFrom = transaction;
          continue;
        }

        value[date] ??= [];
        value[date]!.add(
          lastTransferFrom!
            ..title ??= "transaction.transfer.fromToTitle".tr(
              {
                "from": lastTransferFrom.account.target!.name,
                "to": transaction.account.target!.name
              },
            ),
        );

        lastTransferIndex = null;
        lastTransferFrom = null;
        continue;
      }

      value[date] ??= [];
      value[date]!.add(transaction);
    }

    return value;
  }
}

extension AccountActions on Account {
  /// I'm super sleepy and practically a zombie r.n.
  ///
  /// This is probably better of as Singleton somewhere with memoization as
  /// account names won't get changed that frequently (I hope)
  ///
  /// TODO
  static String nameByUuid(String uuid) {
    final query =
        ObjectBox().box<Account>().query(Account_.uuid.equals(uuid)).build();

    try {
      return query.findFirst()?.name ?? "???";
    } catch (e) {
      return "???";
    } finally {
      query.close();
    }
  }

  void updateBalance(double targetBalance, {String? title}) {
    final double delta = targetBalance - balance;

    transactions.add(
      Transaction(
        amount: delta,
        title: title,
        currency: currency,
      ),
    );

    ObjectBox().box<Account>().put(this);
  }

  /// Returns object ids from `box.put`
  ///
  /// First transaction represents money going out of [this] account
  ///
  /// Second transaction represents money incoming to the target account
  (int from, int to) transferTo({
    String? title,
    required Account targetAccount,
    required double amount,
    DateTime? createdDate,
    DateTime? transactionDate,
  }) {
    if (amount <= 0) {
      return targetAccount.transferTo(
        targetAccount: this,
        amount: amount.abs(),
        title: title,
        createdDate: createdDate,
        transactionDate: transactionDate,
      );
    }

    final String fromTransactionUuid = const Uuid().v4();
    final String toTransactionUuid = const Uuid().v4();

    final Transfer transferData = Transfer(
      uuid: const Uuid().v4(),
      fromAccountUuid: uuid,
      toAccountUuid: targetAccount.uuid,
      relatedTransactionUuid: toTransactionUuid,
    );

    final String resolvedTitle = title ??
        "transaction.transfer.fromToTitle"
            .tr({"from": name, "to": targetAccount.name});

    final int fromTransaction = createTransaction(
      amount: -amount,
      title: resolvedTitle,
      extensions: [transferData],
      uuidOverride: fromTransactionUuid,
      createdDate: createdDate,
      transactionDate: transactionDate,
    );
    final int toTransaction = targetAccount.createTransaction(
      amount: amount,
      title: resolvedTitle,
      extensions: [
        transferData.copyWith(relatedTransactionUuid: fromTransactionUuid)
      ],
      uuidOverride: toTransactionUuid,
      createdDate: createdDate,
      transactionDate: transactionDate,
    );

    return (fromTransaction, toTransaction);
  }

  /// Returns object id
  ///
  /// (From box.put())
  int createTransaction({
    required double amount,
    DateTime? transactionDate,
    DateTime? createdDate,
    String? title,
    Category? category,
    List<TransactionExtension>? extensions,
    String? uuidOverride,
  }) {
    Transaction value = Transaction(
      amount: amount,
      currency: currency,
      title: title,
      transactionDate: transactionDate,
      createdDate: createdDate,
      uuidOverride: uuidOverride,
    )..setCategory(category);

    LocalPreferences().updateFrecencyData("account", uuid);
    if (category != null) {
      LocalPreferences().updateFrecencyData("category", category.uuid);
    }

    if (extensions != null && extensions.isNotEmpty) {
      value.addExtensions(extensions);
    }

    transactions.add(value);
    return ObjectBox().box<Account>().put(this);
  }
}
