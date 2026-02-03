import "dart:async";
import "dart:io";
import "dart:math" as math;

import "package:flow/data/exchange_rates.dart";
import "package:flow/data/flow_analytics.dart";
import "package:flow/data/money.dart";
import "package:flow/data/multi_currency_flow.dart";
import "package:flow/data/prefs/frecency_group.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/data/transaction_programmable_object.dart";
import "package:flow/data/transactions_filter/time_range.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/backup_entry.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/file_attachment.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction/extensions/base.dart";
import "package:flow/entity/transaction/extensions/default/geo.dart";
import "package:flow/entity/transaction/extensions/default/recurring.dart";
import "package:flow/entity/transaction/extensions/default/transfer.dart";
import "package:flow/entity/transaction_tag.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/accounts.dart";
import "package:flow/services/categories.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/file_attachment.dart";
import "package:flow/services/recurring_transactions.dart";
import "package:flow/services/transactions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/utils/utils.dart";
import "package:fuzzywuzzy/fuzzywuzzy.dart";
import "package:logging/logging.dart";
import "package:moment_dart/moment_dart.dart";
import "package:recurrence/recurrence.dart";
import "package:uuid/uuid.dart";

final Logger _log = Logger("ObjectBoxActions");

typedef RelevanceScoredTitle = ({String title, double relevancy});

extension MainActions on ObjectBox {
  /// Returns the grand total of all accounts in primary currency in the primary currency
  Money getPrimaryCurrencyGrandTotal() {
    final String primaryCurrency = UserPreferencesService().primaryCurrency;

    final Query<Account> accountsQuery = box<Account>()
        .query(
          Account_.excludeFromTotalBalance
              .notEquals(true)
              .and(Account_.currency.equals(primaryCurrency)),
        )
        .build();

    final List<Account> accounts = accountsQuery.find();

    accountsQuery.close();

    return accounts
        .map((e) => e.balance)
        .fold(
          Money(0, primaryCurrency),
          (previousValue, element) => previousValue + element,
        );
  }

  /// Returns the grand total of all accounts (including non-primary currency accounts) in the primary currency
  Future<Money?> getGrandTotal() async {
    final String primaryCurrency = UserPreferencesService().primaryCurrency;

    final Condition<Account> query = Account_.excludeFromTotalBalance
        .isNull()
        .or(Account_.excludeFromTotalBalance.notEquals(true))
        .and(Account_.archived.isNull().or(Account_.archived.notEquals(true)));

    final Query<Account> accountsQuery = box<Account>().query(query).build();

    final List<Account> accounts = accountsQuery.find();

    accountsQuery.close();

    Money total = accounts
        .where((account) => account.currency == primaryCurrency)
        .fold<Money>(
          Money(0, primaryCurrency),
          (previousValue, element) => previousValue + element.balance,
        );

    final List<Account> nonPrimaryCurrencyAccounts = accounts
        .where((account) => account.currency != primaryCurrency)
        .toList();

    final ExchangeRates? rates = await ExchangeRatesService().tryFetchRates(
      primaryCurrency,
    );

    if (rates == null) return null;

    for (final Account account in nonPrimaryCurrencyAccounts) {
      final Money converted = account.balance.convert(primaryCurrency, rates);

      total += converted;
    }

    return total;
  }

  List<Account> getAccounts([bool sortByFrecency = true]) {
    final List<Account> accounts = box<Account>().getAll();

    accounts.removeWhere((account) => account.archived == true);

    if (sortByFrecency) {
      final FrecencyGroup frecencyGroup = FrecencyGroup(
        accounts
            .map(
              (account) => TransitiveLocalPreferences().getFrecencyData(
                "account",
                account.uuid,
              ),
            )
            .nonNulls
            .toList(),
      );

      accounts.sort(
        (a, b) => frecencyGroup
            .getScore(b.uuid)
            .compareTo(frecencyGroup.getScore(a.uuid)),
      );
    }

    return accounts;
  }

  List<Category> getCategories([bool sortByFrecency = true]) {
    final List<Category> categories = box<Category>().getAll();

    if (sortByFrecency) {
      final FrecencyGroup frecencyGroup = FrecencyGroup(
        categories
            .map(
              (category) => TransitiveLocalPreferences().getFrecencyData(
                "category",
                category.uuid,
              ),
            )
            .nonNulls
            .toList(),
      );

      categories.sort(
        (a, b) => frecencyGroup
            .getScore(b.uuid)
            .compareTo(frecencyGroup.getScore(a.uuid)),
      );
    }

    return categories;
  }

