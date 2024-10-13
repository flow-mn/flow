import "package:flow/entity/transaction/extensions/base.dart";
import "package:flow/utils/utils.dart";
import "package:geolocator/geolocator.dart";
import "package:json_annotation/json_annotation.dart";
import "package:uuid/uuid.dart";

part "geo.g.dart";

@JsonSerializable()
class Geo extends TransactionExtension implements Jasonable {
  static const String keyName = "@flow/default-geo";

  @override
  @JsonKey(includeToJson: true)
  final String key = Geo.keyName;

  @override
  String? relatedTransactionUuid;

  @override
  setRelatedTransactionUuid(String uuid) => relatedTransactionUuid = uuid;

  final double? latitude;
  final double? longitude;
  final double? altitude;
  final DateTime? timestamp;
  final bool isMocked;

  Geo({
    required super.uuid,
    required this.latitude,
    required this.longitude,
    this.relatedTransactionUuid,
    this.altitude,
    this.timestamp,
    this.isMocked = false,
  }) : super();

  Geo copyWith({
    String? uuid,
    String? relatedTransactionUuid,
    double? latitude,
    double? longitude,
    double? altitude,
    DateTime? timestamp,
    bool? isMocked,
  }) =>
      Geo(
        uuid: uuid ?? this.uuid,
        relatedTransactionUuid:
            relatedTransactionUuid ?? this.relatedTransactionUuid,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        altitude: altitude ?? this.altitude,
        timestamp: timestamp ?? this.timestamp,
        isMocked: isMocked ?? this.isMocked,
      );

  factory Geo.fromPosition(Position position) => Geo(
        uuid: const Uuid().v4(),
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
        timestamp: position.timestamp,
        isMocked: position.isMocked,
      );

  factory Geo.fromJson(Map<String, dynamic> json) => _$GeoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GeoToJson(this);
}
