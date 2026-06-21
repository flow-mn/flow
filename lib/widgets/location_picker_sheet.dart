import "dart:io";

import "package:flow/constants.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flow/widgets/open_street_map.dart";
import "package:flutter/material.dart";
import "package:flutter_map/flutter_map.dart";
import "package:geolocator/geolocator.dart";
import "package:go_router/go_router.dart";
import "package:latlong2/latlong.dart";
import "package:logging/logging.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:permission_handler/permission_handler.dart";

final Logger _log = Logger("LocationPickerSheet");

class LocationPickerSheet extends StatefulWidget {
  final double? latitude;
  final double? longitude;

  const LocationPickerSheet({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  final MapController _mapController = MapController();

  late LatLng center;

  bool _locationBusy = false;

  bool get _myLocationAvailable => Platform.isAndroid || Platform.isIOS;

  @override
  void initState() {
    super.initState();

    center = LatLng(
      widget.latitude ?? sukhbaatarSquareCenterLat,
      widget.longitude ?? sukhbaatarSquareCenterLong,
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      title: Text("general.selectLocation".t(context)),
      scrollableContentMaxHeight: MediaQuery.of(context).size.height * .8,
      trailing: ModalOverflowBar(
        alignment: .end,
        children: [
          TextButton.icon(
            onPressed: () => context.pop(Optional<LatLng>(null)),
            icon: const Icon(Symbols.delete_rounded),
            label: Text("general.delete".t(context)),
          ),
          TextButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Symbols.block_rounded, fill: 0.0),
            label: Text("general.cancel".t(context)),
          ),
          TextButton.icon(
            onPressed: () => context.pop(Optional<LatLng>(center)),
            icon: const Icon(Symbols.check_rounded),
            label: Text("general.done".t(context)),
          ),
        ],
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .75,
        child: Stack(
          children: [
            OpenStreetMap(
              mapController: _mapController,
              center: center,
              onTap: (pos) => setState(() => center = pos),
            ),
            if (_myLocationAvailable)
              Positioned(
                right: 16.0,
                bottom: 16.0,
                child: FloatingActionButton.small(
                  heroTag: null,
                  tooltip: "transaction.tags.location.useCurrent".t(context),
                  onPressed: _locationBusy ? null : _useMyLocation,
                  child: _locationBusy
                      ? const SizedBox.square(
                          dimension: 20.0,
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                        )
                      : const Icon(Symbols.my_location_rounded),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _useMyLocation() async {
    if (_locationBusy) return;

    setState(() => _locationBusy = true);

    try {
      final PermissionStatus status = await Permission.locationWhenInUse
          .request();

      switch (status) {
        case PermissionStatus.limited:
        case PermissionStatus.granted:
          break;
        default:
          if (mounted) {
            context.showErrorToast(
              error: "preferences.transactions.geo.auto.permissionDenied".t(
                context,
              ),
            );
          }
          return;
      }

      final Position position = await Geolocator.getCurrentPosition();
      if (!mounted) return;

      final LatLng point = LatLng(position.latitude, position.longitude);
      setState(() => center = point);
      _mapController.move(point, _mapController.camera.zoom);
    } catch (e, stackTrace) {
      _log.warning("Failed to get current location", e, stackTrace);
    } finally {
      _locationBusy = false;
      if (mounted) setState(() {});
    }
  }
}
