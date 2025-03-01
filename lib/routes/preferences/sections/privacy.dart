import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/routes/preferences_page.dart";
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
    final bool privacyMode = LocalPreferences().privacyMode.get();

    return SwitchListTile /*.adaptive*/ (
      secondary: const Icon(Symbols.password_rounded),
      title: Text("preferences.privacy.maskAtStartup".t(context)),
      value: privacyMode,
      onChanged: updatePrivacyMode,
    );
  }

  void updatePrivacyMode(bool? newPrivacyMode) async {
    if (newPrivacyMode == null) return;

    await LocalPreferences().privacyMode.set(newPrivacyMode);

    if (!mounted) return;

    PreferencesPage.of(context).reload();
    setState(() {});
  }
}
