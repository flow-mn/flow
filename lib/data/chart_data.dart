import 'package:flow/data/exchange_rates.dart';
import 'package:flow/data/money.dart';

class ChartData<T> implements Comparable<ChartData<T>> {
  final String key;
  final Money money;
  final T? associatedData;

  double get displayTotal => money.amount.abs();

  ChartData({
    required this.key,
    required this.money,
    required this.associatedData,
  });

  @override
  int compareTo(ChartData<T> other) {
    return money.tryCompareToWithExchange(
      other.money,
      ExchangeRates.getPrimaryCurrencyRates(),
    );
  }
}