  List<TransactionTag> getTransactionTags([bool sortByFrecency = true]) {
    final List<TransactionTag> transactionTags = box<TransactionTag>().getAll();

    if (sortByFrecency) {
      final FrecencyGroup frecencyGroup = FrecencyGroup(
        transactionTags
            .map(
              (tag) =>
                  TransitiveLocalPreferences().getFrecencyData("tag", tag.uuid),
            )
            .nonNulls
            .toList(),
      );

      transactionTags.sort(
        (a, b) => frecencyGroup
            .getScore(b.uuid)
            .compareTo(frecencyGroup.getScore(a.uuid)),
      );
    }

    return transactionTags;
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
    await _normalizeSortOrders();
  }

  /// Returns all non-pending transactions in given [range]
  Future<List<Transaction>> transcationsByRange(
    TimeRange range, {
    bool includeTransfers = true,
  }) async {
    final TransactionFilter filter = TransactionFilter(
      range: TransactionFilterTimeRange.fromTimeRange(range),
      isPending: false,
    );

    final List<Transaction> transactions = await TransactionsService().findMany(
      filter,
    );

    if (includeTransfers) {
      return transactions;
    }

    return transactions
        .where((transaction) => !transaction.isTransfer)
        .toList();
  }

  Future<Map<T, MultiCurrencyFlow<K>>> flowBy<T, K>(
    List<Transaction> transactions,
    T? Function(Transaction t) keyBy,
    K Function(Transaction t)? associateBy,
  ) async {
    final Map<T, MultiCurrencyFlow<K>> flow = {};

    for (final transaction in transactions) {
      final T? key = keyBy(transaction);

      if (key == null) continue;

      final K? associatedData = associateBy?.call(transaction);

      flow[key] ??= MultiCurrencyFlow<K>(associatedData: associatedData);
      flow[key]!.add(transaction.money);
    }

    return flow;
  }

  /// Returns a map of category uuid -> [MultiCurrencyFlow]
  Future<FlowAnalytics<Category?>> flowByCategories({
    required TimeRange range,
    bool ignoreTransfers = true,
  }) async {
    final List<Transaction> transactions = await transcationsByRange(range);

    final flow = await flowBy(transactions, (t) {
      if (ignoreTransfers && t.isTransfer) return null;

      return t.category.target?.uuid ?? Namespace.nil.value;
    }, (t) => t.category.target);

    return FlowAnalytics(flow: flow, range: range);
  }

  /// Returns a map of category uuid -> [MultiCurrencyFlow]
  Future<FlowAnalytics<Account>> flowByAccounts({
    required TimeRange range,
    bool ignoreTransfers = true,
  }) async {
    final List<Transaction> transactions = await transcationsByRange(range);

    final Map<String, MultiCurrencyFlow<Account>> flow = await flowBy(
      transactions,
      (t) {
        if (ignoreTransfers && t.isTransfer) return null;

        return t.account.target?.uuid ?? Namespace.nil.value;
      },
      (t) => t.account.target!,
    );

    assert(
      !flow.containsKey(Namespace.nil.value),
      "There is no way you've managed to make a transaction without an account, but hey! Congratulations! You've just found a bug!",
    );

    return FlowAnalytics(flow: flow, range: range);
  }

