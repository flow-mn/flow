import 'package:flow/data/currencies.dart';
import 'package:flow/data/exchange_rates.dart';
import 'package:flow/prefs.dart';

class Money implements Comparable<Money> {
  final double amount;
  final String currency;

  static const String invalidCurrency = "   ";

  /// Not a money; lmao
  static const Money nam = Money._(double.nan, invalidCurrency);

  static const Money zeroUSD = Money._(0.0, "USD");

  const Money._(this.amount, this.currency);

  factory Money(double amount, String currency) {
    if (!isCurrencyCodeValid(currency)) {
      throw Exception("Invalid or unsupported currency code: $currency");
    }

    return Money._(amount, currency.toUpperCase());
  }

  static double convertDouble(String from, String to, double amount) {
    if (from == to) return amount;

    if (!isCurrencyCodeValid(from) || !isCurrencyCodeValid(to)) {
      throw Exception("Invalid or unsupported currency code");
    }

    return Money(amount, from).convert(to).amount;
  }

  /// Assumes primary currency rates exist
  Money convert(String newCurrency) {
    if (!isCurrencyCodeValid(newCurrency)) {
      throw Exception("Invalid or unsupported currency code: $currency");
    }

    if (currency == newCurrency) {
      return this;
    }

    final String primaryCurrency = LocalPreferences().getPrimaryCurrency();
    final ExchangeRates rates = ExchangeRates.getPrimaryCurrencyRates()!;

    if (newCurrency == primaryCurrency) {
      return Money(amount / rates.getRate(currency)!, newCurrency);
    }
    if (currency == primaryCurrency) {
      return Money(amount * rates.getRate(newCurrency)!, newCurrency);
    }

    return this & primaryCurrency & newCurrency;
  }

  Money operator &(String currency) => convert(currency);

  Money operator +(Money other) {
    if (currency != other.currency) {
      return this + (other & currency);
    }

    return Money(amount + other.amount, currency);
  }

  Money operator -(Money other) {
    if (currency != other.currency) {
      return this - (other & currency);
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

  @override
  int compareTo(Money other) {
    if (currency != other.currency) {
      return compareTo(other & currency);
    }

    return amount.compareTo(other.amount);
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
