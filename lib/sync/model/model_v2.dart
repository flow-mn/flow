import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/profile.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction_filter_preset.dart";
import "package:flow/entity/user_preferences.dart";
import "package:flow/sync/model/base.dart";
import "package:json_annotation/json_annotation.dart";

part "model_v2.g.dart";

@JsonSerializable()
class SyncModelV2 extends SyncModelBase {
  final List<Transaction> transactions;
  final List<Account> accounts;
  final List<Category> categories;
  final List<TransactionFilterPreset>? transactionFilterPresets;
  final Profile? profile;
  final UserPreferences? userPreferences;
  final String? primaryCurrency;

  const SyncModelV2({
    required super.versionCode,
    required super.exportDate,
    required super.username,
    required super.appVersion,
    required this.transactions,
    required this.accounts,
    required this.categories,
    required this.transactionFilterPresets,
    required this.profile,
    required this.userPreferences,
    required this.primaryCurrency,
  });

  factory SyncModelV2.fromJson(Map<String, dynamic> json) =>
      _$SyncModelV2FromJson(json);
  Map<String, dynamic> toJson() => _$SyncModelV2ToJson(this);
}
