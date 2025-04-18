import "dart:convert";

import "package:flow/entity/_base.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/utils/json/utc_datetime_converter.dart";
import "package:json_annotation/json_annotation.dart";
import "package:moment_dart/moment_dart.dart";
import "package:objectbox/objectbox.dart";
import "package:recurrence/recurrence.dart";
import "package:uuid/uuid.dart";

part "recurring_transaction.g.dart";

@Entity()
@JsonSerializable(explicitToJson: true, converters: [UTCDateTimeConverter()])
class RecurringTransaction extends EntityBase {
  @JsonKey(includeFromJson: false, includeToJson: false)
  int id;

  @override
  String uuid;

  /// Serialized [Transaction] object. This is used as a template for
  /// creating new transactions, and some fields are ignored.
  ///
  /// If the transaction is a transfer, the [transferToAccountUuid] field is
  /// required, and [Transaction.category] is ignored.
  ///
  /// Ignored fields include, but are not limited to:
  /// * [Transaction.uuid]
  /// * [Transaction.createdDate]
  /// * [Transaction.transactionDate]
  /// * [Transaction.isDeleted]
  /// * [Transaction.deletedDate]
  String jsonTransactionTemplate;

  String? transferToAccountUuid;

  @Transient()
  Transaction get template =>
      Transaction.fromJson(jsonDecode(jsonTransactionTemplate));

  /// [moment_dart](https://pub.dev/packages/moment_dart) compatible TimeRange string
  ///
  /// If null, same as [Moment.minValue] to [Moment.maxValue]
  ///
  /// This is inclusive on both ends
  String range;

  @Transient()
  @JsonKey(includeToJson: false, includeFromJson: false)
  TimeRange get timeRange => TimeRange.parse(range);

  set timeRange(TimeRange value) => range = value.encodeShort();

  /// [recurrence](https://pub.dev/packages/recurrence) compatible rules
  List<String> rules;

  @Transient()
  @JsonKey(includeToJson: false, includeFromJson: false)
  List<RecurrenceRule> get recurrenceRules =>
      rules.map((rule) => RecurrenceRule.parse(rule)).toList();

  set recurrenceRules(List<RecurrenceRule> value) =>
      rules = value.map((rule) => rule.serialize()).toList();

  @Transient()
  @JsonKey(includeToJson: false, includeFromJson: false)
  Recurrence get recurrence =>
      Recurrence(range: timeRange, rules: recurrenceRules);

  @Property(type: PropertyType.date)
  DateTime createdDate;

  /// This marks the last generated transaction date
  @Property(type: PropertyType.date)
  DateTime? lastGeneratedTransactionDate;

  final bool disabled;

  RecurringTransaction({
    this.id = 0,
    this.disabled = false,
    required this.rules,
    required this.jsonTransactionTemplate,
    required this.range,
    this.transferToAccountUuid,
    this.lastGeneratedTransactionDate,
    DateTime? createdDate,
    String? uuid,
  }) : createdDate = createdDate ?? DateTime.now(),
       uuid = uuid ?? const Uuid().v4();

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) =>
      _$RecurringTransactionFromJson(json);
  Map<String, dynamic> toJson() => _$RecurringTransactionToJson(this);
}