  Future<List<RelevanceScoredTitle>> transactionTitleSuggestions({
    String? currentInput,
    int? accountId,
    int? categoryId,
    double? amount,
    String? currency,
    DateTime? transactionDate,
    TransactionType? type,
    int? limit,
  }) async {
    final TransactionFilter filter = TransactionFilter(
      searchData: TransactionSearchData(
        includeDescription: false,
        keyword: currentInput?.trim() ?? "",
        mode: TransactionSearchMode.substring,
      ),
      range: TransactionFilterTimeRange(
        Moment.now()
            .subtract(const Duration(days: 210))
            .rangeTo(Moment.now())
            .encodeShort(),
      ),
    );

    final List<Transaction> transactions = await TransactionsService()
        .findMany(filter)
        .then(
          (value) => value.where((element) {
            if (element.title?.trim().isNotEmpty != true) {
              return false;
            }
            if (type != TransactionType.transfer && element.isTransfer) {
              return false;
            }

            return true;
          }).toList(),
        )
        .catchError((error, stackTrace) {
          _log.severe(
            "Failed to fetch transactions for title suggestions",
            error,
            stackTrace,
          );
          return <Transaction>[];
        });

    final List<RelevanceScoredTitle> relevanceCalculatedList = transactions
        .map(
          (e) => (
            title: e.title,
            relevancy: e.titleSuggestionScore(
              accountId: accountId,
              categoryId: categoryId,
              transactionType: type,
              transactionDate: transactionDate,
              amount: amount,
              currency: currency,
            ),
          ),
        )
        .cast<RelevanceScoredTitle>()
        .toList();

    relevanceCalculatedList.sort((a, b) => b.relevancy.compareTo(a.relevancy));

    final List<RelevanceScoredTitle> scoredTitles = _mergeTitleRelevancy(
      relevanceCalculatedList,
    );

    scoredTitles.sort((a, b) => b.relevancy.compareTo(a.relevancy));

    return scoredTitles.sublist(
      0,
      limit == null ? null : math.min(limit, scoredTitles.length),
    );
  }

  /// Removes duplicates from the iterable based on the keyExtractor function.
  List<RelevanceScoredTitle> _mergeTitleRelevancy(
    List<RelevanceScoredTitle> scores,
  ) {
    final List<List<RelevanceScoredTitle>> grouped = scores
        .groupBy((relevance) => relevance.title.toLowerCase())
        .values
        .toList();

    return grouped.map((items) {
      final double max = items.map((x) => x.relevancy).reduce(math.max);

      return (title: items.first.title, relevancy: max);
    }).toList();
  }

  Future<void> _normalizeSortOrders() async {
    final List<Account> accounts = await box<Account>().getAllAsync();
    final Set<int> sortOrders = accounts
        .map((account) => account.sortOrder)
        .toSet();

    if (sortOrders.length != accounts.length ||
        accounts.any((account) => account.sortOrder < 0)) {
      accounts.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      int i = 0;

      for (var account in accounts) {
        if (account.archived) {
          account.sortOrder += 1000 + i;
        } else {
          account.sortOrder = i;
        }
        i++;
      }

      await box<Account>().putManyAsync(accounts);
    }

    return;
  }
}

extension TransactionActions on Transaction {
  /// Base score is 10.0
  ///
  /// * If [query] is exactly same as [title], score is base + 100.0 (110.0)
  /// * If [accountId] matches, score is increased by 25%
  ///   * If [accountId] matches, and [amount] matches, score is increased by another 100%
  /// * If [transactionType] matches, score is increased by 50%
  /// * If [categoryId] matches, score is increased by 150%
  ///   * If [categoryId] matches, and [amount] matches, score is increased by 350%
  /// * Depending on recency of [transactionDate], score is increased by 0% - 40%
  ///
  /// **Max multi.**: 7.15
  /// **Max score**: 786.5
  /// **Query only max score**: 110.0
  /// **No query max score**: 72.5
  ///
  /// Recommended to set [fuzzyPartial] to false when using for filtering purposes
  double titleSuggestionScore({
    String? query,
    int? accountId,
    int? categoryId,
    TransactionType? transactionType,
    bool fuzzyPartial = true,
    bool caseSensitive = false,
    double? amount,
    String? currency,
    DateTime? transactionDate,
  }) {
    final List<String> reasons = [];

    double score = 10.0;

    final String? normalizedTitle = caseSensitive
        ? title?.trim()
        : title?.trim().toLowerCase();

    if (query?.trim().isNotEmpty == true && normalizedTitle != null) {
      score += fuzzyPartial
          ? partialRatio(query!, normalizedTitle).toDouble()
          : ratio(query!, normalizedTitle).toDouble();
    }

    final bool amountMatches =
        amount != null &&
        amount.abs() != 0 &&
        this.amount == amount &&
        this.currency == currency;

    double multiplier = 1.0;

    if (account.targetId == accountId) {
      multiplier += 0.25;
      reasons.add("accountId matches, 25%");

      if (amountMatches) {
        multiplier += 1.0;
      }
    }

    if (transactionType != null && transactionType == type) {
      multiplier += 0.5;
      reasons.add("transactionType matches, 50%");
    }

    if (category.targetId == categoryId) {
      multiplier += 1.5;

      if (amountMatches) {
        multiplier += 3.5;
      }

      final Duration? transactionDateDifference = transactionDate
          ?.difference(this.transactionDate)
          .abs();

      final double recencyScoreMultipler = switch (transactionDateDifference) {
        null => 0,
        > const Duration(days: 60) => 0.1,
        > const Duration(days: 14) => 0.2,
        > const Duration(days: 7) => 0.3,
        _ => 0.4,
      };

      multiplier += recencyScoreMultipler;
    }

    return score * multiplier;
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
        .query(
          Transaction_.uuid.equals(
            transfer.relatedTransactionUuid ?? Namespace.nil.value,
          ),
        )
        .build();

    try {
      return query.findFirst();
    } catch (e) {
      return this;
    } finally {
      query.close();
    }
  }

