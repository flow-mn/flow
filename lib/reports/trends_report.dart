import "package:flow/data/money.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/reports/report.dart";

class TrendsReport extends FlowReport {
  final List<Transaction> transactions;

  /// Map of case insensitive title, count of transactions for that title
  final Map<String, int> titlesByFrequency = {};
  final Map<int, int> expenseByWeekday = {};

  List<MapEntry<String, int>> get sortedTitlesByFrequency =>
      titlesByFrequency.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

  int? get topSpendingWeekday {
    if (expenseByWeekday.isEmpty) {
      return null;
    }

    final List<MapEntry<int, int>> sortedEntries =
        expenseByWeekday.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.first.key;
  }

  late final Money medianExpensePerTransaction;
  late final Money averageExpensePerTransaction;

  bool _showMissingExchangeRatesWarning = false;

  TrendsReport({
    required super.rates,
    required super.primaryCurrency,
    required this.transactions,
  }) {
    _init();
  }

  void _init() {
    final List<double> expenses = [];

    for (final Transaction transaction in transactions) {
      if (transaction.isDeleted == true) {
        continue;
      }

      if (transaction.isPending == true) {
        continue;
      }

      if (transaction.isTransfer) {
        continue;
      }

      if (transaction.type == TransactionType.expense) {
        if (transaction.currency == primaryCurrency) {
          expenses.add(transaction.amount);
        } else {
          if (rates == null) {
            _showMissingExchangeRatesWarning = true;
          } else {
            try {
              expenses.add(
                Money.convertDouble(
                  transaction.currency,
                  primaryCurrency,
                  transaction.amount,
                  rates!,
                ),
              );
            } catch (e) {
              _showMissingExchangeRatesWarning = true;
            }
          }
        }
      }

      final String? key = transaction.title?.trim().toLowerCase();

      if (key == null || key.isEmpty) {
        continue;
      }

      if (titlesByFrequency[key] == null) {
        titlesByFrequency[key] = 1;
      } else {
        titlesByFrequency[key] = titlesByFrequency[key]! + 1;
      }
    }

    expenses.sort();

    medianExpensePerTransaction = Money(
      _calculateMedianExpense(expenses),
      primaryCurrency,
    );
    averageExpensePerTransaction = Money(
      expenses.fold(0.0, (a, b) => a + b) / expenses.length,
      primaryCurrency,
    );
  }

  double _calculateMedianExpense(List<double> expenses) {
    if (expenses.isEmpty) {
      return 0.0;
    }

    if (expenses.length.isEven) {
      final int midIndex = expenses.length ~/ 2;
      return (expenses[midIndex] + expenses[midIndex - 1]) * 0.5;
    }

    return expenses[expenses.length ~/ 2];
  }

  @override
  bool get showMissingExchangeRatesWarning => _showMissingExchangeRatesWarning;
}
