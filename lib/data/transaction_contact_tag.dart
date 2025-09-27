import "package:json_annotation/json_annotation.dart";

part "transaction_contact_tag.g.dart";

@JsonSerializable()
class TransactionContactTag {
  final String? id;
  final String? name;

  const TransactionContactTag({this.id, this.name});

  factory TransactionContactTag.fromJson(Map<String, dynamic> json) =>
      _$TransactionContactTagFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionContactTagToJson(this);
}
