import "package:flow/data/money.dart";
import "package:flow/data/money_flow.dart";
import "package:flow/prefs.dart";
import "package:moment_dart/moment_dart.dart";

/// Only capable of working with the primary currency
class FlowStandardReport {
  final MonthTimeRange current;
  final MonthTimeRange? previous;

  final Map<int, MoneyFlow<DayTimeRange>> currentFlowByDay;
  final Map<int, MoneyFlow<DayTimeRange>>? previousFlowByDay;

  late final Map<int, double> dailyExpenditure;
  late final Map<int, double>? previousDailyExpenditure;

  late final Money expenseSum;
  late final Money incomeSum;
  late final Money flow;

  late final Money dailyAvgExpenditure;
  late final Money dailyAvgIncome;
  late final Money dailyAvgFlow;

  late final Money dailyMaxExpenditure;
  late final Money dailyMinExpenditure;

  late final Money? previousExpenseSum;
  late final Money? currentExpenseSumForecast;

  FlowStandardReport({
    required this.current,
    required this.previous,
    required this.currentFlowByDay,
    required this.previousFlowByDay,
  }) {
    final String primaryCurrency = LocalPreferences().getPrimaryCurrency();

    dailyExpenditure = currentFlowByDay.map(
      (key, value) => MapEntry(
        key,
        value.getExpenseByCurrency(primaryCurrency).amount.abs(),
      ),
    );
    previousDailyExpenditure = previousFlowByDay?.map(
      (key, value) => MapEntry(
        key,
        value.getExpenseByCurrency(primaryCurrency).amount.abs(),
      ),
    );

    expenseSum = -Money(
      currentFlowByDay.values
          .map((flow) =>
              dailyExpenditure[flow.associatedData?.from.date.day] ?? 0)
          .reduce((a, b) => a + b),
      primaryCurrency,
    );
    incomeSum = currentFlowByDay.values
        .map((flow) => flow.getIncomeByCurrency(primaryCurrency))
        .reduce((a, b) => a + b);
    flow = incomeSum + expenseSum;

    dailyAvgExpenditure = expenseSum / current.duration.inDays.toDouble();
    dailyAvgIncome = incomeSum / current.duration.inDays.toDouble();
    dailyAvgFlow = dailyAvgExpenditure + dailyAvgIncome;

    dailyMaxExpenditure = currentFlowByDay.values
        .map((flow) => flow.getExpenseByCurrency(primaryCurrency))
        .reduce((a, b) => a.amount < b.amount ? a : b);
    dailyMinExpenditure = currentFlowByDay.values
        .map((flow) => flow.getExpenseByCurrency(primaryCurrency))
        .reduce((a, b) => a.amount > b.amount ? a : b);

    if (previousFlowByDay != null && previousDailyExpenditure != null) {
      previousExpenseSum = -Money(
        previousFlowByDay!.values
            .map((flow) =>
                previousDailyExpenditure![flow.associatedData?.from.date.day] ??
                0)
            .reduce((a, b) => a + b),
        primaryCurrency,
      );
    }

    final int daysLeft = current.duration.inDays -
        current.from.difference(DateTime.now()).inDays;

    currentExpenseSumForecast =
        expenseSum + (dailyAvgExpenditure * daysLeft.toDouble());
  }
}
