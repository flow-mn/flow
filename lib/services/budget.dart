import "package:flow/data/exchange_rates.dart";
import "package:flow/data/single_currency_flow.dart";
import "package:flow/data/string_multi_filter.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/data/transactions_filter/time_range.dart";
import "package:flow/entity/budget.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:logging/logging.dart";
import "package:moment_dart/moment_dart.dart";

final Logger _log = Logger("BudgetService");

class BudgetService {
  static BudgetService? _instance;

  factory BudgetService() => _instance ??= BudgetService._internal();

  BudgetService._internal();

  QueryBuilder<Budget> allQb() =>
      ObjectBox().box<Budget>().query().order(Budget_.createdDate);

  /// Expense transactions that count towards [budget] during [range]
  /// (defaults to the budget's own period).
  ///
  /// A budget with no categories counts every expense.
  QueryBuilder<Transaction> transactionsQb(Budget budget, {TimeRange? range}) {
    final List<String> categoriesUuids = budget.categories
        .map((category) => category.uuid)
        .toList();

    return TransactionFilter(
      range: TransactionFilterTimeRange.fromTimeRange(
        range ?? budget.timeRange,
      ),
      categories: categoriesUuids.isEmpty
          ? null
          : StringMultiFilter.whitelist(categoriesUuids),
      types: const [TransactionType.expense],
    ).queryBuilder();
  }

  /// Sums [transactions] into [budget]'s currency. Pending transactions
  /// don't count towards the budget.
  ///
  /// [SingleCurrencyFlow.hasMissingData] is set when a foreign-currency
  /// transaction couldn't be converted due to missing [rates].
  SingleCurrencyFlow computeSpent(
    Budget budget,
    Iterable<Transaction> transactions,
    ExchangeRates? rates,
  ) {
    return transactions.nonPending.flow.merge(budget.currency, rates);
  }

  /// Advances every auto-renewing budget whose period has ended to the
  /// period containing the current moment. No-op for budgets on a
  /// non-pageable (custom) range.
  ///
  /// Idempotent; safe to call at startup and before rendering budgets.
  ///
  /// Returns the number of budgets that were advanced.
  Future<int> renewDueBudgets() async {
    final DateTime now = DateTime.now();
    final List<Budget> budgets = await ObjectBox().box<Budget>().getAllAsync();
    final List<Budget> renewed = [];

    for (final Budget budget in budgets) {
      if (!budget.renewAutomatically) continue;

      TimeRange range = budget.timeRange;
      if (range is! PageableRange) continue;

      if (!range.to.isBefore(now)) continue;

      while (range.to.isBefore(now)) {
        range = (range as PageableRange).next;
      }

      budget.timeRange = range;
      renewed.add(budget);
    }

    if (renewed.isNotEmpty) {
      await ObjectBox().box<Budget>().putManyAsync(renewed);
      _log.fine("Renewed ${renewed.length} budget(s) to their current period");
    }

    return renewed.length;
  }
}
