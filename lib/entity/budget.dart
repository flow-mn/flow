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

  /// [moment_dart](https://pub.dev/packages/moment_dart)'s [TimeRange] compliant string
  String range;

  @Transient()
  TimeRange get timeRange => TimeRange.parse(range);

  set timeRange(TimeRange value) => range = value.toString();

  double amount;

  String currency;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final category = ToOne<Category>();

  @Transient()
  String? _categoryUuid;

  String? get categoryUuid => _categoryUuid ?? category.target?.uuid;

  set categoryUuid(String? value) {
    _categoryUuid = value;
  }

  /// This won't be saved until you call `Box.put()`
  void setCategory(Category? newCategory) {
    category.target = newCategory;
    categoryUuid = newCategory?.uuid;
  }

  Budget({
    this.id = 0,
    required this.name,
    required this.amount,
    required this.currency,
    required this.range,
    DateTime? createdDate,
  }) : createdDate = createdDate ?? DateTime.now(),
       uuid = const Uuid().v4();

  factory Budget.fromJson(Map<String, dynamic> json) => _$BudgetFromJson(json);
  Map<String, dynamic> toJson() => _$BudgetToJson(this);
}
