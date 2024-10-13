import "package:flutter/material.dart";
import "package:flutter_map/flutter_map.dart";
import "package:latlong2/latlong.dart";

class GeoPreview extends StatelessWidget {
  final double? latitude;
  final double? longitude;

  static const double sukhbaatarSquareCenterLat = 47.918828;
  static const double sukhbaatarSquareCenterLong = 106.917604;

  const GeoPreview({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    final LatLng center = LatLng(
      latitude ?? sukhbaatarSquareCenterLat,
      longitude ?? sukhbaatarSquareCenterLong,
    );

    return AspectRatio(
      aspectRatio: 1.0,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: center,
          initialZoom: 17.0,
          keepAlive: false,
          interactionOptions: InteractionOptions(flags: InteractiveFlag.none),
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: center,
                child: Image.asset("assets/images/pin.png"),
                alignment: Alignment.topCenter,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
