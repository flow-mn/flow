import "package:flow/entity/transaction/extensions/base.dart";
import "package:flow/utils/utils.dart";
import "package:json_annotation/json_annotation.dart";

part "recurring.g.dart";

@JsonSerializable(explicitToJson: true)
class Recurring extends TransactionExtension implements Jasonable {
  static const String keyName = "@flow/default-recurring";

  @override
  String? relatedTransactionUuid;

  @override
  void setRelatedTransactionUuid(String uuid) => relatedTransactionUuid = uuid;

  final String recurringTransactionUuid;

  /// Indicates whether this transaction should be updated when the recurring
  /// transaction is updated.
  final bool locked;

  Recurring({
    required this.relatedTransactionUuid,
    required this.recurringTransactionUuid,
    required super.uuid,
    this.locked = false,
  }) : super();

  @override
  @JsonKey(includeToJson: true)
  final String key = Recurring.keyName;

  factory Recurring.fromJson(Map<String, dynamic> json) =>
      _$RecurringFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$RecurringToJson(this);

  Recurring copyWith({
    String? relatedTransactionUuid,
    String? recurringTransactionUuid,
    String? uuid,
    bool? locked,
  }) {
    return Recurring(
      relatedTransactionUuid:
          relatedTransactionUuid ?? this.relatedTransactionUuid,
      recurringTransactionUuid:
          recurringTransactionUuid ?? this.recurringTransactionUuid,
      uuid: uuid ?? this.uuid,
      locked: locked ?? this.locked,
    );
  }
}
