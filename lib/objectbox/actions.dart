import 'dart:developer';
import 'dart:math' as math;

import 'package:flow/data/flow_analytics.dart';
import 'package:flow/data/memo.dart';
import 'package:flow/data/money_flow.dart';
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
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:uuid/uuid.dart';

typedef RelevanceScoredTitle = ({String title, double relevancy});

extension MainActions on ObjectBox {
  double getTotalBalance() {
    final Query<Account> accountsQuery = box<Account>()
        .query(Account_.excludeFromTotalBalance.equals(false))
        .build();

    final List<Account> accounts = accountsQuery.find();

    return accounts
        .map((e) => e.balance)
        .fold(0, (previousValue, element) => previousValue + element);
  }

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

  Future<void> updateAccountOrderList({
    List<Account>? accounts,
    bool ignoreIfNoUnsetValue = false,
  }) async {
    accounts ??= await ObjectBox().box<Account>().getAllAsync();

    if (ignoreIfNoUnsetValue &&
        !accounts.any((element) => element.sortOrder < 0)) {
      return;
    }

    for (final e in accounts.indexed) {
      accounts[e.$1].sortOrder = e.$1;
    }

    await ObjectBox().box<Account>().putManyAsync(accounts);
  }

  /// Returns a map of category uuid -> [MoneyFlow]
  Future<FlowAnalytics<Category>> flowByCategories({
    required DateTime from,
    required DateTime to,
    bool ignoreTransfers = true,
    bool omitZeroes = true,
  }) async {
    final Condition<Transaction> dateFilter =
        Transaction_.transactionDate.betweenDate(from, to);

    final Query<Transaction> transactionsQuery =
        ObjectBox().box<Transaction>().query(dateFilter).build();

    final List<Transaction> transactions = await transactionsQuery.findAsync();

    transactionsQuery.close();

    final Map<String, MoneyFlow<Category>> flow = {};

    for (final transaction in transactions) {
      if (ignoreTransfers && transaction.isTransfer) continue;

      final String categoryUuid =
          transaction.category.target?.uuid ?? Uuid.NAMESPACE_NIL;

      flow[categoryUuid] ??=
          MoneyFlow(associatedData: transaction.category.target);
      flow[categoryUuid]!.add(transaction.amount);
    }

    if (omitZeroes) {
      flow.removeWhere((key, value) => value.isEmpty);
    }

    return FlowAnalytics(flow: flow, from: from, to: to);
  }

  /// Returns a map of category uuid -> [MoneyFlow]
  Future<FlowAnalytics<Account>> flowByAccounts({
    required DateTime from,
    required DateTime to,
    bool ignoreTransfers = true,
    bool omitZeroes = true,
  }) async {
    final Condition<Transaction> dateFilter =
        Transaction_.transactionDate.betweenDate(from, to);

    final Query<Transaction> transactionsQuery =
        ObjectBox().box<Transaction>().query(dateFilter).build();

    final List<Transaction> transactions = await transactionsQuery.findAsync();

    transactionsQuery.close();

    final Map<String, MoneyFlow<Account>> flow = {};

    for (final transaction in transactions) {
      if (ignoreTransfers && transaction.isTransfer) continue;

      final String accountUuid =
          transaction.account.target?.uuid ?? Uuid.NAMESPACE_NIL;

      flow[accountUuid] ??=
          MoneyFlow(associatedData: transaction.account.target);
      flow[accountUuid]!.add(transaction.amount);
    }

    assert(!flow.containsKey(Uuid.NAMESPACE_NIL),
        "There is no way you've managed to make a transaction without an account");

    if (omitZeroes) {
      flow.removeWhere((key, value) => value.isEmpty);
    }

    return FlowAnalytics(from: from, to: to, flow: flow);
  }

  Future<List<RelevanceScoredTitle>> transactionTitleSuggestions({
    String? currentInput,
    int? accountId,
    int? categoryId,
    TransactionType? type,
    int? limit,
  }) async {
    final Query<Transaction> transactionsQuery = ObjectBox()
        .box<Transaction>()
        .query(Transaction_.title.contains(
          currentInput?.trim() ?? "",
          caseSensitive: false,
        ))
        .build();

    final List<Transaction> transactions = await transactionsQuery
        .findAsync()
        .then((value) => value.where((element) {
              if (element.title?.trim().isNotEmpty != true) {
                return false;
              }
              if (type != TransactionType.transfer && element.isTransfer) {
                return false;
              }

              return true;
            }).toList());

    transactionsQuery.close();

    final List<RelevanceScoredTitle> relevanceCalculatedList = transactions
        .map((e) => (
              title: e.title,
              relevancy: e.titleSuggestionScore(
                accountId: accountId,
                categoryId: categoryId,
                transactionType: type,
              )
            ))
        .cast<RelevanceScoredTitle>()
        .toList();

    relevanceCalculatedList.sort((a, b) => b.relevancy.compareTo(a.relevancy));

    final List<RelevanceScoredTitle> scoredTitles =
        _mergeTitleRelevancy(relevanceCalculatedList);

    scoredTitles.sort((a, b) => b.relevancy.compareTo(a.relevancy));

    return scoredTitles.sublist(
      0,
      limit == null ? null : math.min(limit, scoredTitles.length),
    );
  }

