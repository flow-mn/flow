import 'package:flow/data/money.dart';
import 'package:flow/entity/transaction.dart';

class MoneyFlow<T> implements Comparable<MoneyFlow> {
  final T? associatedData;

  final String currency;

  double totalExpense;
  double totalIncome;

  double get flow => totalExpense + totalIncome;

  bool get isEmpty => totalExpense.abs() == 0.0 && totalIncome.abs() == 0.0;

  MoneyFlow({
    required this.currency,
    this.associatedData,
    this.totalExpense = 0.0,
    this.totalIncome = 0.0,
  });

  @override
  int compareTo(MoneyFlow other) {
    return flow.compareTo(other.flow);
  }

  void addMoney(Money money) => add(money.amount, money.currency);

  void addExpense(double expense, String currency) =>
      totalExpense += Money.convertDouble(
        currency,
        this.currency,
        expense,
      );
  void addIncome(double income, String currency) =>
      totalIncome += Money.convertDouble(
        currency,
        this.currency,
        income,
      );
  void add(double amount, String currency) => amount.isNegative
      ? addExpense(amount, currency)
      : addIncome(amount, currency);

  double getTotalByType(TransactionType type) => switch (type) {
        TransactionType.expense => totalExpense,
        TransactionType.income => totalIncome,
        TransactionType.transfer => 0,
      };

  operator +(MoneyFlow other) {
    return MoneyFlow(
      totalExpense: totalExpense +
          Money.convertDouble(other.currency, currency, other.totalExpense),
      totalIncome: totalIncome +
          Money.convertDouble(other.currency, currency, other.totalIncome),
      currency: currency,
    );
  }

  operator -(MoneyFlow other) {
    return MoneyFlow(
      totalExpense: totalExpense -
          Money.convertDouble(other.currency, currency, other.totalExpense),
      totalIncome: totalIncome -
          Money.convertDouble(other.currency, currency, other.totalIncome),
      currency: currency,
    );
  }

  operator -() {
    return MoneyFlow(
      totalExpense: -totalExpense,
      totalIncome: -totalIncome,
      currency: currency,
    );
  }
}
