import "package:flow/data/prefs/change_visuals.dart";
import "package:flow/entity/_base.dart";
import "package:flow/entity/transaction/type.dart";
import "package:flow/entity/user_preferences/transaction_entry_flow.dart";
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
  Duration? get remindDailyAt => remindDailyAtRelativeSeconds == null
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

  bool transactionListTileShowCategoryName;
  bool transactionListTileShowAccountForLeading;
  bool transactionListTileRelaxedDensity;

  String? icuCurrencyFormattingPattern;

  String? primaryCurrency;

  /// In hours, set as `null` to disable
  int? autoBackupIntervalInHours;

  bool enableICloudSync;

  /// Number of iCloud backups Flow should preserve. At each startup,
  /// Flow will remove any extra backups, sorted by time of the backup.
  ///
  /// Defaults to [10]
  ///
  /// Set to 0 or less to keep all
  int? iCloudBackupsToKeep;

  String? transactionButtonOrderJoined;

  String? themeName;
  bool themeChangesAppIcon;

  /// Serialized version of [ChangeVisuals]
  String? changeVisuals;

  @Transient()
  @JsonKey(includeToJson: false, includeFromJson: false)
  TransactionEntryFlow get transactionEntryFlow =>
      TransactionEntryFlow.deserialize(transactionEntryFlowJson);

  set transactionEntryFlow(TransactionEntryFlow flow) {
    transactionEntryFlowJson = flow.serialize();
  }

  /// Serialized version of [TransactionEntryFlow]
  String? transactionEntryFlowJson;

  @Transient()
  @JsonKey(includeFromJson: false, includeToJson: false)
  ChangeVisuals? get changeVisualParsed =>
      ChangeVisuals.tryParse(changeVisuals);
  set changeVisualParsed(ChangeVisuals? visuals) {
    changeVisuals = visuals?.serialize() ?? ChangeVisuals.defaults.serialize();
  }

  @Transient()
  @JsonKey(includeToJson: false, includeFromJson: false)
  List<TransactionType> get transactionButtonOrder {
    try {
      if (transactionButtonOrderJoined == null ||
          transactionButtonOrderJoined!.isEmpty) {
        throw StateError("transactionButtonOrderJoined is null or empty");
      }

      final List<TransactionType> parsed = transactionButtonOrderJoined!
          .split(",")
          .map(
            (e) => TransactionType.values.firstWhere((type) => type.value == e),
          )
          .toList();

      if (parsed.length != TransactionType.values.length) {
        throw StateError("Parsed transactionButtonOrder length mismatch");
      }

      return parsed;
    } catch (e) {
      return TransactionType.values.toList();
    }
  }

  set transactionButtonOrder(List<TransactionType> order) {
    transactionButtonOrderJoined = order.map((e) => e.value).join(",");
  }

  UserPreferences({
    this.id = 0,
    DateTime? createdDate,
    this.combineTransfers = true,
    this.excludeTransfersFromFlow = true,
    this.useCategoryNameForUntitledTransactions = false,
    this.transactionListTileShowCategoryName = false,
    this.transactionListTileShowAccountForLeading = false,
    this.transactionListTileRelaxedDensity = false,
    this.trashBinRetentionDays = 30,
    this.defaultFilterPreset,
    this.enableICloudSync = false,
    this.iCloudBackupsToKeep = 10,
    this.autoBackupIntervalInHours = 72,
    this.icuCurrencyFormattingPattern,
    this.primaryCurrency,
    this.transactionButtonOrderJoined,
    this.remindDailyAtRelativeSeconds,
    this.themeName,
    this.transactionEntryFlowJson,
    this.themeChangesAppIcon = true,
  }) : uuid = const Uuid().v4();

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);
}
