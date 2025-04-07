import "package:flow/entity/transaction/extensions/base.dart";
import "package:flow/utils/utils.dart";
import "package:json_annotation/json_annotation.dart";

part "recurring.g.dart";

@JsonSerializable(explicitToJson: true)
class Recurring extends TransactionExtension implements Jasonable {
  static const String name = "@flow/default-recurring";

  @override
  String? relatedTransactionUuid;

  @override
  void setRelatedTransactionUuid(String uuid) => relatedTransactionUuid = uuid;

  final String recurringTransactionUuid;

  Recurring({
    required this.relatedTransactionUuid,
    required this.recurringTransactionUuid,
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
