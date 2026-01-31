import "package:flow/data/money.dart";
import "package:flow/data/multi_currency_flow.dart";
import "package:flow/data/single_currency_flow.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/reports/report.dart";

/// A report that summarizes transactions in a given time range by intervals.
///
/// Everything is in the given [primaryCurrency]
class IntervalFlowReport extends FlowReport {
  final RangeData rangeData;
  final Duration interval;

  /// Map of start of range, [MultiCurrencyFlow]
  ///
  /// Uses [Namespace.nil] for uncategorized transactions
  final Map<DateTime, SingleCurrencyFlow> data = {};

  /// Average of sum by interval, in the primary currency.
  late double _averageIncome;
  late double _averageExpense;
  late double _averageFlow;

  /// Average of sum by interval, in the primary currency.
  late double _totalIncome;
  late double _totalExpense;
  late double _totalFlow;

  Money get averageIncome => Money(_averageIncome, primaryCurrency);
  Money get averageExpense => Money(_averageExpense, primaryCurrency);
  Money get averageFlow => Money(_averageFlow, primaryCurrency);
  Money get totalIncome => Money(_totalIncome, primaryCurrency);
  Money get totalExpense => Money(_totalExpense, primaryCurrency);
  Money get totalFlow => Money(_totalFlow, primaryCurrency);

  bool _showMissingExchangeRatesWarning = false;

  IntervalFlowReport({
    required this.interval,
    required this.rangeData,
    required super.rates,
    required super.primaryCurrency,
  }) {
    _init();
  }

  @override
  bool get showMissingExchangeRatesWarning => _showMissingExchangeRatesWarning;

  void _init() {
    bool hasNonPrimaryCurrency = false;

    for (final Transaction transaction in rangeData.transactions) {
      if (transaction.isDeleted == true) {
        continue;
      }

      if (transaction.isTransfer == true) {
        continue;
      }

      if (!rangeData.range.contains(transaction.transactionDate)) {
        continue;
      }

      if (transaction.currency != primaryCurrency) {
        hasNonPrimaryCurrency = true;
      }

      final (DateTime associatedInterval, int index) = getInterval(
        transaction.transactionDate,
      );

      data[associatedInterval] ??= SingleCurrencyFlow();
      data[associatedInterval]!.add(transaction.money, rates);
    }

    if (hasNonPrimaryCurrency && rates == null) {
      _showMissingExchangeRatesWarning = true;
    }

    _totalIncome = 0.0;
    _totalExpense = 0.0;
    _totalFlow = 0.0;

    final List<DateTime> sortedKeys = data.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    int? firstTransactionIndex;
    int? lastTransactionIndex;

    for (int i = 0; i < sortedKeys.length; i++) {
      final DateTime startOfInterval = sortedKeys[i];
      final SingleCurrencyFlow flow = data[startOfInterval]!;

      if (firstTransactionIndex == null && flow.flow != 0) {
        firstTransactionIndex = i;
      }

      if (lastTransactionIndex == null || i > lastTransactionIndex) {
        if (flow.flow != 0) {
          lastTransactionIndex = i;
        }
      }

      _totalIncome += flow.incomeSum;

      _totalExpense += flow.expenseSum;

      _totalFlow += flow.flow;
    }

    final int intervalCount =
        (rangeData.range.duration.inMicroseconds / interval.inMicroseconds)
            .ceil();

    final int totalTransactionCount =
        ((lastTransactionIndex ?? 0) - (firstTransactionIndex ?? 0) + 1).clamp(
          1,
          intervalCount,
        );

    _averageIncome = _totalIncome / totalTransactionCount.toDouble();
    _averageExpense = _totalExpense / totalTransactionCount.toDouble();
    _averageFlow = _totalFlow / totalTransactionCount.toDouble();
  }

  (DateTime, int) getInterval(DateTime transactionDate) {
    final int value =
        transactionDate.millisecondsSinceEpoch -
        rangeData.range.from.millisecondsSinceEpoch;

    final int intervalValue = value ~/ interval.inMilliseconds;

    final DateTime startOfInterval = DateTime.fromMillisecondsSinceEpoch(
      rangeData.range.from.millisecondsSinceEpoch +
          (intervalValue * interval.inMilliseconds),
    );

    return (startOfInterval, intervalValue);
  }
}
