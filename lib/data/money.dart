import 'package:flow/data/currencies.dart';
import 'package:flow/data/exchange_rates.dart';
import 'package:flow/prefs.dart';

class Money implements Comparable<Money> {
  final double amount;
  final String currency;

  static const String _invalidCurrency = "   ";

  /// Not a money; lmao
  static const Money nam = Money._(double.nan, _invalidCurrency);

  const Money._(this.amount, this.currency);

  factory Money(double amount, String currency) {
    if (!isCurrencyCodeValid(currency)) {
      throw Exception("Invalid or unsupported currency code: $currency");
    }

    return Money._(amount, currency.toUpperCase());
  }

  /// Assumes
  Money convert(String newCurrency) {
    if (!isCurrencyCodeValid(newCurrency)) {
      throw Exception("Invalid or unsupported currency code: $currency");
    }

    if (currency == newCurrency) {
      return this;
    }

    final String primaryCurrency = LocalPreferences().getPrimaryCurrency();
    final ExchangeRates rates = ExchangeRates.getPrimaryCurrencyRates()!;

    if (currency == primaryCurrency) {
      return Money(amount * rates.rates[newCurrency]!, newCurrency);
    } else {
      return this & primaryCurrency & newCurrency;
    }
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
      // TODO (@sadespresso) convert currencies
      throw ArgumentError("Cannot compare money with different currencies");
    }

    return amount.compareTo(other.amount);
  }
}
