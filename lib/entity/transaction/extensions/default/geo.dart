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

  final String uuid;
  final String relatedTransactionUuid;

  final double? latitude;
  final double? longitude;
  final double? altitude;
  final DateTime? timestamp;
  final bool isMocked;

  const Geo({
    required this.uuid,
    required this.relatedTransactionUuid,
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.timestamp,
    this.isMocked = false,
  }) : super();

  factory Geo.fromPosition(String relatedTransactionUuid, Position position) =>
      Geo(
        uuid: const Uuid().v4(),
        relatedTransactionUuid: relatedTransactionUuid,
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
