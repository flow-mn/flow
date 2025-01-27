import "dart:math" as math;

import "package:flow/data/exchange_rates.dart";
import "package:flow/data/money.dart";
import "package:flow/data/money_flow.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs.dart";
import "package:moment_dart/moment_dart.dart";

/// Only capable of working with the primary currency
class FlowStandardReport {
  final TimeRange current;
  TimeRange? get previous {
    if (current case PageableRange pageable) {
      return pageable.last;
    }

    return null;
  }

  final Map<int, MoneyFlow<DayTimeRange>> currentFlowByDay;
  final Map<int, MoneyFlow<DayTimeRange>>? previousFlowByDay;

  // current range stuff

  late final Map<int, double> dailyExpenditure;

  late final Money expenseSum;
  late final Money incomeSum;
  late final Money flow;

  late final Money dailyAvgExpenditure;
  late final Money dailyAvgIncome;
  late final Money dailyAvgFlow;

  late final Money dailyMaxExpenditure;
  late final Money dailyMinExpenditure;

  late final Money? currentExpenseSumForecast;

  // [previous] range stuff

  late final Map<int, double>? previousDailyExpenditure;

  late final Money? previousDailyAvgExpenditure;
  late final Money? previousDailyAvgIncome;
  late final Money? previousDailyAvgFlow;

  late final Money? previousExpenseSum;
  late final Money? previousIncomeSum;
  late final Money? previousFlow;

  FlowStandardReport._internal({
    required this.current,
    required this.currentFlowByDay,
    required this.previousFlowByDay,
  }) {
    _init();
  }

  void _init() {
    _initCurrent();
    _initPrev();
  }

  void _initCurrent() {
    final String primaryCurrency = LocalPreferences().getPrimaryCurrency();

    dailyExpenditure = currentFlowByDay.map(
      (key, value) => MapEntry(
        key,
        value.getExpenseByCurrency(primaryCurrency).amount.abs(),
      ),
    );

    expenseSum = -Money(
      currentFlowByDay.values.map((flow) {
        final int dayOffset =
            flow.associatedData!.from.difference(current.from).inDays;
        return dailyExpenditure[dayOffset] ?? 0;
      }).fold(0, (a, b) => a + b),
      primaryCurrency,
    );
    incomeSum = currentFlowByDay.values
        .map((flow) => flow.getIncomeByCurrency(primaryCurrency))
        .fold(Money(0, primaryCurrency), (a, b) => a + b);
    flow = incomeSum + expenseSum;

    int uncountableDays = 0;

    for (int offset = current.duration.inDays; offset > 0; offset--) {
      if (dailyExpenditure[offset] == null || dailyExpenditure[offset] == 0.0) {
        uncountableDays++;
      } else {
        break;
      }
    }

    final int countableDays =
        math.max(1, current.duration.inDays - uncountableDays);

    dailyAvgExpenditure = expenseSum / countableDays.toDouble();
    dailyAvgIncome = incomeSum / countableDays.toDouble();
    dailyAvgFlow = dailyAvgExpenditure + dailyAvgIncome;

    dailyMaxExpenditure = currentFlowByDay.values
        .map((flow) => flow.getExpenseByCurrency(primaryCurrency))
        .fold(Money(0, primaryCurrency), (a, b) => a.amount < b.amount ? a : b);
    dailyMinExpenditure = currentFlowByDay.values
        .map((flow) => flow.getExpenseByCurrency(primaryCurrency))
        .fold(Money(0, primaryCurrency), (a, b) => a.amount > b.amount ? a : b);

    final int daysLeft = current.duration.inDays - countableDays;

    currentExpenseSumForecast =
        expenseSum + (dailyAvgExpenditure * daysLeft.toDouble());
  }

  void _initPrev() {
    final TimeRange? previous = this.previous;

    final bool canInit = previous != null && previousFlowByDay != null;

    if (!canInit) {
      previousDailyAvgExpenditure = null;
      previousDailyAvgIncome = null;
      previousDailyAvgFlow = null;
      previousExpenseSum = null;
      previousIncomeSum = null;
      previousFlow = null;
      return;
    }

    final String primaryCurrency = LocalPreferences().getPrimaryCurrency();

    previousDailyExpenditure = previousFlowByDay?.map(
      (key, value) => MapEntry(
        key,
        value.getExpenseByCurrency(primaryCurrency).amount.abs(),
      ),
    );

    previousExpenseSum = -Money(
      previousFlowByDay!.values.map((flow) {
        final int? dayOffset =
            flow.associatedData?.from.difference(previous.from).inDays;
        return previousDailyExpenditure![dayOffset] ?? 0;
      }).fold(0, (a, b) => a + b),
      primaryCurrency,
    );
    previousIncomeSum = previousFlowByDay!.values
        .map((flow) => flow.getIncomeByCurrency(primaryCurrency))
        .fold(Money(0, primaryCurrency), (a, b) => a == null ? b : (a + b));
    previousFlow = previousIncomeSum! + previousExpenseSum!;

    int uncountableDays = 0;

    for (int offset = previous.duration.inDays; offset > 0; offset--) {
      if (previousDailyExpenditure![offset] == null ||
          previousDailyExpenditure![offset] == 0.0) {
        uncountableDays++;
      } else {
        break;
      }
    }

    final int previousCountableDays = previousDailyExpenditure == null
        ? 1
        : math.max(
            1,
            previous.duration.inDays - uncountableDays,
          );

    previousDailyAvgExpenditure =
        previousExpenseSum! / previousCountableDays.toDouble();
    previousDailyAvgIncome =
        previousIncomeSum! / previousCountableDays.toDouble();
    previousDailyAvgFlow =
        previousDailyAvgExpenditure! + previousDailyAvgIncome!;
  }

  /// When [rates] is not available, ignores all other currencies.
  ///
  /// It's a good idea to show a notice to the user that the report is not accurate.
  static Future<FlowStandardReport> generate(
    TimeRange range,
    ExchangeRates? rates,
  ) async {
    final Map<int, MoneyFlow<DayTimeRange>> currentFlowByDay =
        await _reportMonthRangeFlowByDayInPrimaryCurrencyOnly(range, rates);
    final Map<int, MoneyFlow<DayTimeRange>>? previousFlowByDay =
        switch (range) {
      PageableRange pageable =>
        await _reportMonthRangeFlowByDayInPrimaryCurrencyOnly(
            pageable.last, rates),
      _ => null,
    };

    return FlowStandardReport._internal(
      current: range,
      currentFlowByDay: currentFlowByDay,
      previousFlowByDay: previousFlowByDay,
    );
  }

  static Future<Map<int, MoneyFlow<DayTimeRange>>>
      _reportMonthRangeFlowByDayInPrimaryCurrencyOnly(
          TimeRange range, ExchangeRates? rates) async {
    final String primaryCurrency = LocalPreferences().getPrimaryCurrency();

    final List<Transaction> transactions =
        await ObjectBox().transcationsByRange(range);

    final Map<int, MoneyFlow<DayTimeRange>> result = {};

    for (final Transaction transaction in transactions) {
      if (transaction.isTransfer) continue;

      final DayTimeRange day =
          DayTimeRange.fromDateTime(transaction.transactionDate);
      final int dayOffset = day.from.difference(range.from).inDays.abs();

      result[dayOffset] ??= MoneyFlow(associatedData: day);

      if (transaction.currency == primaryCurrency) {
        result[dayOffset]!.add(transaction.money);
      } else if (rates != null) {
        result[dayOffset]!
            .add(transaction.money.convert(primaryCurrency, rates));
      }
    }

    return result;
  }
}
