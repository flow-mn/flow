import "package:flow/entity/transaction/extensions/base.dart";
import "package:flow/utils/json/utc_datetime_converter.dart";
import "package:flow/utils/utils.dart";
import "package:geolocator/geolocator.dart";
import "package:json_annotation/json_annotation.dart";
import "package:latlong2/latlong.dart";
import "package:uuid/uuid.dart";

part "geo.g.dart";

@JsonSerializable(explicitToJson: true, converters: [UTCDateTimeConverter()])
class Geo extends TransactionExtension implements Jasonable {
  static const String keyName = "@flow/default-geo";

  @override
  @JsonKey(includeToJson: true)
  final String key = Geo.keyName;

  @override
  String? relatedTransactionUuid;

  @override
  void setRelatedTransactionUuid(String uuid) => relatedTransactionUuid = uuid;

  double? latitude;
  double? longitude;
  double? altitude;
  DateTime? timestamp;
  bool isMocked;

  String? toSexagesimal() {
    if (latitude == null || longitude == null) return null;

    return LatLng(latitude!, longitude!).toSexagesimal();
  }

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
  }) => Geo(
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

  factory Geo.fromLatLng(LatLng latLng) => Geo(
    uuid: const Uuid().v4(),
    latitude: latLng.latitude,
    longitude: latLng.longitude,
    altitude: null,
    timestamp: DateTime.now(),
    isMocked: false,
  );

  factory Geo.fromJson(Map<String, dynamic> json) => _$GeoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GeoToJson(this);
}
