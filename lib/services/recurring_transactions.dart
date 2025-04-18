import "dart:convert";

import "package:flow/data/transaction_filter.dart";
import "package:flow/entity/recurring_transaction.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction/extensions/default/recurring.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/services/transactions.dart";
import "package:logging/logging.dart";
import "package:moment_dart/moment_dart.dart";
import "package:recurrence/recurrence.dart";
import "package:uuid/uuid.dart";

final Logger _log = Logger("RecurringTransactionsService");

class RecurringTransactionsService {
  static RecurringTransactionsService? _instance;

  factory RecurringTransactionsService() =>
      _instance ??= RecurringTransactionsService._internal();

  RecurringTransactionsService._internal() {
    synchronize();

    TransactionsService().addListener(() => synchronize());
  }

  Future<void> _synchronize(RecurringTransaction recurring) async {
    final String loggingPrefix = "Recurring(${recurring.uuid})";

    try {
      _log.fine("$loggingPrefix Synchronizing recurring transaction");

      if (recurring.disabled) {
        _log.fine("$loggingPrefix Recurring transaction is disabled, skipping");
        return;
      }

      final TimeRange? range =
          recurring.lastGeneratedTransactionDate?.rangeToMax();

      final DateTime? nextOccurence = recurring.recurrence
          .nextAbsoluteOccurrence(
            DateTime.now().copyWith(
              hour: recurring.timeRange.from.hour,
              minute: recurring.timeRange.from.minute,
              second: recurring.timeRange.from.second,
              millisecond: recurring.timeRange.from.millisecond,
              microsecond: recurring.timeRange.from.microsecond,
            ),
            range: range,
          );

      if (nextOccurence == null) {
        _log.fine(
          "$loggingPrefix No next occurrence for recurring transaction; range is $range; last generated transaction's transaction date is ${recurring.lastGeneratedTransactionDate}",
        );
        return;
      }

      final List<Transaction> relatedTransactions = await TransactionsService()
          .findMany(TransactionFilter(extraTag: recurring.uuid));

      relatedTransactions.sort(
        (a, b) => a.transactionDate.compareTo(b.transactionDate),
      );

      final DateTime lastGeneratedTransactionDate =
          relatedTransactions.isEmpty
              ? Moment.minValue
              : relatedTransactions.last.transactionDate;

      if (lastGeneratedTransactionDate.isAfter(nextOccurence)) {
        _log.fine(
          "$loggingPrefix Next occurrence is before last generated transaction date: $lastGeneratedTransactionDate, skipping",
        );
        return;
      }

      final String generatedTransactionUuid = const Uuid().v4();

      final Transaction transaction =
          recurring.template
            ..uuid = generatedTransactionUuid
            ..createdDate = DateTime.now()
            ..transactionDate = nextOccurence;
      if (!transaction.extraTags.contains(recurring.uuid)) {
        transaction.extraTags.add(recurring.uuid);
      }
      transaction.extensions.recurring ??= Recurring(
        uuid: recurring.uuid,
        relatedTransactionUuid: generatedTransactionUuid,
        locked: true,
      );

      await TransactionsService().upsertOne(transaction);
      _log.fine(
        "$loggingPrefix Generated transaction: $generatedTransactionUuid",
      );

      recurring.lastGeneratedTransactionDate = nextOccurence;
      recurring.lastGeneratedTransactionUuid = generatedTransactionUuid;

      ObjectBox().box<RecurringTransaction>().put(
        recurring,
        mode: PutMode.update,
      );

      _log.fine(
        "$loggingPrefix Updated recurring transaction with last generated transaction date: $nextOccurence",
      );
    } catch (e, stackTrace) {
      _log.severe(
        "$loggingPrefix Failed to synchronize recurring transaction",
        e,
        stackTrace,
      );
    }
  }

  /// This function will only generate necessary transaction, and is meant to
  /// be called over and over again.
  ///
  /// Current rule is one transaction in the future for the recurrence.
  Future<void> synchronize() async {
    _log.fine("Synchronizing recurring transactions");

    final Query<RecurringTransaction> query = activeRecurringsQb().build();

    final List<RecurringTransaction> items = query.find();

    try {
      for (var item in items) {
        await _synchronize(item);
      }
    } finally {
      query.close();
    }
  }

  QueryBuilder<RecurringTransaction> activeRecurringsQb() {
    final Condition<RecurringTransaction> condition = RecurringTransaction_
        .disabled
        .isNull()
        .or(RecurringTransaction_.disabled.notEquals(true));

    return ObjectBox().box<RecurringTransaction>().query(condition);
  }

  RecurringTransaction createFromTransaction({
    required dynamic identifier,
    required Recurrence recurrence,
    String? uuidOverride,
    String? transferToAccountUuid,
  }) {
    if (identifier == null) {
      throw ArgumentError("identifier must be a Transaction or an identifier");
    }

    late final Transaction? transaction;

    if (identifier is Transaction) {
      transaction = identifier;
    } else {
      transaction = TransactionsService().findByIdentifierSync(identifier);
    }

    if (transaction == null) {
      throw ArgumentError("Transaction not found for identifier: $identifier");
    }

    final RecurringTransaction recurringTransaction = RecurringTransaction(
      uuid: uuidOverride ?? const Uuid().v4(),
      jsonTransactionTemplate: jsonEncode(transaction.toJson()),
      transferToAccountUuid: transferToAccountUuid,
      range: recurrence.range.encodeShort(),
      rules: recurrence.rules.map((e) => e.serialize()).toList(),
      lastGeneratedTransactionDate: transaction.transactionDate,
      lastGeneratedTransactionUuid: transaction.uuid,
    );

    ObjectBox().box<RecurringTransaction>().put(recurringTransaction);

    return recurringTransaction;
  }
}
