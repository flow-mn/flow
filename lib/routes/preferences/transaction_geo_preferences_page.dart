import "dart:io";

import "package:app_settings/app_settings.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/utils/extensions/toast.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/geo_permission_missing_reminder.dart";
import "package:flutter/material.dart";
import "package:geolocator/geolocator.dart";

class TransactionGeoPreferencesPage extends StatefulWidget {
  const TransactionGeoPreferencesPage({super.key});

  @override
  State<TransactionGeoPreferencesPage> createState() =>
      _TransactionGeoPreferencesPageState();
}

class _TransactionGeoPreferencesPageState
    extends State<TransactionGeoPreferencesPage> {
  late final AppLifecycleListener _listener;

  late Future<LocationPermission> _geoPermissionGranted;

  @override
  void initState() {
    super.initState();

    _geoPermissionGranted = Geolocator.checkPermission();

    _listener = AppLifecycleListener(
      onShow: () {
        _geoPermissionGranted = Geolocator.checkPermission();
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool geoSupported = !Platform.isLinux;

    final bool enableGeo = LocalPreferences().enableGeo.get();
    final bool autoAttachTransactionGeo =
        LocalPreferences().autoAttachTransactionGeo.get();

    return Scaffold(
      appBar: AppBar(title: Text("preferences.transactions.geo".t(context))),
      body: SafeArea(
        child: FutureBuilder(
          future: _geoPermissionGranted,
          builder: (context, snapshot) {
            final LocationPermission? permissionData = snapshot.data;
            final bool hasPermission =
                permissionData != null && resolvePermission(permissionData);

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16.0),
                  CheckboxListTile(
                    title: Text(
                      "preferences.transactions.geo.enable".t(context),
                    ),
                    value: enableGeo,
                    onChanged: updateEnableGeo,
                  ),
                  if (geoSupported) ...[
                    const SizedBox(height: 16.0),
                    CheckboxListTile(
                      title: Text(
                        "preferences.transactions.geo.auto.enable".t(context),
                      ),
                      value: autoAttachTransactionGeo,
                      onChanged: updateAutoAttachTransactionGeo,
                    ),
                    if (permissionData != null && !hasPermission) ...[
                      const SizedBox(height: 16.0),
                      GeoPermissionMissingReminder(),
                    ],
                    const SizedBox(height: 16.0),
                    Frame(
                      child: InfoText(
                        child: Text(
                          "preferences.transactions.geo.auto.description".t(
                            context,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16.0),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  bool resolvePermission(LocationPermission permission) => switch (permission) {
    LocationPermission.whileInUse || LocationPermission.always => true,
    _ => false,
  };

  Future<bool> tryRequestPermission([
    bool retryAfterOpeningSettings = true,
  ]) async {
    final LocationPermission currentPermission =
        await Geolocator.checkPermission();

    switch (currentPermission) {
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return true;
      case LocationPermission.deniedForever:
      case LocationPermission.unableToDetermine:
        if (!retryAfterOpeningSettings) return false;

        await AppSettings.openAppSettings(type: AppSettingsType.location);
        return await tryRequestPermission(false);
      case LocationPermission.denied:
        break;
    }

    final LocationPermission newPermission =
        await Geolocator.requestPermission();

    switch (newPermission) {
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return true;
      case LocationPermission.denied:
      case LocationPermission.deniedForever:
      case LocationPermission.unableToDetermine:
        return false;
    }
  }

  void updateEnableGeo(bool? newEnableGeo) async {
    if (newEnableGeo == null) return;

    await LocalPreferences().enableGeo.set(newEnableGeo);

    if (mounted) setState(() {});
  }

  void updateAutoAttachTransactionGeo(bool? newAutoAttachTransactionGeo) async {
    if (newAutoAttachTransactionGeo == null) return;

    if (newAutoAttachTransactionGeo) {
      final bool granted = await tryRequestPermission();

      if (!mounted) return;

      if (!granted) {
        context.showErrorToast(
          error: "preferences.transactions.geo.auto.permissionDenied".t(
            context,
          ),
        );

        await LocalPreferences().autoAttachTransactionGeo.set(false);
      }

      await LocalPreferences().autoAttachTransactionGeo.set(
        newAutoAttachTransactionGeo,
      );
    } else {
      await LocalPreferences().autoAttachTransactionGeo.set(
        newAutoAttachTransactionGeo,
      );
    }

    if (mounted) setState(() {});
  }
}
