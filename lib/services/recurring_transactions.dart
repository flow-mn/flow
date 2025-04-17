import "dart:convert";

import "package:flow/data/transaction_filter.dart";
import "package:flow/entity/recurring_transaction.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/services/transactions.dart";
import "package:recurrence/recurrence.dart";
import "package:uuid/uuid.dart";

class RecurringTransactionsService {
  static RecurringTransactionsService? _instance;

  factory RecurringTransactionsService() =>
      _instance ??= RecurringTransactionsService._internal();

  RecurringTransactionsService._internal() {
    // Constructor
  }

  void _synchronize(RecurringTransaction recurring) async {
    if (recurring.disabled) return;

    final List<Transaction> relatedTransactions = await TransactionsService()
        .findMany(TransactionFilter(extraTag: recurring.uuid));
  }

  void synchronize() {
    final Query<RecurringTransaction> query = activeRecurringsQb().build();

    final List<RecurringTransaction> items = query.find();

    // TODO @sadespresso call _synchronize for each item
    for (var item in items) {
      _synchronize(item);
    }

    query.close();
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