  bool permanentlyDelete([bool skipBinCheck = false]) {
    if (!skipBinCheck && isDeleted != true) {
      throw StateError(
        "Transaction must be moved to trash bin before deletion, or set [skipBinCheck] to true",
      );
    }

    if (isTransfer) {
      final Transfer? transfer = extensions.transfer;

      if (transfer == null) {
        _log.severe(
          "Couldn't delete transfer transaction properly due to missing transfer data",
        );
      } else {
        final TransactionFilter filter = TransactionFilter(
          uuids: [transfer.relatedTransactionUuid ?? Namespace.nil.value],
        );

        final Transaction? relatedTransaction = TransactionsService()
            .findFirstSync(filter);

        try {
          final bool removedRelated = TransactionsService().deleteSync(
            relatedTransaction,
          );

          if (!removedRelated) {
            throw Exception("Failed to remove related transaction");
          }
        } catch (e, stackTrace) {
          _log.severe(
            "Couldn't delete transfer transaction properly",
            e,
            stackTrace,
          );
        }
      }
    }

    return TransactionsService().deleteSync(id);
  }

  bool confirm([bool confirm = true, bool updateTransactionDate = true]) {
    try {
      if (isTransfer) {
        final Transfer? transfer = extensions.transfer;

        if (transfer == null) {
          _log.severe(
            "Couldn't delete transfer transaction properly due to missing transfer data",
          );
        } else {
          try {
            TransactionsService().confirmTransactionSync(
              transfer.relatedTransactionUuid,
              confirm: confirm,
              updateTransactionDate: updateTransactionDate,
            );
          } catch (e, stackTrace) {
            _log.severe(
              "Couldn't delete transfer transaction properly",
              e,
              stackTrace,
            );
          }
        }
      }

      return TransactionsService().confirmTransactionSync(
        this,
        confirm: confirm,
        updateTransactionDate: updateTransactionDate,
      );
    } catch (e, stackTrace) {
      _log.severe("Failed to confirm transaction", e, stackTrace);
      return false;
    }
  }

  /// Returns the ObjectBox ID for the newly created transaction
  int duplicate() {
    if (isTransfer) {
      throw Exception("Cannot duplicate transfer transactions");
    }

    final Transaction duplicate =
        Transaction(
            amount: amount,
            currency: currency,
            title: title,
            description: description,
            transactionDate: transactionDate,
            createdDate: Moment.now(),
            isPending: isPending,
            uuid: Uuid().v4(),
            extraTags: extraTags,
            subtype: subtype,
          )
          ..setTags(tags.toList())
          ..setAttachments(attachments.toList())
          ..setCategory(category.target)
          ..setAccount(account.target);

    duplicate.addExtensions(extensions.data);

    return TransactionsService().upsertOneSync(duplicate);
  }
}

extension AccountListActions on Iterable<Account> {
  Iterable<Account> get actives => where((account) => account.archived != true);
  Iterable<Account> get inactives =>
      where((account) => account.archived == true);
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
  Iterable<Transaction> get nonPending =>
      where((transaction) => transaction.isPending != true);
  Iterable<Transaction> get nonDeleted =>
      where((transaction) => transaction.isDeleted != true);

