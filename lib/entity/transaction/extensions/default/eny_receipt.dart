import "package:flow/entity/transaction/extensions/base.dart";
import "package:flow/utils/utils.dart";
import "package:json_annotation/json_annotation.dart";

part "eny_receipt.g.dart";

@JsonSerializable()
class EnyReceipt extends TransactionExtension implements Jasonable {
  static const String keyName = "@flow/eny-receipt";

  EnyReceipt({
    required super.uuid,
    this.relatedTransactionUuid,
    this.enyImageUrl,
    this.enyReceiptId,
    this.partOfMultiTransaction,
  }) : super();

  @override
  String? relatedTransactionUuid;

  String? enyReceiptId;

  String? enyImageUrl;

  bool? partOfMultiTransaction;

  @override
  @JsonKey(includeToJson: true)
  final String key = EnyReceipt.keyName;

  factory EnyReceipt.fromJson(Map<String, dynamic> json) =>
      _$EnyReceiptFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$EnyReceiptToJson(this);
}
