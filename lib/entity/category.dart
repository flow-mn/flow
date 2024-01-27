import 'package:flow/data/flow_icon.dart';
import 'package:flow/entity/_base.dart';
import 'package:flow/entity/transaction.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:objectbox/objectbox.dart';
import 'package:uuid/uuid.dart';

part "category.g.dart";

@Entity()
@JsonSerializable()
class Category implements EntityBase {
  @JsonKey(includeFromJson: false, includeToJson: false)
  int id;

  @override
  @Unique()
  String uuid;

  @Property(type: PropertyType.date)
  DateTime createdDate;

  @Unique()
  String name;

  @Backlink('category')
  @JsonKey(includeFromJson: false, includeToJson: false)
  final transactions = ToMany<Transaction>();

  String iconCode;

  @Transient()
  FlowIconData get icon {
    try {
      return FlowIconData.parse(iconCode);
    } catch (e) {
      return FlowIconData.emoji("🤷");
    }
  }

  Category({
    this.id = 0,
    required this.name,
    required this.iconCode,
    DateTime? createdDate,
  })  : createdDate = createdDate ?? DateTime.now(),
        uuid = const Uuid().v4();

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
