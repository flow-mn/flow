import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/sync/model/base.dart";
import "package:json_annotation/json_annotation.dart";

part "model_v1.g.dart";

@JsonSerializable()
class SyncModelV1 extends SyncModelBase {
  final List<Transaction> transactions;
  final List<Account> accounts;
  final List<Category> categories;

  const SyncModelV1({
    required super.versionCode,
    required super.exportDate,
    required super.username,
    required super.appVersion,
    required this.transactions,
    required this.accounts,
    required this.categories,
  });

  factory SyncModelV1.fromJson(Map<String, dynamic> json) =>
      _$SyncModelV1FromJson(json);
  Map<String, dynamic> toJson() => _$SyncModelV1ToJson(this);
}
