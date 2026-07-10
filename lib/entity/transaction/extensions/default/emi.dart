import "package:flow/entity/transaction/extensions/base.dart";
import "package:flow/utils/jasonable.dart";
import "package:json_annotation/json_annotation.dart";

part "emi.g.dart";

@JsonSerializable()
class EmiExtension extends TransactionExtension implements Jasonable {
  static const String keyName = "@flow/emi-reference";

  @override
  @JsonKey(includeToJson: true)
  final String key = EmiExtension.keyName;

  final String emiUuid;

  @override
  String? get relatedTransactionUuid => null;

  @override
  set relatedTransactionUuid(String? uuid) {}

  EmiExtension({required super.uuid, required this.emiUuid}) : super();

  factory EmiExtension.fromJson(Map<String, dynamic> json) =>
      _$EmiExtensionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EmiExtensionToJson(this);
}