  /// Returns null if there are zero or one transaction.
  ///
  /// Returns the time range of the transactions;
  ///
  /// E.g., If the earliest transaction is 2023-01-01 and the latest is
  /// 2023-12-31, the range will be 2023-01-01 to 2023-12-31.
  ///
  /// Always returns a [CustomTimeRange] object when not null.
  TimeRange? get range {
    if (length < 2) {
      return null;
    }

    DateTime min = Moment.maxValue;
    DateTime max = Moment.minValue;

    for (final transaction in this) {
      min = transaction.transactionDate.isBefore(min)
          ? transaction.transactionDate
          : min;
      max = transaction.transactionDate.isAfter(max)
          ? transaction.transactionDate
          : max;
    }

    return min.rangeTo(max);
  }

  /// Number of transactions that are rendered on the screen
  ///
  /// This depends on [LocalPreferences().combineTransferTransactions]
  /// and current list of transactions
  int get renderableCount =>
      length -
      (UserPreferencesService().combineTransfers ? transfers.length ~/ 2 : 0);

  double get incomeSumWithoutCurrency =>
      incomes.fold(0, (value, element) => value + element.amount);
  double get expenseSumWithoutCurrency =>
      expenses.fold(0, (value, element) => value + element.amount);
  double get sumWithoutCurrency =>
      fold(0, (value, element) => value + element.amount);

  Money get incomeSum => incomes.fold(
    Money(0.0, firstOrNull?.currency ?? "XXX"),
    (value, element) => value + element.money,
  );
  Money get expenseSum => expenses.fold(
    Money(0.0, firstOrNull?.currency ?? "XXX"),
    (value, element) => value + element.money,
  );
  Money get sum => fold(
    Money(0.0, firstOrNull?.currency ?? "XXX"),
    (value, element) => value + element.money,
  );

  MultiCurrencyFlow get flow =>
      MultiCurrencyFlow()..addAll(map((transaction) => transaction.money));

  /// If [mergeFutureTransactions] is set to true, transactions in future
  /// relative to [anchor] will be grouped into the same group
  Map<TimeRange, List<Transaction>> groupByDate({DateTime? anchor}) =>
      groupByRange(
        rangeFn: (transaction) =>
            DayTimeRange.fromDateTime(transaction.transactionDate),
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

  List<Transaction> filter(List<bool Function(Transaction)> predicates) =>
      where(
        (Transaction t) => predicates
            .map((predicate) => predicate(t))
            .every((element) => element),
      ).toList();

  List<Transaction> search(TransactionSearchData? data) {
    if (data == null || data.normalizedKeyword == null) return toList();

    final matches = where(data.predicate).toList();

    if (data.mode == TransactionSearchMode.smart && matches.isEmpty) {
      return search(
        data.copyWithOptional(mode: TransactionSearchMode.substring),
      );
    }

    return matches;
  }
}

extension AccountActions on Account {
  /// Upserts a transaction (creates if not exists, updates if exists)
  ///
  /// Returns transaction id from [Box.put]
  int updateBalanceAndSave(
    double targetBalance, {
    int? existingTransactionId,
    String? title,
    DateTime? transactionDate,
  }) {
    final double delta =
        targetBalance -
        (transactionDate == null
            ? balance.amount
            : balanceAt(transactionDate).amount);

    if (delta == 0) {
      throw Exception(
        "[Account.updateBalanceAndSave] Target balance ($targetBalance) is same as current balance (${balance.amount})",
      );
    }

    if (existingTransactionId != null && existingTransactionId > 0) {
      final Transaction? transaction = TransactionsService().getOneSync(
        existingTransactionId,
      );

      if (transaction == null) {
        throw Exception(
          "[Account.updateBalanceAndSave] Transaction with id $existingTransactionId not found, aborting operation",
        );
      }

      transaction.amount = delta;
      transaction.transactionDate = DateTime.now();
      return TransactionsService().updateOneSync(transaction);
    }

    return createAndSaveTransaction(
      amount: delta,
      title: title,
      transactionDate: transactionDate,
      subtype: TransactionSubtype.updateBalance,
    );
  }

