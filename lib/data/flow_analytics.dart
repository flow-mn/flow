import "package:flow/data/money_flow.dart";
import "package:moment_dart/moment_dart.dart";

class FlowAnalytics<T> {
  final TimeRange range;

  final Map<String, MoneyFlow<T>> flow;

  const FlowAnalytics({required this.range, required this.flow});
}
