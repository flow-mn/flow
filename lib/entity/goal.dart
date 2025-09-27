import "package:flow/data/flow_icon.dart";
import "package:flow/entity/_base.dart";
import "package:flow/entity/account.dart";
import "package:flow/utils/json/time_range_converter.dart";
import "package:flow/utils/json/utc_datetime_converter.dart";
import "package:json_annotation/json_annotation.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";
import "package:objectbox/objectbox.dart";
import "package:uuid/uuid.dart";

part "goal.g.dart";

@Entity()
@JsonSerializable(
  explicitToJson: true,
  converters: [UTCDateTimeConverter(), TimeRangeConverter()],
)
class Goal implements EntityBase {
  @JsonKey(includeFromJson: false, includeToJson: false)
  int id;

  @override
  @Unique()
  String uuid;

  @Property(type: PropertyType.date)
  DateTime createdDate;

  @Unique()
  String name;

  /// [moment_dart](https://pub.dev/packages/moment_dart)'s [TimeRange] compliant string
  String? range;

  @Transient()
  TimeRange? get timeRange => range == null ? null : TimeRange.parse(range!);

  set timeRange(TimeRange? value) => range = value?.toString();

  double targetBalance;

  String currency;

  String? iconCode;

  @Transient()
  @JsonKey(includeFromJson: false, includeToJson: false)
  FlowIconData get icon {
    try {
      if (iconCode == null) throw Exception("No icon code");

      return FlowIconData.parse(iconCode!);
    } catch (e) {
      return FlowIconData.icon(Symbols.sports_score_rounded);
    }
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  final account = ToOne<Account>();

  @Transient()
  String? _accountUuid;

  String? get accountUuid => _accountUuid ?? account.target?.uuid;

  set accountUuid(String? value) {
    _accountUuid = value;
  }

  /// This won't be saved until you call `Box.put()`
  void setAccount(Account? newAccount) {
    account.target = newAccount;
    accountUuid = newAccount?.uuid;
  }

  Goal({
    this.id = 0,
    required this.name,
    required this.targetBalance,
    required this.currency,
    required this.range,
    this.iconCode,
    DateTime? createdDate,
  }) : createdDate = createdDate ?? DateTime.now(),
       uuid = const Uuid().v4();

  factory Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);
  Map<String, dynamic> toJson() => _$GoalToJson(this);
}