  /// Returns object ids from `box.put`
  ///
  /// First transaction represents money going out of [this] account
  ///
  /// Second transaction represents money incoming to the target account
  ///
  /// [this]' [currency] will be used as the anchor. Not that if [amount] is
  /// less than zero, the from and to will be reversed roles, and [conversionRate]
  /// will be inversed.
  ///
  /// [conversionRate] is used to multiple the `to`'s amount.
  ///
  /// e.g., for transfers from USD to MNT, it may be something like 3450.0.
  (int from, int to) transferTo({
    String? title,
    String? description,
    required Account targetAccount,
    required double amount,
    DateTime? createdDate,
    DateTime? transactionDate,
    double? latitude,
    double? longitude,
    List<TransactionExtension>? extensions,
    List<TransactionTag>? tags,
    List<FileAttachment>? attachments,
    bool? isPending,
    double? conversionRate = 1.0,
    Recurrence? recurrence,
    List<String>? extraTags,
  }) {
    if (conversionRate == 0) {
      throw Exception("Conversion rate cannot be zero, use 1.0 instead");
    }

    if (amount <= 0) {
      return targetAccount.transferTo(
        targetAccount: this,
        amount: amount.abs(),
        title: title,
        description: description,
        createdDate: createdDate,
        transactionDate: transactionDate,
        latitude: latitude,
        longitude: longitude,
        extensions: extensions,
        isPending: isPending,
        conversionRate: 1.0 / (conversionRate ?? 1.0),
        recurrence: recurrence,
        extraTags: extraTags,
        tags: tags,
        attachments: attachments,
      );
    }

    final String fromTransactionUuid = const Uuid().v4();
    final String toTransactionUuid = const Uuid().v4();

    final Transfer transferData = Transfer(
      uuid: const Uuid().v4(),
      fromAccountUuid: uuid,
      toAccountUuid: targetAccount.uuid,
      relatedTransactionUuid: toTransactionUuid,
      conversionRate: conversionRate,
    );

    final String resolvedTitle =
        title ??
        "transaction.transfer.fromToTitle".tr({
          "from": name,
          "to": targetAccount.name,
        });

    final List<TransactionExtension> filteredExtensions =
        extensions?.where((ext) => ext is! Transfer).toList() ?? [];

    transactionDate ??= recurrence?.range.from ?? DateTime.now();

    final String? recurringTransactionUuid = recurrence == null
        ? null
        : const Uuid().v4();

    Recurring? recurringExtension;

    if (recurringTransactionUuid != null) {
      recurringExtension = Recurring(
        initialTransactionDate: transactionDate,
        uuid: recurringTransactionUuid,
        relatedTransactionUuid: fromTransactionUuid,
      );
    }

    final int fromTransaction = createAndSaveTransaction(
      amount: -amount,
      title: resolvedTitle,
      description: description,
      extensions: [
        ...filteredExtensions,
        transferData,
        if (recurringExtension != null) recurringExtension,
      ],
      uuidOverride: fromTransactionUuid,
      createdDate: createdDate,
      transactionDate: transactionDate,
      isPending: isPending,
      extraTags: extraTags,
      tags: tags,
      attachments: attachments,
    );
    final int toTransaction = targetAccount.createAndSaveTransaction(
      amount: amount * (conversionRate ?? 1.0),
      title: resolvedTitle,
      description: description,
      extensions: [
        ...filteredExtensions,
        transferData.copyWith(relatedTransactionUuid: fromTransactionUuid),
        if (recurringExtension != null)
          recurringExtension.copyWith(
            relatedTransactionUuid: toTransactionUuid,
          ),
      ],
      uuidOverride: toTransactionUuid,
      createdDate: createdDate,
      transactionDate: transactionDate,
      isPending: isPending,
      extraTags: extraTags,
      tags: tags,
      attachments: attachments,
    );

    if (recurringTransactionUuid != null) {
      RecurringTransactionsService().createFromTransaction(
        identifier: fromTransactionUuid,
        recurrence: recurrence!,
        uuidOverride: recurringTransactionUuid,
        transferToAccountUuid: targetAccount.uuid,
      );
    }

    return (fromTransaction, toTransaction);
  }

