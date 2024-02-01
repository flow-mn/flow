import 'package:flow/entity/_base.dart';
import 'package:flow/objectbox.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:objectbox/objectbox.dart';
import 'package:uuid/uuid.dart';

part "profile.g.dart";

@Entity()
@JsonSerializable()
class Profile implements EntityBase {
  @JsonKey(includeFromJson: false, includeToJson: false)
  int id;

  @override
  @Unique()
  String uuid;

  String name;

  @Property(type: PropertyType.date)
  DateTime createdDate;

  @Transient()
  String get imagePath => "$uuid.png";

  Profile({
    this.id = 0,
    DateTime? createdDate,
    required this.name,
  })  : createdDate = createdDate ?? DateTime.now(),
        uuid = const Uuid().v4();

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  static createDefaultProfile() {
    ObjectBox().box<Profile>().put(
          Profile(
            name: "Default Profile",
          ),
        );
  }
}
