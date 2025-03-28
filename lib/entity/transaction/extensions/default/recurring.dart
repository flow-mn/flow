import "package:flow/entity/transaction/extensions/base.dart";
import "package:flow/utils/utils.dart";
import "package:json_annotation/json_annotation.dart";
import "package:moment_dart/moment_dart.dart";
import "package:recurrence/recurrence.dart";

part "recurring.g.dart";

@JsonSerializable(explicitToJson: true)
class Recurring extends TransactionExtension implements Jasonable {
  static const String name = "@flow/default-recurring";

  @override
  String? relatedTransactionUuid;

  @override
  void setRelatedTransactionUuid(String uuid) => relatedTransactionUuid = uuid;

  /// [moment_dart](https://pub.dev/packages/moment_dart) compatible TimeRange string
  ///
  /// If null, same as [Moment.minValue] to [Moment.maxValue]
  ///
  /// This is inclusive on both ends
  String? range;

  @JsonKey(includeToJson: false, includeFromJson: false)
  TimeRange? get timeRange => range != null ? TimeRange.parse(range!) : null;

  set timeRange(TimeRange? value) => range = value?.toString();

  /// [recurrence](https://pub.dev/packages/recurrence) compatible rules
  List<String> rules;

  @JsonKey(includeToJson: false, includeFromJson: false)
  List<RecurrenceRule> get recurrenceRules =>
      rules.map((rule) => RecurrenceRule.parse(rule)).toList();

  set recurrenceRules(List<RecurrenceRule> value) =>
      rules = value.map((rule) => rule.serialize()).toList();

  @JsonKey(includeToJson: false, includeFromJson: false)
  Recurrence get recurrence => Recurrence(
    range: timeRange ?? TimeRange.allTime(),
    rules: recurrenceRules,
  );

  Recurring({
    required this.relatedTransactionUuid,
    required this.range,
    required this.rules,
    required super.uuid,
  }) : super();

  @override
  @JsonKey(includeToJson: true)
  final String key = Recurring.name;

  factory Recurring.fromJson(Map<String, dynamic> json) =>
      _$RecurringFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$RecurringToJson(this);
}
