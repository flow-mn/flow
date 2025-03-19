import "package:flow/entity/_base.dart";
import "package:flow/utils/json/utc_datetime_converter.dart";
import "package:json_annotation/json_annotation.dart";
import "package:objectbox/objectbox.dart";
import "package:uuid/uuid.dart";

part "user_preferences.g.dart";

@Entity()
@JsonSerializable(explicitToJson: true, converters: [UTCDateTimeConverter()])
class UserPreferences implements EntityBase {
  @JsonKey(includeFromJson: false, includeToJson: false)
  int id;

  @override
  @Unique()
  String uuid;

  /// Whether to combine transfer transactions in the transaction list
  ///
  /// Doesn't necessarily combine the transactions, but rather
  /// shows them as a single transaction in the transaction list
  ///
  /// It will not work in transactions list where a filter has applied
  bool combineTransfers;

  /// Whether to exclude transfer transactions from the flow
  ///
  /// When set to true, transfer transactions will not contribute
  /// to total income/expense for a given context
  bool excludeTransfersFromFlow;

  /// Defaults to [30]
  ///
  /// Set null to retain forever
  int? trashBinRetentionDays;

  /// Le UUID of it
  String? defaultFilterPreset;

  /// It's a added to a start of the day
  ///
  /// e.g., to set a daily reminder at 9:00 AM, set it to 9 hours
  @Transient()
  @JsonKey(includeToJson: false, includeFromJson: false)
  Duration? get remindDailyAt =>
      remindDailyAtRelativeSeconds == null
          ? null
          : Duration(seconds: remindDailyAtRelativeSeconds!);

  set remindDailyAt(Duration? duration) {
    remindDailyAtRelativeSeconds = duration?.inSeconds;
  }

  /// It's a added to a start of the day
  ///
  /// e.g., to set a daily reminder at 9:00 AM, set it to 9 hours
  int? remindDailyAtRelativeSeconds;

  bool useCategoryNameForUntitledTransactions;
  bool showCategoryInListTile;

  UserPreferences({
    this.id = 0,
    DateTime? createdDate,
    this.combineTransfers = true,
    this.excludeTransfersFromFlow = true,
    this.useCategoryNameForUntitledTransactions = false,
    this.showCategoryInListTile = false,
    this.trashBinRetentionDays = 30,
    this.defaultFilterPreset,
  }) : uuid = const Uuid().v4();

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);
}