  /// Removes duplicates from the iterable based on the keyExtractor function.
  ///
  /// Keeps the first value seen for a given key.
  List<RelevanceScoredTitle> _mergeTitleRelevancy(
    List<RelevanceScoredTitle> scores,
  ) {
    final Map<String, RelevanceScoredTitle> items = {};

    for (final element in scores) {
      final key = element.title.toLowerCase();

      if (items.containsKey(key)) {
        final RelevanceScoredTitle current = items[key]!;
        items[key] = (
          title: current.title,
          relevancy: current.relevancy + element.relevancy
        );
      } else {
        // Casing of the first occurance is preserved
        //
        // If you have "kfc" - 69 entries, and "KFC" - 420 entires,
        // "KFC" will appear in the list, and any other casing will be ignored
        items[key] = element;
      }
    }

    return items.values.toList();
  }
}

extension TransactionActions on Transaction {
  double titleSuggestionScore({
    String? query,
    int? accountId,
    int? categoryId,
    TransactionType? transactionType,
  }) {
    late double score;

    if (query == null ||
        query.trim().isEmpty ||
        title == null ||
        title!.trim().isEmpty) {
      score = 10.0; // Full match score is 100
    } else {
      score = partialRatio(query, title!).toDouble() + 10.0;
    }

    double multipler = 1.0;

    if (account.targetId == accountId) multipler += 0.33;

    if (transactionType != null && transactionType == type) multipler += 0.33;

    if (category.targetId == categoryId) multipler += 2.0;

    return score * multipler;
  }

  /// When user makes a transfer, it actually creates two transactions.
  ///
  /// 1. The main one (amount is positive)
  /// 2. The counter one (amount is negative)
  ///
  /// When editting transfer, everything should be applied to both
  /// transactions for consistency.
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

extension TransactionListActions on Iterable<Transaction> {
  Iterable<Transaction> get nonTransfers =>
      where((transaction) => !transaction.isTransfer);
  Iterable<Transaction> get transfers =>
      where((transaction) => transaction.isTransfer);
  Iterable<Transaction> get expenses =>
      where((transaction) => transaction.amount.isNegative);
  Iterable<Transaction> get incomes =>
      where((transaction) => transaction.amount > 0);

  double get incomeSum =>
      incomes.fold(0, (value, element) => value + element.amount);
  double get expenseSum =>
      expenses.fold(0, (value, element) => value + element.amount);
  double get sum => fold(0, (value, element) => value + element.amount);

  MoneyFlow get flow => MoneyFlow(
        totalExpense: expenseSum,
        totalIncome: incomeSum,
      );

  /// If [mergeFutureTransactions] is set to true, transactions in future
  /// relative to [anchor] will be grouped into the same group
  Map<TimeRange, List<Transaction>> groupByDate({
    DateTime? anchor,
  }) =>
      groupByRange(
        rangeFn: (transaction) => DayTimeRange.fromDateTime(
          transaction.transactionDate,
        ),
        anchor: anchor,
      );

  Map<TimeRange, List<Transaction>> groupByRange({
    DateTime? anchor,
    required TimeRange Function(Transaction) rangeFn,
  }) {
    anchor ??= DateTime.now();

    final Map<TimeRange, List<Transaction>> value = {};

    for (final transaction in this) {
      final TimeRange range = rangeFn(transaction);

      value[range] ??= [];
      value[range]!.add(transaction);
    }

    return value;
  }
}

extension AccountActions on Account {
  static Memoizer<String, String?>? accountNameToUuid;

  static String nameByUuid(String uuid) {
    accountNameToUuid ??= Memoizer(
      compute: _nameByUuid,
    );

    return accountNameToUuid!.get(uuid) ?? "???";
  }

  static String _nameByUuid(String uuid) {
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

  /// Creates a new transaction, and saves it
  ///
  /// Returns transaction id from [Box.put]
  int updateBalanceAndSave(
    double targetBalance, {
    String? title,
    DateTime? transactionDate,
  }) {
    final double delta = targetBalance - balance;

    return createAndSaveTransaction(
      amount: delta,
      title: title,
      transactionDate: transactionDate,
    );
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

    final int fromTransaction = createAndSaveTransaction(
      amount: -amount,
      title: resolvedTitle,
      extensions: [transferData],
      uuidOverride: fromTransactionUuid,
      createdDate: createdDate,
      transactionDate: transactionDate,
    );
    final int toTransaction = targetAccount.createAndSaveTransaction(
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

  /// Returns transaction id from [Box.put]
  int createAndSaveTransaction({
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
    )
      ..setCategory(category)
      ..setAccount(this);

    if (extensions != null && extensions.isNotEmpty) {
      value.addExtensions(extensions);
    }

    final int id = ObjectBox().box<Transaction>().put(value);

    try {
      LocalPreferences().updateFrecencyData("account", uuid);
      if (category != null) {
        LocalPreferences().updateFrecencyData("category", category.uuid);
      }
    } catch (e) {
      log("Failed to update frecency data for transaction ($id)");
    }

    return id;
  }
}