  /// Returns transaction id from [Box.put]
  int createAndSaveTransaction({
    required double amount,
    DateTime? transactionDate,
    DateTime? createdDate,
    String? title,
    String? description,
    Category? category,
    List<TransactionExtension>? extensions,
    List<TransactionTag>? tags,
    List<FileAttachment>? attachments,
    String? uuidOverride,
    bool? isPending,
    TransactionSubtype? subtype,
    Recurrence? recurrence,
    List<String>? extraTags,
    double? latitude,
    double? longitude,
  }) {
    FileAttachmentService().upsertManySync(attachments ?? []);

    final String uuid = uuidOverride ?? const Uuid().v4();

    if (latitude == null || longitude == null) {
      final Geo? geo =
          extensions?.firstWhereOrNull((ext) => ext is Geo) as Geo?;

      final latLng = geo?.toLatLng();
      latitude ??= latLng?[0];
      longitude ??= latLng?[1];
    }

    final String? recurringTransactionUuid = recurrence == null
        ? null
        : const Uuid().v4();

    Recurring? recurringExtension;

    transactionDate ??= recurrence?.range.from ?? DateTime.now();

    if (recurringTransactionUuid != null) {
      recurringExtension = Recurring(
        initialTransactionDate: transactionDate,
        uuid: recurringTransactionUuid,
        relatedTransactionUuid: uuid,
      );

      extensions ??= [];
      extensions.add(recurringExtension);
    }

    Transaction value =
        Transaction(
            amount: amount,
            currency: currency,
            title: title,
            description: description,
            transactionDate: transactionDate,
            createdDate: createdDate,
            uuid: uuid,
            isPending: isPending ?? false,
            subtype: subtype?.value,
            extraTags: extraTags ?? [],
            location: (latitude != null && longitude != null)
                ? [latitude, longitude]
                : null,
          )
          ..setTags(tags ?? [])
          ..setCategory(category)
          ..setAccount(this)
          ..setAttachments(attachments ?? []);

    final List<TransactionExtension>? applicableExtensions = extensions
        ?.map((ext) {
          _log.fine(
            "Adding extension to Transaction($uuidOverride): ${ext.runtimeType}(${ext.uuid})",
          );
          _log.fine("Checking extension: ${ext.runtimeType}");

          if (ext.relatedTransactionUuid == null) {
            return ext..setRelatedTransactionUuid(uuid);
          }

          if (ext.key == Transfer.keyName) {
            // Transfer extension is handled separately
            return ext;
          }

          if (ext.relatedTransactionUuid == uuid) {
            return ext;
          }

          _log.warning(
            "Skipping extension ${ext.runtimeType}(${ext.uuid}) due to mismatched relatedTransactionUuid (${ext.relatedTransactionUuid} != $uuid)",
          );

          return null;
        })
        .nonNulls
        .toList();

    if (applicableExtensions != null && applicableExtensions.isNotEmpty) {
      value.addExtensions(applicableExtensions);
    }

    final int id = TransactionsService().upsertOneSync(value);

    if (recurringTransactionUuid != null) {
      RecurringTransactionsService().createFromTransaction(
        identifier: uuid,
        recurrence: recurrence!,
        uuidOverride: recurringTransactionUuid,
      );
    }

    try {
      unawaited(
        TransitiveLocalPreferences()
            .updateFrecencyData("account", uuid)
            .then((_) {})
            .catchError((e, stackTrace) {
              _log.warning(
                "Failed to update frecency data for account ($uuid)",
                e,
                stackTrace,
              );
            }),
      );
      if (category != null) {
        unawaited(
          TransitiveLocalPreferences()
              .updateFrecencyData("category", category.uuid)
              .then((_) {})
              .catchError((e, stackTrace) {
                _log.warning(
                  "Failed to update frecency data for category (${category.uuid})",
                  e,
                  stackTrace,
                );
              }),
        );
      }
      if (tags?.isNotEmpty == true) {
        for (final tag in tags!) {
          unawaited(
            TransitiveLocalPreferences()
                .updateFrecencyData("tag", tag.uuid)
                .then((_) {})
                .catchError((e, stackTrace) {
                  _log.warning(
                    "Failed to update frecency data for tag (${tag.uuid})",
                    e,
                    stackTrace,
                  );
                }),
          );
        }
      }
    } catch (e, stackTrace) {
      _log.warning(
        "Failed to update frecency data for transaction ($id)",
        e,
        stackTrace,
      );
    }

    return id;
  }
}

extension BackupEntryActions on BackupEntry {
  Future<bool> delete() async {
    try {
      final File file = File(filePath);

      if (await file.exists()) {
        await file.delete();
      }

      return ObjectBox().box<BackupEntry>().remove(id);
    } catch (e) {
      return false;
    }
  }
}

extension TransactionProgrammableObjectActions
    on TransactionProgrammableObject {
  int save({
    dynamic fromAccount,
    dynamic toAccount,
    List<String>? extraTags,
    List<TransactionExtension>? extensions,
    bool? isPendingOverride,
  }) {
    final Account? resolvedFromAccount =
        AccountsService().findOneActiveSync(fromAccountUuid) ??
        AccountsService().findOneActiveSync(fromAccount) ??
        switch (fromAccount) {
          Account a => a,
          dynamic any => AccountsService().findOneActiveSync(any),
        } ??
        AccountsService().findOneActiveSync(
          UserPreferencesService().primaryAccountUuid,
        );

    Account? resolvedToAccount =
        AccountsService().findOneActiveSync(toAccountUuid) ??
        AccountsService().findOneActiveSync(toAccount) ??
        switch (toAccount) {
          Account a => a,
          dynamic any => AccountsService().findOneActiveSync(any),
        };

    if (resolvedFromAccount == null) {
      throw Exception(
        "Failed to find account for TransactionProgrammableObject.save",
      );
    }

    if (type == .transfer &&
        resolvedToAccount == null &&
        resolvedFromAccount.uuid !=
            UserPreferencesService().primaryAccountUuid) {
      resolvedToAccount = AccountsService().findOneActiveSync(
        UserPreferencesService().primaryAccountUuid,
      );
    }

    if (type == .transfer && resolvedToAccount == null) {
      throw Exception(
        "Failed to find target account for transfer TransactionProgrammableObject.save",
      );
    }

    Category? resolvedCategory;

    if (type != .transfer) {
      try {
        resolvedCategory =
            CategoriesService().findOneSync(categoryUuid) ??
            CategoriesService().findOneSync(category);
      } catch (e) {
        // Ignore errors here
      }
    }

    final List<TransactionTag>? resolvedTags = resolveTags();

    if (type == .transfer) {
      return resolvedFromAccount
          .transferTo(
            targetAccount: resolvedToAccount!,
            amount: amount ?? 0.0,
            title: title,
            description: notes,
            transactionDate: transactionDate,
            isPending: isPendingOverride ?? isPending,
            tags: resolvedTags,
            conversionRate: transferConversionRate,
            // attachments: attachments,
            // recurrence: recurrence,
            extraTags: extraTags,
            extensions: extensions,
            latitude: lat,
            longitude: lng,
          )
          .$1;
    } else {
      // required double amount,
      // DateTime? transactionDate,
      // DateTime? createdDate,
      // String? title,
      // String? description,
      // Category? category,
      // List<TransactionExtension>? extensions,
      // List<TransactionTag>? tags,
      // List<FileAttachment>? attachments,
      // String? uuidOverride,
      // bool? isPending,
      // TransactionSubtype? subtype,
      // Recurrence? recurrence,
      // List<String>? extraTags,
      // List<double>? location,
      return resolvedFromAccount.createAndSaveTransaction(
        amount: amount ?? 0.0,
        transactionDate: transactionDate,
        title: title,
        description: notes,
        category: resolvedCategory,
        tags: resolvedTags,
        isPending: isPendingOverride ?? isPending,
        // attachments: attachments,
        // subtype: subtype,
        extensions: extensions,
        extraTags: extraTags,
        latitude: lat,
        longitude: lng,
      );
    }
  }

  List<TransactionTag>? resolveTags() {
    if (tagsUuids == null && tags == null) {
      return null;
    }

    if (tagsUuids?.isNotEmpty == true) {
      final query = ObjectBox()
          .box<TransactionTag>()
          .query(TransactionTag_.uuid.oneOf(tagsUuids!))
          .build();

      final List<TransactionTag> resolvedTags = query.find();
      query.close();
      return resolvedTags;
    }

    if (tags?.isNotEmpty == true) {
      final query = ObjectBox()
          .box<TransactionTag>()
          .query(TransactionTag_.title.oneOf(tags!))
          .build();

      final List<TransactionTag> resolvedTags = query.find();
      query.close();
      return resolvedTags;
    }

    return [];
  }
}
