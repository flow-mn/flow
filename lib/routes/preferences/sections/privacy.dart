import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences_page.dart";
import "package:flow/services/user_preferences.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class Privacy extends StatefulWidget {
  const Privacy({super.key});

  @override
  State<Privacy> createState() => _PrivacyState();
}

class _PrivacyState extends State<Privacy> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      children: [
        SwitchListTile(
          secondary: const Icon(Symbols.password_rounded),
          title: Text("preferences.privacy.maskAtStartup".t(context)),
          value: UserPreferencesService().privacyModeUponLaunch,
          onChanged: updatePrivacyMode,
        ),
        SwitchListTile(
          secondary: const Icon(Symbols.earthquake_rounded),
          title: Text("preferences.privacy.maskAtShake".t(context)),
          value: UserPreferencesService().privacyModeUponShaking,
          onChanged: updatePrivacyModeUponShaking,
        ),
      ],
    );
  }

  void updatePrivacyMode(bool? newPrivacyMode) async {
    if (newPrivacyMode == null) return;

    UserPreferencesService().privacyModeUponLaunch = newPrivacyMode;

    if (!mounted) return;

    PreferencesPage.of(context).reload();
    setState(() {});
  }

  void updatePrivacyModeUponShaking(bool? newPrivacyMode) async {
    if (newPrivacyMode == null) return;

    UserPreferencesService().privacyModeUponShaking = newPrivacyMode;

    if (!mounted) return;

    PreferencesPage.of(context).reload();
    setState(() {});
  }
}
