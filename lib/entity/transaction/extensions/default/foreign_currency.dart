import "package:flow/data/money.dart";
import "package:flow/entity/transaction/extensions/base.dart";
import "package:flow/utils/jasonable.dart";
import "package:json_annotation/json_annotation.dart";

part "foreign_currency.g.dart";

/// Original amount of a transaction made in a currency other than its
/// account's. The transaction itself stores the converted amount.
@JsonSerializable()
class ForeignCurrency extends TransactionExtension implements Jasonable {
  static const String keyName = "@flow/default-foreign-currency";

  @override
  @JsonKey(includeToJson: true)
  final String key = ForeignCurrency.keyName;

  /// Signed the same way as the transaction amount
  final double amount;

  /// Currency code complying with [ISO 4217](https://en.wikipedia.org/wiki/ISO_4217)
  final String currency;

  @override
  String? relatedTransactionUuid;

  @override
  void setRelatedTransactionUuid(String uuid) => relatedTransactionUuid = uuid;

  @JsonKey(includeFromJson: false, includeToJson: false)
  Money get money => Money(amount, currency);

  ForeignCurrency({
    required super.uuid,
    required this.amount,
    required this.currency,
    this.relatedTransactionUuid,
  }) : super();

  ForeignCurrency copyWith({
    String? uuid,
    double? amount,
    String? currency,
    String? relatedTransactionUuid,
  }) => ForeignCurrency(
    uuid: uuid ?? this.uuid,
    amount: amount ?? this.amount,
    currency: currency ?? this.currency,
    relatedTransactionUuid:
        relatedTransactionUuid ?? this.relatedTransactionUuid,
  );

  factory ForeignCurrency.fromJson(Map<String, dynamic> json) =>
      _$ForeignCurrencyFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ForeignCurrencyToJson(this);
}
