import "package:flow/entity/recurring_transaction.dart";
import "package:flow/entity/transaction/extensions/default/recurring.dart";

extension RecurringTransactionHelpers on RecurringTransaction {
  String get extensionIdentifierTag =>
      Recurring(
        uuid: uuid,
        initialTransactionDate: DateTime.now(),
      ).extensionIdentifierTag;
}
