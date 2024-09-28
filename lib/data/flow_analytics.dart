import "package:flow/data/money_flow.dart";

class FlowAnalytics<T> {
  final DateTime from;
  final DateTime to;

  final Map<String, MoneyFlow<T>> flow;

  const FlowAnalytics({
    required this.from,
    required this.to,
    required this.flow,
  });
}
