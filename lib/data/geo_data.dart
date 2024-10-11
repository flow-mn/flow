import "package:flow/utils/utils.dart";
import "package:geolocator/geolocator.dart";
import "package:json_annotation/json_annotation.dart";

@JsonSerializable()
class GeoData implements Jasonable {
  final double? latitude;
  final double? longitude;
  final double? altitude;
  final DateTime? timestamp;
  final bool isMocked;

  const GeoData({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.timestamp,
    this.isMocked = false,
  });

  factory GeoData.fromPosition(Position position) => GeoData(
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
        timestamp: position.timestamp,
        isMocked: false,
      );

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}
