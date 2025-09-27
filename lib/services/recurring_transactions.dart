import "dart:async";
import "dart:convert";
import "dart:math";

import "package:flow/data/transaction_filter.dart";
import "package:flow/data/transactions_filter/time_range.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/recurring_transaction.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction/extensions/default/recurring.dart";
import "package:flow/entity/transaction_tag.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/routes/transaction_page/select_recurring_update_mode_sheet.dart";
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
    _synchronizeAll();
  }

  Future<void> _synchronize(
    RecurringTransaction recurringTransaction, {
    DateTime? anchor,
  }) async {
    anchor ??= DateTime.now();

    final String loggingPrefix =
        "Recurring(${recurringTransaction.template.title} ${recurringTransaction.uuid})";

    try {
      _log.fine("$loggingPrefix Synchronizing recurring transaction");

      if (recurringTransaction.disabled) {
        _log.fine("$loggingPrefix Recurring transaction is disabled, skipping");
        return;
      }

      final TimeRange? range = recurringTransaction.lastGeneratedTransactionDate
          ?.rangeToMax()
          .intersect(recurringTransaction.recurrence.range);

      final DateTime nextOccurenceAnchor =
          recurringTransaction.lastGeneratedTransactionDate ??
          DateTime.fromMicrosecondsSinceEpoch(
            min(
              anchor.date.microsecondsSinceEpoch,
              recurringTransaction
                  .recurrence
                  .range
                  .from
                  .date
                  .microsecondsSinceEpoch,
            ),
          ).copyWith(
            hour: recurringTransaction.timeRange.from.hour,
            minute: recurringTransaction.timeRange.from.minute,
            second: recurringTransaction.timeRange.from.second,
            millisecond: recurringTransaction.timeRange.from.millisecond,
            microsecond: 0,
          );

      final DateTime? nextOccurence = recurringTransaction.recurrence
          .nextAbsoluteOccurrence(nextOccurenceAnchor, subrange: range)
          ?.startOfMillisecond();

      if (nextOccurence == null) {
        _log.fine(
          "$loggingPrefix No next occurrence for recurring transaction; range is $range; last generated transaction's transaction date is ${recurringTransaction.lastGeneratedTransactionDate}",
        );
        return;
      }

      if (recurringTransaction.lastGeneratedTransactionDate != null &&
          (nextOccurence.startOfMillisecond() <=
                  recurringTransaction.lastGeneratedTransactionDate!
                      .startOfMillisecond() ||
              recurringTransaction.lastGeneratedTransactionDate! >= anchor)) {
        _log.fine(
          "$loggingPrefix Next occurrence is before last generated transaction date: ${recurringTransaction.lastGeneratedTransactionDate}, skipping",
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
        (a, b) => a.extensions.recurring!.initialTransactionDate.compareTo(
          b.extensions.recurring!.initialTransactionDate,
        ),
      );

      final DateTime lastGeneratedTransactionDate = relatedTransactions.isEmpty
          ? Moment.minValue
          : relatedTransactions
                .last
                .extensions
                .recurring!
                .initialTransactionDate
                .startOfMillisecond();

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
      final Account? to = transferToAccountUuid != null
          ? await AccountsService().findOne(transferToAccountUuid)
          : null;

      late final Category? category;

      late final List<TransactionTag>? tags;

      if (template.categoryUuid != null) {
        final categoryQuery = ObjectBox()
            .box<Category>()
            .query(Category_.uuid.equals(template.categoryUuid!))
            .build();

        category = categoryQuery.findFirst();

        categoryQuery.close();
      } else {
        category = null;
      }

      if (template.tagsUuids.isNotEmpty) {
        final transactionTags = ObjectBox()
            .box<TransactionTag>()
            .query(TransactionTag_.uuid.oneOf(template.tagsUuids))
            .build();

        tags = transactionTags.find();

        transactionTags.close();
      } else {
        tags = null;
      }

      if (from == null) {
        _log.severe(
          "$loggingPrefix Failed to find account for transaction template: ${template.accountUuid}",
        );
        throw StateError(
          "$loggingPrefix From account not found: ${template.accountUuid}",
        );
      }

      final bool isPending = nextOccurence.isAfter(anchor)
          ? PendingTransactionsLocalPreferences().requireConfrimation.get()
          : false;

      if (to == null) {
        from.createAndSaveTransaction(
          amount: template.amount,
          category: category,
          tags: tags,
          title: template.title,
          description: template.description,
          subtype: template.transactionSubtype,
          transactionDate: nextOccurence,
          uuidOverride: generatedTransactionUuid,
          extensions: [
            Recurring(
              initialTransactionDate: nextOccurence,
              uuid: recurringTransaction.uuid,
              relatedTransactionUuid: generatedTransactionUuid,
            ),
          ],
          isPending: isPending,
        );

        _log.fine(
          "$loggingPrefix Generated transaction: $generatedTransactionUuid",
        );
      } else {
        final (int fromObjectId, int toObjectId) = from.transferTo(
          targetAccount: to,
          tags: tags,
          amount: template.amount.abs(),
          title: template.title,
          description: template.description,
          transactionDate: nextOccurence,
          extensions: [
            Recurring(
              uuid: recurringTransaction.uuid,
              initialTransactionDate: nextOccurence,
            ),
          ],
          isPending: isPending,
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

      if (nextOccurence.isBefore(anchor)) {
        _log.fine(
          "$loggingPrefix Next occurrence is before anchor: $anchor, trying to create another one",
        );

        await _synchronize(recurringTransaction);
      }

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
  Future<void> _synchronizeAll() async {
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

    _synchronizeAll();

    return recurringTransaction;
  }

  Future<RecurringTransaction?> findOne(dynamic identifier) async {
    if (identifier is int) {
      return await ObjectBox().box<RecurringTransaction>().getAsync(identifier);
    }

    if (identifier case String uuid) {
      final Query<RecurringTransaction> query = ObjectBox()
          .box<RecurringTransaction>()
          .query(RecurringTransaction_.uuid.equals(uuid))
          .build();

      final RecurringTransaction? recurringTransaction = await query
          .findFirstAsync();

      query.close();

      return recurringTransaction;
    }

    return null;
  }

  RecurringTransaction? findOneSync(dynamic identifier) {
    if (identifier is int) {
      return ObjectBox().box<RecurringTransaction>().get(identifier);
    }

    if (identifier case String uuid) {
      final Query<RecurringTransaction> query = ObjectBox()
          .box<RecurringTransaction>()
          .query(RecurringTransaction_.uuid.equals(uuid))
          .build();

      final RecurringTransaction? recurringTransaction = query.findFirst();

      query.close();

      return recurringTransaction;
    }

    return null;
  }

  Future<void> update(RecurringTransaction recurringTransaction) async {
    await ObjectBox().box<RecurringTransaction>().putAsync(
      recurringTransaction,
      mode: PutMode.update,
    );

    unawaited(_synchronize(recurringTransaction));
  }

  void updateSync(RecurringTransaction recurringTransaction) {
    ObjectBox().box<RecurringTransaction>().put(
      recurringTransaction,
      mode: PutMode.update,
    );

    unawaited(_synchronize(recurringTransaction));
  }

  Future<bool> delete(dynamic identifier) async {
    final RecurringTransaction? recurringTransaction = await findOne(
      identifier,
    );

    if (recurringTransaction == null) {
      _log.warning(
        "Couldn't delete recurring transaction because it was not found",
      );
      return false;
    }

    final List<Transaction> transactions = await TransactionsService().findMany(
      TransactionFilter(extraTag: recurringTransaction.extensionIdentifierTag),
    );

    if (transactions.isNotEmpty) {
      _log.warning(
        "Recurring transaction (${recurringTransaction.uuid}) has ${transactions.length} transactions, cannot delete",
      );
      return false;
    }

    return await ObjectBox().box<RecurringTransaction>().removeAsync(
      recurringTransaction.id,
    );
  }

  /// Throws [ArgumentError] if the transaction does not have a recurring
  /// extension.
  ///
  /// Throws [StateError] if the recurring transaction is not found.
  ///
  /// Returns a list of transactions that are related to the given transaction
  Future<(RecurringTransaction, List<Transaction>)>
  findRelatedTransactionsByMode(
    Transaction transaction,
    RecurringUpdateMode mode,
  ) async {
    final Recurring? recurringExt = transaction.extensions.recurring;

    if (recurringExt == null) {
      throw ArgumentError("Transaction does not have a recurring extension");
    }

    final RecurringTransaction? recurringTransaction = await findOne(
      recurringExt.uuid,
    );

    if (recurringTransaction == null) {
      throw StateError(
        "Recurring transaction not found for transaction: ${transaction.uuid}",
      );
    }

    if (mode == RecurringUpdateMode.current) {
      return (recurringTransaction, [transaction]);
    }

    final List<Transaction> transactions = await TransactionsService().findMany(
      TransactionFilter(
        extraTag: recurringTransaction.extensionIdentifierTag,
        range: mode == RecurringUpdateMode.all
            ? null
            : TransactionFilterTimeRange.fromTimeRange(
                transaction.transactionDate.rangeToMax(),
              ),
      ),
    );

    return (recurringTransaction, transactions);
  }
}
