import "dart:developer";

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

  factory TransactionsService() =>
      _instance ??= TransactionsService._internal();

  TransactionsService._internal() {
    ObjectBox().box<Transaction>().query().watch().listen((event) {
      _onChange();
    });
  }

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

  QueryBuilder<Transaction> pendingTransactionsQb([DateTime? anchor]) {
    anchor = DateTime.now();

    return ObjectBox()
        .box<Transaction>()
        .query(Transaction_.transactionDate
            .greaterThanDate(anchor.startOfNextMinute())
            .or(Transaction_.isPending.equals(true)))
        .order(Transaction_.transactionDate);
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
