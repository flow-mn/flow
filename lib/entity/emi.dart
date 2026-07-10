import "package:flow/entity/_base.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/utils/json/utc_datetime_converter.dart";
import "package:json_annotation/json_annotation.dart";
import "package:objectbox/objectbox.dart";
import "package:uuid/uuid.dart";

part "emi.g.dart";

@Entity()
@JsonSerializable(explicitToJson: true, converters: [UTCDateTimeConverter()])
class Emi implements EntityBase {
  @JsonKey(includeFromJson: false, includeToJson: false)
  int id;

  @override
  @Unique()
  String uuid;

  @Property(type: PropertyType.date)
  DateTime createdDate;

  String title;
  String? description;

  double totalAmount;
  double installmentAmount;
  int totalInstallments;
  int paidInstallments;
  int remainingInstallments;
  double paidAmount;
  double remainingAmount;

  @Property(type: PropertyType.date)
  DateTime startDate;

  @Property(type: PropertyType.date)
  DateTime? nextDueDate;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final account = ToOne<Account>();

  @Transient()
  String? _accountUuid;
  String? get accountUuid => _accountUuid ?? account.target?.uuid;
  set accountUuid(String? value) => _accountUuid = value;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final category = ToOne<Category>();

  @Transient()
  String? _categoryUuid;
  String? get categoryUuid => _categoryUuid ?? category.target?.uuid;
  set categoryUuid(String? value) => _categoryUuid = value;

  String status; // 'active' or 'completed'

  Emi({
    this.id = 0,
    required this.title,
    this.description,
    required this.totalAmount,
    required this.installmentAmount,
    required this.totalInstallments,
    this.paidInstallments = 0,
    required this.remainingInstallments,
    this.paidAmount = 0.0,
    required this.remainingAmount,
    required this.startDate,
    this.nextDueDate,
    this.status = "active",
    DateTime? createdDate,
  }) : createdDate = createdDate ?? DateTime.now(),
       uuid = const Uuid().v4();

  factory Emi.fromJson(Map<String, dynamic> json) => _$EmiFromJson(json);
  Map<String, dynamic> toJson() => _$EmiToJson(this);
}
