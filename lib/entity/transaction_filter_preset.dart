import "dart:convert";

import "package:flow/data/transaction_filter.dart";
import "package:flow/entity/_base.dart";
import "package:flow/utils/json/utc_datetime_converter.dart";
import "package:json_annotation/json_annotation.dart";
import "package:objectbox/objectbox.dart";
import "package:uuid/uuid.dart";

part "transaction_filter_preset.g.dart";

@Entity()
@JsonSerializable(
  explicitToJson: true,
  converters: [UTCDateTimeConverter()],
)
class TransactionFilterPreset implements EntityBase {
  @JsonKey(includeFromJson: false, includeToJson: false)
  int id;

  @override
  @Unique()
  String uuid;

  static const int maxNameLength = 128;

  String name;

  String jsonTransactionFilter;

  @Transient()
  TransactionFilter get filter =>
      TransactionFilter.fromJson(jsonDecode(jsonTransactionFilter));

  /// Returns whether this [filter] contains any references that isn't
  /// resolvable to existing [Account] and/or [Category].
  bool validate({
    required List<String> accounts,
    required List<String> categories,
  }) {
    final TransactionFilter filter = this.filter;

    if (filter.accounts?.isNotEmpty == true &&
        filter.accounts!.any(
          (accountUuid) => !accounts.contains(accountUuid),
        )) {
      return false;
    }

    if (filter.categories?.isNotEmpty == true &&
        filter.categories!.any(
          (categoryUuid) => !categories.contains(categoryUuid),
        )) {
      return false;
    }

    return true;
  }

  @Property(type: PropertyType.date)
  DateTime createdDate;

  TransactionFilterPreset({
    this.id = 0,
    DateTime? createdDate,
    required this.jsonTransactionFilter,
    required this.name,
  })  : createdDate = createdDate ?? DateTime.now(),
        uuid = const Uuid().v4();

  factory TransactionFilterPreset.fromJson(Map<String, dynamic> json) =>
      _$TransactionFilterPresetFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionFilterPresetToJson(this);
}
