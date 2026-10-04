import "package:flow/data/exchange_rates.dart";
import "package:flow/data/insights/insight_adapter.dart";
import "package:flow/data/insights/insight_engine.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/data/transactions_filter/time_range.dart";
import "package:flow/entity/recurring_transaction.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/recurring_transactions.dart";
import "package:flow/services/transactions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flutter/foundation.dart";
import "package:moment_dart/moment_dart.dart";

class InsightsService {
  static InsightsService? _instance;

  factory InsightsService() => _instance ??= InsightsService._internal();

  InsightsService._internal();

  /// Two years, so yearly charges can be seen repeating.
  static const int historyMonths = 26;

  /// Insights for the month containing [month], computed off the main
  /// isolate.
  Future<InsightReport> computeFor(
    DateTime month, {
    Set<InsightType> hiddenTypes = const {},
    List<InsightSighting> sightings = const [],
  }) async {
    final String primaryCurrency = UserPreferencesService().primaryCurrency;
    final ExchangeRates? rates = ExchangeRatesService()
        .getPrimaryCurrencyRates();

    final List<Transaction> transactions = await TransactionsService().findMany(
      TransactionFilter(
        range: TransactionFilterTimeRange.fromTimeRange(
          CustomTimeRange(
            DateTime(month.year, month.month - historyMonths),
            DateTime(month.year, month.month + 1),
          ),
        ),
      ),
    );

    final Query<RecurringTransaction> recurringQuery =
        RecurringTransactionsService().activeRecurringsQb().build();
    final List<RecurringTransaction> recurringTransactions = recurringQuery
        .find();
    recurringQuery.close();

    final ({List<InsightTransaction> transactions, bool hasMissingRates})
    converted = insightTransactionsOf(
      transactions,
      primaryCurrency: primaryCurrency,
      rates: rates,
    );

    return compute(
      computeInsights,
      InsightRequest(
        transactions: converted.transactions,
        month: month,
        now: DateTime.now(),
        recurringTemplates: insightTemplatesOf(
          recurringTransactions,
          primaryCurrency: primaryCurrency,
          rates: rates,
        ),
        hiddenTypes: hiddenTypes,
        sightings: sightings,
        hasMissingRates: converted.hasMissingRates,
      ),
    );
  }
}
