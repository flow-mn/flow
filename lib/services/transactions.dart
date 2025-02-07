import "dart:developer";

import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/pending_transactions.dart";
import "package:flow/services/notifications.dart";
import "package:moment_dart/moment_dart.dart";

class TransactionsService {
  static TransactionsService? _instance;

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
}
