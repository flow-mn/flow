import "package:flow/entity/transaction/extensions/base.dart";
import "package:flow/utils/jsonable.dart";
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

  final String relatedTransactionUuid;

  final String uuid;

  const Transfer({
    required this.uuid,
    required this.fromAccountUuid,
    required this.toAccountUuid,
    required this.relatedTransactionUuid,
  }) : super();

  Transfer copyWith({
    String? uuid,
    String? fromAccountUuid,
    String? toAccountUuid,
    String? relatedTransactionUuid,
  }) =>
      Transfer(
        uuid: uuid ?? this.uuid,
        fromAccountUuid: fromAccountUuid ?? this.fromAccountUuid,
        toAccountUuid: toAccountUuid ?? this.toAccountUuid,
        relatedTransactionUuid:
            relatedTransactionUuid ?? this.relatedTransactionUuid,
      );

  factory Transfer.fromJson(Map<String, dynamic> json) =>
      _$TransferFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TransferToJson(this);
}
