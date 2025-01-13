import "dart:developer";

import "package:flow/data/currencies.dart";
import "package:flow/data/exchange_rates.dart";
import "package:flow/data/money.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/prefs.dart";

class MultiCurrencyMoneyFlow<T> {
  final T? associatedData;

  final Map<String, double> _totalExpenseByCurrency = {};
  final Map<String, double> _totalIncomeByCurrency = {};

  int expenseCount = 0;
  int incomeCount = 0;

  String? get singleCurrency {
    if (_totalExpenseByCurrency.keys.length != 1) return null;
    if (_totalIncomeByCurrency.keys.length != 1) return null;

    return _totalExpenseByCurrency.keys.single;
  }

  MultiCurrencyMoneyFlow({this.associatedData});

  void add(Money money) {
    final double amount = money.amount;
    final String currency = money.currency.trim().toUpperCase();

    if (amount.abs() == 0.0) {
      log("[MoneyFlow] Ignoring zero entry");
      return;
    }

    if (!isCurrencyCodeValid(currency)) {
      throw FormatException(
        "[MoneyFlow] Failed adding income, invalid currency code: $currency",
      );
    }

    if (amount.isNegative) {
      _totalExpenseByCurrency.update(
        currency,
        (value) => value + amount,
        ifAbsent: () => amount,
      );
      expenseCount++;
    } else {
      _totalIncomeByCurrency.update(
        currency,
        (value) => value + amount,
        ifAbsent: () => amount,
      );
      incomeCount++;
    }
  }

  void addAll(Iterable<Money> moneys) => moneys.forEach(add);

  /// Returns the expense for the given currency, excludes other currency expenses
  Money getExpenseByCurrency(String currency) {
    return Money(_totalExpenseByCurrency[currency] ?? 0.0, currency);
  }

  /// Returns the income for the given currency, excludes other currency incomes
  Money getIncomeByCurrency(String currency) {
    return Money(_totalIncomeByCurrency[currency] ?? 0.0, currency);
  }

  Money getFlowByCurrency(String currency) {
    return getIncomeByCurrency(currency) + getExpenseByCurrency(currency);
  }

  SingleCurrencyMoneyFlow<T> extractByCurrency(String currency) {
    currency = currency.trim().toUpperCase();

    return SingleCurrencyMoneyFlow<T>._internal(
      singleCurrency!,
      associatedData: associatedData,
      expense: getExpenseByCurrency(currency).amount,
      income: getIncomeByCurrency(currency).amount,

      /// TODO @sadespresso fix lost data
      expenseCount: expenseCount,

      /// TODO @sadespresso fix lost data
      incomeCount: incomeCount,
    );
  }

  /// If type is transfer, returns `Money(0.0, currency)`
  Money getByTypeAndCurrency(String currency, TransactionType type) {
    return switch (type) {
      TransactionType.expense => getExpenseByCurrency(currency),
      TransactionType.income => getIncomeByCurrency(currency),
      _ => Money(0.0, currency),
    };
  }

  /// Returns the converted sum of all expenses in given [currency],
  /// or rates.baseCurrency if null
  Money getTotalExpense(ExchangeRates rates, String? currency) {
    currency ??= rates.baseCurrency;

    double amount = 0.0;

    for (final entry in _totalExpenseByCurrency.entries) {
      if (entry.key == currency) {
        amount += entry.value;
      } else {
        amount += Money.convertDouble(entry.key, currency, entry.value, rates);
      }
    }

    return Money(amount, currency);
  }

  /// Returns the converted sum of all incomes in given [currency],
  /// or rates.baseCurrency if null
  Money getTotalIncome(ExchangeRates rates, String? currency) {
    currency ??= rates.baseCurrency;

    double amount = 0.0;

    for (final entry in _totalIncomeByCurrency.entries) {
      if (entry.key == currency) {
        amount += entry.value;
      } else {
        amount += Money.convertDouble(entry.key, currency, entry.value, rates);
      }
    }

    return Money(amount, currency);
  }

  /// If type is transfer, returns `Money(0.0, currency)`
  Money getTotalByType(
    TransactionType type,
    ExchangeRates rates,
    String? currency,
  ) {
    currency ??= LocalPreferences().getPrimaryCurrency();

    return switch (type) {
      TransactionType.expense => getTotalExpense(rates, currency),
      TransactionType.income => getTotalIncome(rates, currency),
      _ => Money(0.0, currency),
    };
  }

  /// Returns the converted flow of all transactions in given [currency],
  /// or rates.baseCurrency if null
  Money getTotalFlow(ExchangeRates rates, String? currency) {
    currency ??= LocalPreferences().getPrimaryCurrency();

    return getTotalIncome(rates, currency) + getTotalExpense(rates, currency);
  }

  /// Merge all currencies into a single currency
  ///
  /// If [currency] is null, uses [rates.baseCurrency]
  SingleCurrencyMoneyFlow<T> merge(
    ExchangeRates rates,
    String? currency,
  ) {
    currency ??= rates.baseCurrency;

    final double expense = getTotalExpense(rates, currency).amount;
    final double income = getTotalIncome(rates, currency).amount;

    return SingleCurrencyMoneyFlow<T>._internal(
      currency,
      associatedData: associatedData,
      expense: expense,
      income: income,
      expenseCount: expenseCount,
      incomeCount: incomeCount,
    );
  }
}

class SingleCurrencyMoneyFlow<T> {
  final T? associatedData;
  final String currency;

  double _expense = 0.0;
  double get expense => _expense;

  double _income = 0.0;
  double get income => _income;

  int _expenseCount = 0;
  int get expenseCount => _expenseCount;

  int _incomeCount = 0;
  int get incomeCount => _incomeCount;

  SingleCurrencyMoneyFlow(this.currency, {this.associatedData});
  SingleCurrencyMoneyFlow._internal(
    this.currency, {
    this.associatedData,
    double expense = 0.0,
    double income = 0.0,
    int expenseCount = 0,
    int incomeCount = 0,
  })  : _expense = expense,
        _income = income,
        _expenseCount = expenseCount,
        _incomeCount = incomeCount;

  void add(double amount) {
    if (amount.abs() == 0.0) {
      return;
    }

    if (amount.isNegative) {
      _expense += amount;
      _expenseCount++;
    } else {
      _income += amount;
      _incomeCount++;
    }
  }

  /// Adds the [Money.amount] IF the [Money.currency] matches [currency]
  void addMoney(Money money) {
    if (money.currency == currency) {
      add(money.amount);
    }
  }

  /// Converts the amount to [rates.baseCurrency], or [currency] if given
  SingleCurrencyMoneyFlow<T> convert(ExchangeRates rates, String? currency) {
    currency ??= rates.baseCurrency;

    if (currency == this.currency) return this;

    final double convertedExpense =
        Money.convertDouble(this.currency, currency, _expense, rates);
    final double convertedIncome =
        Money.convertDouble(this.currency, currency, _income, rates);

    return SingleCurrencyMoneyFlow<T>._internal(
      currency,
      associatedData: associatedData,
      expense: convertedExpense,
      income: convertedIncome,
      expenseCount: expenseCount,
      incomeCount: incomeCount,
    );
  }
}
