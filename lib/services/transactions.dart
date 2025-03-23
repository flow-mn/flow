import "package:flow/data/flow_notification_payload.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/prefs/pending_transactions.dart";
import "package:flow/services/notifications.dart";
import "package:flow/services/user_preferences.dart";
import "package:logging/logging.dart";
import "package:moment_dart/moment_dart.dart";

final Logger _log = Logger("TransactionsService");

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
    if (disableUpdates) return;

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

  final Condition<Transaction> nonDeletedCondition =
      Transaction_.isDeleted.equals(false) | Transaction_.isDeleted.isNull();

  QueryBuilder<Transaction> pendingTransactionsQb([DateTime? anchor]) {
    anchor = DateTime.now();

    final Condition<Transaction> condition =
        nonDeletedCondition &
        (Transaction_.transactionDate.greaterThanDate(
              anchor.startOfNextMinute(),
            ) |
            Transaction_.isPending.equals(true));

    return ObjectBox()
        .box<Transaction>()
        .query(condition)
        .order(Transaction_.transactionDate);
  }

  QueryBuilder<Transaction> deletedTransactionsQb() {
    return ObjectBox()
        .box<Transaction>()
        .query(Transaction_.isDeleted.equals(true))
        .order(Transaction_.transactionDate);
  }

  Future<List<int>> upsertMany(List<Transaction> transactions) async {
    final List<int> ids = await ObjectBox().box<Transaction>().putManyAsync(
      transactions,
    );

    return ids;
  }

  /// Returns how many items were deleted
  Future<int> deleteMany(TransactionFilter filter) async {
    final Query<Transaction> condition = filter.queryBuilder().build();
    final int deletedCount = await condition.removeAsync();
    condition.close();

    return deletedCount;
  }

  Future<int> emptyTrashBin() async {
    final Query<Transaction> condition = deletedTransactionsQb().build();
    final int deletedCount = await condition.removeAsync();
    condition.close();

    return deletedCount;
  }

  Future<List<Transaction>> findMany(TransactionFilter filter) async {
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

  Future<Transaction?> findByIdentifier(dynamic identifier) async {
    switch (identifier) {
      case int id:
        return await getOne(id);
      case Transaction transaction:
        return transaction;
      case String uuid:
        return await findFirst(TransactionFilter(uuids: [uuid]));
      default:
        return null;
    }
  }

  Transaction? findByIdentifierSync(
    dynamic identifier, {
    bool includeDeleted = false,
  }) {
    switch (identifier) {
      case int id:
        return getOneSync(id);
      case Transaction transaction:
        return transaction;
      case String uuid:
        return findFirstSync(
          TransactionFilter(uuids: [uuid], includeDeleted: includeDeleted),
        );
      default:
        return null;
    }
  }

  int countMany(TransactionFilter filter) {
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
    return await ObjectBox().box<Transaction>().putAsync(
      updateTransaction,
      mode: PutMode.update,
    );
  }

  int updateOneSync(Transaction updateTransaction) {
    return ObjectBox().box<Transaction>().put(
      updateTransaction,
      mode: PutMode.update,
    );
  }

  Future<Transaction?> getOne(int id) async {
    return ObjectBox().box<Transaction>().getAsync(id);
  }

  Transaction? getOneSync(int id) {
    return ObjectBox().box<Transaction>().get(id);
  }

  int countAll() {
    return ObjectBox().box<Transaction>().count();
  }

  /// Deletes a transaction by its identifier.
  ///
  /// The identifier can be either an [int] id, a [Transaction] object, or [string] uuid.
  ///
  /// Returns `true` if the transaction existed, and was deleted, `false` otherwise.
  bool deleteSync(dynamic identifier) {
    final Transaction? transaction = findByIdentifierSync(identifier);

    if (transaction == null) {
      return false;
    }

    return ObjectBox().box<Transaction>().remove(transaction.id);
  }

  /// Moves transaction into the trash bin by its identifier.
  ///
  /// The identifier can be either an [int] id, a [Transaction] object, or [string] uuid.
  ///
  /// Returns `true` upon success
  bool moveToBinSync(dynamic identifier) {
    final Transaction? transaction = findByIdentifierSync(identifier);

    if (transaction == null) {
      return false;
    }

    transaction.deletedDate = DateTime.now();
    transaction.isDeleted = true;

    updateOneSync(transaction);

    return true;
  }

  /// Recovers transaction from the trash bin by its identifier.
  ///
  /// The identifier can be either an [int] id, a [Transaction] object, or [string] uuid.
  ///
  /// Returns `true` upon success
  bool recoverFromBinSync(dynamic identifier) {
    final Transaction? transaction = findByIdentifierSync(
      identifier,
      includeDeleted: true,
    );

    if (transaction == null) {
      return false;
    }

    transaction.isDeleted = false;

    updateOneSync(transaction);

    return true;
  }

  bool confirmTransactionSync(
    dynamic identifier, {
    bool confirm = true,
    bool updateTransactionDate = true,
  }) {
    final Transaction? transaction = findByIdentifierSync(identifier);

    if (transaction == null) {
      return false;
    }

    transaction.isPending = !confirm;

    if (updateTransactionDate) {
      transaction.transactionDate = Moment.now();
    }

    updateOneSync(transaction);

    return true;
  }

  Future<void> clearStaleTrashBinEntries() async {
    final int? keepDays = UserPreferencesService().trashBinRetentionDays;

    // Retain forever!
    if (keepDays == null) return;

    if (keepDays <= 0) {
      await emptyTrashBin();
      return;
    }

    final Query<Transaction> staleTrashBinTxns =
        ObjectBox()
            .box<Transaction>()
            .query(
              Transaction_.isDeleted.equals(true) &
                  Transaction_.deletedDate.lessOrEqualDate(
                    Moment.now().subtract(Duration(days: keepDays)),
                  ),
            )
            .build();

    final int deletedCount = await staleTrashBinTxns.removeAsync();

    staleTrashBinTxns.close();

    _log.fine("Deleted $deletedCount stale trash bin entries");
  }

  Future<void> synchronizeNotifications() async {
    final Query<Transaction> qb = pendingTransactionsQb().build();
    final List<Transaction> pendingTransactions = qb.find();
    qb.close();

    await NotificationsService().clearByType(
      FlowNotificationPayloadItemType.transaction,
    );

    await Future.wait(
      pendingTransactions.map(
        (transaction) => NotificationsService()
            .scheduleForPlannedTransaction(transaction)
            .catchError((error) {
              _log.severe(
                "Failed to schedule exact reminder for transaction ${transaction.uuid}",
                error,
              );
            }),
      ),
    ).catchError((error) {
      _log.warning(
        "Scheduling for one or more transactions have been failed",
        error,
      );
      return [];
    });

    final Duration earlyReminder = Duration(
      seconds:
          PendingTransactionsLocalPreferences().earlyReminderInSeconds.get() ??
          0,
    );

    if (earlyReminder.inSeconds > 60) {
      await Future.wait(
        pendingTransactions.map(
          (transaction) => NotificationsService()
              .scheduleForPlannedTransaction(transaction, earlyReminder)
              .then((_) {
                _log.info(
                  "Scheduled early reminder for transaction '${transaction.title ?? 'untitled'}' ${transaction.uuid}",
                );
              })
              .catchError((error) {
                _log.warning(
                  "Failed to schedule an early reminder notification for transaction ${transaction.uuid}",
                  error,
                );
              }),
        ),
      );
    }
  }

  /// Has no effect if it's already paused
  void pauseListeners() {
    _disableUpdates = true;
  }

  /// Has no effect if it's already resumed
  void resumeListeners() {
    _disableUpdates = false;
    _onChange();
  }
}
