import "dart:developer";

import "package:flow/data/transactions_filter.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/pending_transactions.dart";
import "package:flow/services/notifications.dart";
import "package:moment_dart/moment_dart.dart";

/// Call [disableUpdates] to pause listeners and [enableUpdates] to resume them.
class TransactionsService {
  static TransactionsService? _instance;

  bool _disableUpdates = false;
  bool get disableUpdates => _disableUpdates;

  final Set<void Function()> _listeners = {};

  void addListener(void Function() listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  _onChange() {
    for (final listener in _listeners) {
      listener();
    }
  }

  factory TransactionsService() =>
      _instance ??= TransactionsService._internal();

  TransactionsService._internal() {
    ObjectBox().box<Transaction>().query().watch().listen((event) {
      _onChange();
    });
  }

  QueryBuilder<Transaction> pendingTransactionsQb([DateTime? anchor]) {
    anchor = DateTime.now();

    return ObjectBox()
        .box<Transaction>()
        .query(Transaction_.transactionDate
            .greaterThanDate(anchor.startOfNextMinute())
            .or(Transaction_.isPending.equals(true)))
        .order(Transaction_.transactionDate);
  }

  Future<List<int>> upsertMany(List<Transaction> transactions) async {
    final List<int> ids =
        await ObjectBox().box<Transaction>().putManyAsync(transactions);

    return ids;
  }

  /// Returns how many items were deleted
  Future<int> deleteMany(TransactionFilter filter) async {
    final Query<Transaction> condition = filter.queryBuilder().build();
    final List<int> transactionIds = await condition.findIdsAsync();
    condition.close();

    final int deletedCount =
        await ObjectBox().box<Transaction>().removeManyAsync(transactionIds);

    return deletedCount;
  }

  Future<List<Transaction>> findMany(TransactionFilter? filter) async {
    if (filter == null) {
      return await getAll();
    }

    final Query<Transaction> condition = filter.queryBuilder().build();

    final List<Transaction> transactions = await condition.findAsync();

    condition.close();

    return transactions;
  }

  Future<Transaction?> findFirst(TransactionFilter? filter) async {
    if (filter == null) {
      return null;
    }

    final Query<Transaction> condition = filter.queryBuilder().build();

    final Transaction? transaction = await condition.findFirstAsync();

    condition.close();

    return transaction;
  }

  Transaction? findFirstSync(TransactionFilter? filter) {
    if (filter == null) {
      return null;
    }

    final Query<Transaction> condition = filter.queryBuilder().build();

    final Transaction? transaction = condition.findFirst();

    condition.close();

    return transaction;
  }

  int countMany(TransactionFilter? filter) {
    if (filter == null) {
      return countAll();
    }

    final Query<Transaction> condition = filter.queryBuilder().build();

    final int count = condition.count();

    return count;
  }

  Future<int> upsertOne(Transaction updateTransaction) async {
    return await ObjectBox().box<Transaction>().putAsync(updateTransaction);
  }

  int upsertOneSync(Transaction updateTransaction) {
    return ObjectBox().box<Transaction>().put(updateTransaction);
  }

  Future<int> updateOne(Transaction updateTransaction) async {
    return await ObjectBox()
        .box<Transaction>()
        .putAsync(updateTransaction, mode: PutMode.update);
  }

  int updateOneSync(Transaction updateTransaction) {
    return ObjectBox()
        .box<Transaction>()
        .put(updateTransaction, mode: PutMode.update);
  }

  Future<Transaction?> getOne(int id) async {
    return ObjectBox().box<Transaction>().getAsync(id);
  }

  Future<List<Transaction>> getAll() async {
    return ObjectBox().box<Transaction>().getAllAsync();
  }

  int countAll() {
    return ObjectBox().box<Transaction>().count();
  }

  /// Deletes a transaction by its identifier.
  ///
  /// The identifier can be either an [int] or a [Transaction] object.
  ///
  /// Returns `true` if the transaction existend, and was deleted, `false` otherwise.
  bool deleteSync(dynamic identifier) {
    switch (identifier) {
      case int id:
        return ObjectBox().box<Transaction>().remove(id);
      case Transaction transaction:
        return ObjectBox().box<Transaction>().remove(transaction.id);
      default:
        return false;
    }
  }

  Future<void> synchronizeNotifications() async {
    final Query<Transaction> qb = pendingTransactionsQb().build();
    final List<Transaction> pendingTransactions = qb.find();
    qb.close();

    await NotificationsService().cancelAllNotifications();

    await Future.wait(
      pendingTransactions.map(
        (transaction) =>
            NotificationsService().scheduleForPlannedTransaction(transaction),
      ),
    ).catchError((error) {
      log("Failed to schedule notifications", error: error);
      return [];
    });

    final Duration earlyReminder = Duration(
      seconds:
          PendingTransactionsLocalPreferences().earlyReminderInSeconds.get() ??
              0,
    );

    if (earlyReminder.inSeconds > 0) {
      await Future.wait(
        pendingTransactions.map(
          (transaction) =>
              NotificationsService().scheduleForPlannedTransaction(transaction),
        ),
      ).catchError((error) {
        log("Failed to schedule planned notifications", error: error);
        return [];
      });
    }
  }

  /// Has no effect if it's already paused
  void pauseListeners() {
    _disableUpdates = true;
  }

  /// Has no effect if it's already resumed
  void resumeListeners() {
    _disableUpdates = false;
  }
}
