import "package:flow/data/exchange_rates.dart";
import "package:flow/data/money.dart";
import "package:flow/services/currency_registry.dart";
import "package:flow/services/user_preferences.dart";

/// A class that sums up expense/income separately. When a foreign currency is used,
/// it may ignore that, and set [hasMissingData] to true, if exchange rates are not available.
class SingleCurrencyFlow<T> {
  final T? associatedData;
  late final String currency;

  bool _hasMissingData = false;
  bool get hasMissingData => _hasMissingData;

  int _expenseCount = 0;
  int get expenseCount => _expenseCount;
  int _incomeCount = 0;
  int get incomeCount => _incomeCount;

  double _expenseSum = 0.0;
  double get expenseSum => _expenseSum;
  double _incomeSum = 0.0;
  double get incomeSum => _incomeSum;

  double get flow => _incomeSum + _expenseSum;

  Money get totalExpense => Money(_expenseSum, currency);
  Money get totalIncome => Money(_incomeSum, currency);
  Money get totalFlow => Money(flow, currency);

  SingleCurrencyFlow({this.associatedData, String? currency}) {
    this.currency = (currency ??= UserPreferencesService().primaryCurrency);

    if (!CurrencyRegistryService().isCurrencyCodeValid(currency)) {
      throw FormatException(
        "[MoneyFlow] Failed initializing, invalid currency code: $currency",
      );
    }
  }

  void add(Money money, ExchangeRates? rates) {
    final double amount = money.amount;

    if (amount.abs() == 0.0) {
      return;
    }

    final String currency = money.currency.trim().toUpperCase();

    if (!CurrencyRegistryService().isCurrencyCodeValid(currency)) {
      throw FormatException(
        "[MoneyFlow] Failed adding income, invalid currency code: $currency",
      );
    }

    if (amount.isNegative) {
      _expenseCount++;
      if (money.currency == this.currency) {
        _expenseSum += amount;
      } else {
        // Converting can throw when a rate is missing; per this class's
        // contract that is "missing data", never a hard failure that would
        // abort the whole aggregation for one unconvertible transaction.
        final double? converted = _tryConvert(money, rates);
        if (converted == null) {
          _hasMissingData = true;
        } else {
          _expenseSum += converted;
        }
      }

      return;
    }

    if (!amount.isNegative) {
      _incomeCount++;
      if (money.currency == this.currency) {
        _incomeSum += amount;
      } else {
        final double? converted = _tryConvert(money, rates);
        if (converted == null) {
          _hasMissingData = true;
        } else {
          _incomeSum += converted;
        }
      }

      return;
    }
  }

  double? _tryConvert(Money money, ExchangeRates? rates) {
    if (rates == null) return null;

    try {
      return money.convert(currency, rates).amount;
    } catch (_) {
      return null;
    }
  }

  void addAll(Iterable<Money> moneys, ExchangeRates? rates) {
    for (final Money money in moneys) {
      add(money, rates);
    }
  }
}
