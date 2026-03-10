import "package:flow/entity/_base.dart";
import "package:flow/entity/category.dart";
import "package:flow/utils/json/time_range_converter.dart";
import "package:flow/utils/json/utc_datetime_converter.dart";
import "package:json_annotation/json_annotation.dart";
import "package:moment_dart/moment_dart.dart";
import "package:objectbox/objectbox.dart";
import "package:uuid/uuid.dart";

part "budget.g.dart";

@Entity()
@JsonSerializable(
  explicitToJson: true,
  converters: [UTCDateTimeConverter(), TimeRangeConverter()],
)
class Budget implements EntityBase {
  @JsonKey(includeFromJson: false, includeToJson: false)
  int id;

  @override
  @Unique()
  String uuid;

  @Property(type: PropertyType.date)
  DateTime createdDate;

  @Unique()
  String name;

  /// [moment_dart](https://pub.dev/packages/moment_dart)'s [TimeRange]
  /// compliant string
  String range;

  @Transient()
  TimeRange get timeRange => TimeRange.parse(range);

  set timeRange(TimeRange value) => range = value.toString();

  /// When [true], and [timeRange] is [PageableRange], it will automatically
  /// create a new budget for the next period when the current one expires.
  bool renewAutomatically;

  double amount;

  String currency;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final categories = ToMany<Category>();

  @Transient()
  List<String>? _categoriesUuids;

  List<String>? get categoriesUuids =>
      _categoriesUuids ?? categories.map((e) => e.uuid).toList();

  set categoriesUuids(List<String>? newTagUuids) {
    _categoriesUuids = newTagUuids ?? <String>[];
  }

  void setCategories(List<Category>? newCategories) {
    categories.clear();
    categories.addAll(newCategories ?? []);
    categoriesUuids = categories.map((e) => e.uuid).toList();
  }

  Budget({
    this.id = 0,
    required this.name,
    required this.amount,
    required this.currency,
    required this.range,
    this.renewAutomatically = true,
    DateTime? createdDate,
  }) : createdDate = createdDate ?? DateTime.now(),
       uuid = const Uuid().v4();

  factory Budget.fromJson(Map<String, dynamic> json) => _$BudgetFromJson(json);
  Map<String, dynamic> toJson() => _$BudgetToJson(this);
}
