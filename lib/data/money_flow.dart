import "dart:developer";

import "package:flow/data/currencies.dart";
import "package:flow/data/exchange_rates.dart";
import "package:flow/data/money.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/prefs.dart";

class MoneyFlow<T> {
  final T? associatedData;

  final Map<String, double> _totalExpenseByCurrency = {};
  final Map<String, double> _totalIncomeByCurrency = {};

  int expenseCount = 0;
  int incomeCount = 0;

  MoneyFlow({this.associatedData});

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

  /// Calls [getExpenseByCurrency] or [getIncomeByCurrency] based on [type]
  ///
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
  Money getTotalExpense(ExchangeRates rates, [String? currency]) {
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

  Money getTotalFlow(ExchangeRates rates, String? currency) {
    currency ??= LocalPreferences().getPrimaryCurrency();

    return getTotalIncome(rates, currency) + getTotalExpense(rates, currency);
  }
}
