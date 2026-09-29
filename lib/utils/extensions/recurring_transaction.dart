import "package:flow/entity/recurring_transaction.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction/extensions/default/recurring.dart";

extension RecurringTransactionHelpers on RecurringTransaction {
  String get extensionIdentifierTag => Recurring(
    uuid: uuid,
    initialTransactionDate: DateTime.now(),
  ).extensionIdentifierTag;

  /// Amount for the next occurrence. With [variableAmount], it's the latest
  /// confirmed amount among [logged], falling back to the [template]'s.
  double estimateAmount(Transaction template, Iterable<Transaction> logged) {
    if (!variableAmount) return template.amount;

    Transaction? latest;

    for (final Transaction transaction in logged) {
      if (transaction.isPending == true || transaction.isDeleted == true) {
        continue;
      }
      // Transfers log both sides; the template is the outgoing one
      if (transaction.isTransfer && !transaction.amount.isNegative) continue;

      if (latest == null ||
          transaction.transactionDate.isAfter(latest.transactionDate)) {
        latest = transaction;
      }
    }

    return latest?.amount ?? template.amount;
  }
}
