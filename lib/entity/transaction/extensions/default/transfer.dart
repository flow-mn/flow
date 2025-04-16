import "package:flow/entity/transaction/extensions/base.dart";
import "package:flow/utils/jasonable.dart";
import "package:json_annotation/json_annotation.dart";

part "transfer.g.dart";

@JsonSerializable()
class Transfer extends TransactionExtension implements Jasonable {
  static const String keyName = "@flow/default-transfer";

  @override
  @JsonKey(includeToJson: true)
  final String key = Transfer.keyName;

  final String fromAccountUuid;
  final String toAccountUuid;

  /// Only used for conversion between different currencies
  ///
  /// You can technically use this for other purposes, but it's not recommended
  final double? conversionRate;

  @override
  String? relatedTransactionUuid;

  @override
  void setRelatedTransactionUuid(String uuid) => relatedTransactionUuid = uuid;

  Transfer({
    required super.uuid,
    required this.fromAccountUuid,
    required this.toAccountUuid,
    required this.relatedTransactionUuid,
    this.conversionRate,
  }) : super();

  Transfer copyWith({
    String? uuid,
    String? fromAccountUuid,
    String? toAccountUuid,
    String? relatedTransactionUuid,
    double? conversionRate,
  }) => Transfer(
    uuid: uuid ?? this.uuid,
    fromAccountUuid: fromAccountUuid ?? this.fromAccountUuid,
    toAccountUuid: toAccountUuid ?? this.toAccountUuid,
    relatedTransactionUuid:
        relatedTransactionUuid ?? this.relatedTransactionUuid,
    conversionRate: conversionRate ?? this.conversionRate,
  );

  factory Transfer.fromJson(Map<String, dynamic> json) =>
      _$TransferFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TransferToJson(this);
}
