import "dart:developer";

import "package:flow/data/currencies.dart";
import "package:flow/data/exchange_rates.dart";

class Money {
  final double amount;
  final String currency;

  static const String invalidCurrency = "   ";

  /// Not a money; lmao
  static const Money nam = Money._(double.nan, invalidCurrency);

  static const Money zeroUSD = Money._(0.0, "USD");

  const Money._(this.amount, this.currency);

  factory Money(double amount, String currency) {
    if (!isCurrencyCodeValid(currency)) {
      throw MoneyException("Invalid or unsupported currency code: $currency");
    }

    return Money._(amount, currency.toUpperCase());
  }

  static double convertDouble(
      String from, String to, double amount, ExchangeRates rates) {
    if (from == to) return amount;

    if (!isCurrencyCodeValid(from) || !isCurrencyCodeValid(to)) {
      throw const MoneyException("Invalid or unsupported currency code");
    }

    return Money(amount, from).convert(to, rates).amount;
  }

  /// Assumes primary currency rates exist
  Money convert(String newCurrency, ExchangeRates rates) {
    if (!isCurrencyCodeValid(newCurrency)) {
      throw MoneyException("Invalid or unsupported currency code: $currency");
    }

    if (currency == newCurrency) {
      return this;
    }

    if (rates.getRate(currency) == null || rates.getRate(newCurrency) == null) {
      throw MoneyException(
        "Exchange rates for both $currency and $newCurrency are required",
      );
    }

    final String currencyFranco = rates.baseCurrency;

    if (newCurrency == currencyFranco) {
      return Money(amount / rates.getRate(currency)!, newCurrency);
    }
    if (currency == currencyFranco) {
      return Money(amount * rates.getRate(newCurrency)!, newCurrency);
    }

    return convert(currencyFranco, rates).convert(newCurrency, rates);
  }

  Money operator +(Money other) {
    if (currency != other.currency) {
      throw const MoneyException(
        "Cannot add Money of different currencies",
      );
    }

    return Money(amount + other.amount, currency);
  }

  Money operator -(Money other) {
    if (currency != other.currency) {
      throw const MoneyException(
        "Cannot subtract Money of different currencies",
      );
    }

    return Money(amount - other.amount, currency);
  }

  Money operator -() {
    return Money(-amount, currency);
  }

  Money operator *(double multiplier) {
    return Money(amount * multiplier, currency);
  }

  Money operator /(double divisor) {
    return Money(amount / divisor, currency);
  }

  /// Compare doesn't work for [Money]s of different currencies
  int tryCompareTo(Money other) {
    if (currency != other.currency) {
      log("Cannot compare Money of different currencies, returning 0");
      return 0;
    }

    return amount.compareTo(other.amount);
  }

  /// If [rates] is given, converts [this] and [other] to
  /// [rates.baseCurrency] before calling [tryCompareTo]
  int tryCompareToWithExchange(Money other, ExchangeRates? rates) {
    if (rates == null) {
      return tryCompareTo(other);
    }

    return convert(rates.baseCurrency, rates)
        .tryCompareTo(other.convert(rates.baseCurrency, rates));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! Money) return false;

    return amount == other.amount && currency == other.currency;
  }

  bool get isNegative => amount.isNegative;

  Money abs() => Money(amount.abs(), currency);

  @override
  int get hashCode => Object.hashAll([amount, currency]);
}

class MoneyException implements Exception {
  final String message;

  const MoneyException(this.message);

  @override
  String toString() => message;
}
