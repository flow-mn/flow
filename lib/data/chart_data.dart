import "package:flow/data/money.dart";
import "package:flow/services/exchange_rates.dart";

class ChartData<T> implements Comparable<ChartData<T>> {
  final String key;
  final Money money;
  final String currency;
  final T? associatedData;

  double get displayTotal => money.amount.abs();

  ChartData({
    required this.key,
    required this.money,
    required this.currency,
    required this.associatedData,
  });

  @override
  int compareTo(ChartData<T> other) {
    return money.tryCompareToWithExchange(
      other.money,
      ExchangeRatesService().getPrimaryCurrencyRates(),
    );
  }
}
