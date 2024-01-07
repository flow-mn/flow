import 'package:flow/entity/_base.dart';
import 'package:flow/entity/icon/parser.dart';
import 'package:flow/entity/transaction.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:objectbox/objectbox.dart';
import 'package:uuid/uuid.dart';
import 'package:material_symbols_icons/symbols.dart';

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
  IconData get icon {
    try {
      return IconCode.getIcon(iconCode);
    } catch (e) {
      return Symbols.error_rounded;
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
