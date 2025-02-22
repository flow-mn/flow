import "dart:io";

import "package:app_settings/app_settings.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/utils/extensions/toast.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
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
  @override
  Widget build(BuildContext context) {
    final bool geoSupported = !Platform.isLinux;

    final bool enableGeo = LocalPreferences().enableGeo.get();
    final bool autoAttachTransactionGeo =
        LocalPreferences().autoAttachTransactionGeo.get();

    return Scaffold(
      appBar: AppBar(title: Text("preferences.transactionGeo".t(context))),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              CheckboxListTile /*.adaptive*/ (
                title: Text("preferences.transactionGeo.enable".t(context)),
                value: enableGeo,
                onChanged: updateEnableGeo,
              ),
              if (geoSupported) ...[
                const SizedBox(height: 16.0),
                CheckboxListTile /*.adaptive*/ (
                  title: Text(
                    "preferences.transactionGeo.auto.enable".t(context),
                  ),
                  value: autoAttachTransactionGeo,
                  onChanged: updateAutoAttachTransactionGeo,
                ),
                const SizedBox(height: 16.0),
                Frame(
                  child: InfoText(
                    child: Text(
                      "preferences.transactionGeo.auto.description".t(context),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

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
        if (!retryAfterOpeningSettings) return false;

        await AppSettings.openAppSettings(type: AppSettingsType.location);
        return await tryRequestPermission(false);
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
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
          error: "preferences.transactionGeo.auto.permissionDenied".t(context),
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
