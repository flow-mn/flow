import "dart:io";

import "package:flow/constants.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flow/widgets/square_map.dart";
import "package:flutter/material.dart";
import "package:geolocator/geolocator.dart";
import "package:go_router/go_router.dart";
import "package:latlong2/latlong.dart";
import "package:logging/logging.dart";
import "package:material_symbols_icons/symbols.dart";

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
  late LatLng center;

  bool useCurrentLocationWhenAvailable = false;

  @override
  void initState() {
    super.initState();

    center = LatLng(
      widget.latitude ?? sukhbaatarSquareCenterLat,
      widget.longitude ?? sukhbaatarSquareCenterLong,
    );

    useCurrentLocationWhenAvailable =
        widget.latitude == null || widget.longitude == null;
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      title: Text("general.selectLocation".t(context)),
      scrollableContentMaxHeight: MediaQuery.of(context).size.height * .8,
      trailing: ModalOverflowBar(
        alignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: () => context.pop(Optional<LatLng>(null)),
            icon: const Icon(Symbols.delete_rounded),
            label: Text("general.delete".t(context)),
          ),
          TextButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Symbols.block_rounded),
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
        child: OSMap(
          center: center,
          onTap:
              (pos) => setState(() {
                useCurrentLocationWhenAvailable = false;
                center = pos;
              }),
        ),
      ),
    );
  }

  void tryFetchLocation() {
    if (Platform.isLinux) return;
    if (LocalPreferences().enableGeo.get() != true) return;
    if (LocalPreferences().autoAttachTransactionGeo.get() != true) return;

    Geolocator.getLastKnownPosition()
        .then((lastKnown) {
          if (lastKnown == null) {
            return;
          }

          if (!useCurrentLocationWhenAvailable) return;

          if (mounted) {
            setState(() {
              center = LatLng(lastKnown.latitude, lastKnown.longitude);
            });
          }
        })
        .catchError((e) {
          _log.warning("Failed to get last known location", e);
        });

    Geolocator.getCurrentPosition()
        .then((current) {
          if (!useCurrentLocationWhenAvailable) return;

          center = LatLng(current.latitude, current.longitude);
        })
        .catchError((e) {
          _log.warning("Failed to get current location", e);
        })
        .whenComplete(() {
          if (mounted) {
            setState(() {
              useCurrentLocationWhenAvailable = false;
            });
          }
        });
  }
}
