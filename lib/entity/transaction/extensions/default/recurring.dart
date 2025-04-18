import "package:flow/entity/transaction/extensions/base.dart";
import "package:flow/utils/utils.dart";
import "package:json_annotation/json_annotation.dart";

part "recurring.g.dart";

@JsonSerializable(explicitToJson: true)
class Recurring extends TransactionExtension implements Jasonable {
  static const String keyName = "@flow/default-recurring";

  @override
  String? relatedTransactionUuid;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get recurringTransactionUuid => uuid;

  DateTime initialTransactionDate;

  @override
  void setRelatedTransactionUuid(String uuid) => relatedTransactionUuid = uuid;

  /// Indicates whether this transaction should be updated when the recurring
  /// transaction is updated.
  final bool locked;

  Recurring({
    required super.uuid,
    required this.initialTransactionDate,
    this.relatedTransactionUuid,
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
    DateTime? initialTransactionDate,
    String? relatedTransactionUuid,
    String? uuid,
    bool? locked,
  }) {
    return Recurring(
      initialTransactionDate:
          initialTransactionDate ?? this.initialTransactionDate,
      relatedTransactionUuid:
          relatedTransactionUuid ?? this.relatedTransactionUuid,
      uuid: uuid ?? this.uuid,
      locked: locked ?? this.locked,
    );
  }
}
