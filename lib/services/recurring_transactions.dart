import "dart:convert";

import "package:flow/data/transaction_filter.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/recurring_transaction.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction/extensions/default/recurring.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/services/accounts.dart";
import "package:flow/services/transactions.dart";
import "package:flow/utils/extensions/recurring_transaction.dart";
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

  Future<void> _synchronize(RecurringTransaction recurringTransaction) async {
    final String loggingPrefix = "Recurring(${recurringTransaction.uuid})";

    try {
      _log.fine("$loggingPrefix Synchronizing recurring transaction");

      if (recurringTransaction.disabled) {
        _log.fine("$loggingPrefix Recurring transaction is disabled, skipping");
        return;
      }

      final TimeRange? range =
          recurringTransaction.lastGeneratedTransactionDate?.rangeToMax();

      final DateTime now = DateTime.now().date;

      final DateTime? nextOccurence =
          recurringTransaction.recurrence
              .nextAbsoluteOccurrence(
                now.copyWith(
                  hour: recurringTransaction.timeRange.from.hour,
                  minute: recurringTransaction.timeRange.from.minute,
                  second: recurringTransaction.timeRange.from.second,
                  millisecond: recurringTransaction.timeRange.from.millisecond,
                  microsecond: 0,
                ),
                range: range,
              )
              ?.startOfMillisecond();

      if (nextOccurence == null) {
        _log.fine(
          "$loggingPrefix No next occurrence for recurring transaction; range is $range; last generated transaction's transaction date is ${recurringTransaction.lastGeneratedTransactionDate}",
        );
        return;
      }

      final List<Transaction> relatedTransactions = await TransactionsService()
          .findMany(
            TransactionFilter(
              extraTag: recurringTransaction.extensionIdentifierTag,
            ),
          );

      relatedTransactions.sort(
        (a, b) => a.transactionDate.compareTo(b.transactionDate),
      );

      final DateTime lastGeneratedTransactionDate =
          relatedTransactions.isEmpty
              ? Moment.minValue
              : relatedTransactions.last.transactionDate.startOfMillisecond();

      if (lastGeneratedTransactionDate >= nextOccurence) {
        _log.fine(
          "$loggingPrefix Next occurrence is before last generated transaction date: $lastGeneratedTransactionDate, skipping",
        );
        return;
      }

      final String generatedTransactionUuid = const Uuid().v4();

      final Transaction template = recurringTransaction.template;

      final String? transferToAccountUuid =
          recurringTransaction.transferToAccountUuid;

      final Account? from = await AccountsService().findOne(
        template.accountUuid,
      );
      final Account? to =
          transferToAccountUuid != null
              ? await AccountsService().findOne(transferToAccountUuid)
              : null;

      if (from == null) {
        _log.severe(
          "$loggingPrefix Failed to find account for transaction template: ${template.accountUuid}",
        );
        throw StateError(
          "$loggingPrefix From account not found: ${template.accountUuid}",
        );
      }

      if (to == null) {
        from.createAndSaveTransaction(
          amount: template.amount,
          title: template.title,
          description: template.description,
          transactionDate: nextOccurence,
          uuidOverride: generatedTransactionUuid,
          extensions: [
            Recurring(
              initialTransactionDate: nextOccurence,
              uuid: recurringTransaction.uuid,
              relatedTransactionUuid: generatedTransactionUuid,
            ),
          ],
          isPending: true,
        );

        _log.fine(
          "$loggingPrefix Generated transaction: $generatedTransactionUuid",
        );
      } else {
        final (int fromObjectId, int toObjectId) = from.transferTo(
          targetAccount: to,
          amount: template.amount,
          title: template.title,
          description: template.description,
          transactionDate: nextOccurence,
          extensions: [
            Recurring(
              uuid: recurringTransaction.uuid,
              initialTransactionDate: nextOccurence,
            ),
          ],
          isPending: true,
        );

        _log.fine(
          "$loggingPrefix Generated transfer transactions, idk where is the UUID, but here is the local ids: $fromObjectId, $toObjectId",
        );
      }

      recurringTransaction.lastGeneratedTransactionDate = nextOccurence;

      ObjectBox().box<RecurringTransaction>().put(
        recurringTransaction,
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
    );

    ObjectBox().box<RecurringTransaction>().put(recurringTransaction);

    return recurringTransaction;
  }
}
