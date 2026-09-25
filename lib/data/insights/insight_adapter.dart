import "package:flow/data/exchange_rates.dart";
import "package:flow/data/insights/insight_request.dart";
import "package:flow/data/money.dart";
import "package:flow/entity/recurring_transaction.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/utils/extensions/money.dart";

/// Maps Flow transactions to [InsightTransaction]s in [primaryCurrency].
///
/// Deleted, pending and transfer transactions are left out. Ones that can't
/// be converted are skipped and flagged with `hasMissingRates`.
({List<InsightTransaction> transactions, bool hasMissingRates})
insightTransactionsOf(
  Iterable<Transaction> transactions, {
  required String primaryCurrency,
  required ExchangeRates? rates,
}) {
  final List<InsightTransaction> result = [];
  bool hasMissingRates = false;

  for (final Transaction transaction in transactions) {
    if (transaction.isDeleted == true ||
        transaction.isPending == true ||
        transaction.isTransfer) {
      continue;
    }

    final double? amount = _convert(
      transaction.amount,
      transaction.currency,
      primaryCurrency,
      rates,
    );

    if (amount == null) {
      hasMissingRates = true;
      continue;
    }

    result.add(
      InsightTransaction(
        uuid: transaction.uuid,
        date: transaction.transactionDate.toLocal(),
        amount: amount,
        title: transaction.title,
        categoryUuid: transaction.categoryUuid,
        accountUuid: transaction.accountUuid,
        recurringUuid: transaction.extensions.recurring?.uuid,
      ),
    );
  }

  return (transactions: result, hasMissingRates: hasMissingRates);
}

/// Active, non-transfer recurring transactions as templates. Ones that can't
/// be read or converted are skipped.
List<InsightRecurringTemplate> insightTemplatesOf(
  Iterable<RecurringTransaction> recurringTransactions, {
  required String primaryCurrency,
  required ExchangeRates? rates,
}) {
  final List<InsightRecurringTemplate> result = [];

  for (final RecurringTransaction recurring in recurringTransactions) {
    if (recurring.disabled || recurring.transferToAccountUuid != null) {
      continue;
    }

    final Transaction template;

    try {
      template = recurring.template;
    } catch (_) {
      continue;
    }

    final double? amount = _convert(
      template.amount,
      template.currency,
      primaryCurrency,
      rates,
    );

    if (amount == null) continue;

    result.add(InsightRecurringTemplate(title: template.title, amount: amount));
  }

  return result;
}

double? _convert(
  double amount,
  String currency,
  String primaryCurrency,
  ExchangeRates? rates,
) {
  try {
    return Money(amount, currency).tryConvertAmount(primaryCurrency, rates);
  } catch (_) {
    return null;
  }
}
