import "package:flow/constants.dart";
import "package:flutter/material.dart";
import "package:flutter_map/flutter_map.dart";
import "package:latlong2/latlong.dart";
import "package:flow/widgets/utils/utils.dart";

class OSMap extends StatelessWidget {
  final bool interactable;
  final LatLng center;
  final Function(LatLng)? onTap;
  final MapController? mapController;

  const OSMap({
    super.key,
    this.center = sukhbaatarSquareCenter,
    this.mapController,
    this.interactable = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        onTap: (_, pos) => onTap?.call(pos),
        initialCenter: center,
        initialZoom: 17.0,
        keepAlive: interactable,
        interactionOptions:
            interactable
                ? const InteractionOptions()
                : InteractionOptions(flags: InteractiveFlag.none),
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
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              "OpenStreetMap contributors",
              onTap:
                  () =>
                      openUrl(Uri.parse("https://openstreetmap.org/copyright")),
            ),
          ],
          popupBackgroundColor: Color(0xC0FFFFFF),
        ),
      ],
    );
  }
}
