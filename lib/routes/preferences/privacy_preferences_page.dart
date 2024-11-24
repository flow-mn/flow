import "package:flow/l10n/extensions.dart";
import "package:flow/prefs.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flutter/material.dart";

class PrivacyPreferencesPage extends StatefulWidget {
  const PrivacyPreferencesPage({super.key});

  @override
  State<PrivacyPreferencesPage> createState() => _PrivacyPreferencesPageState();
}

class _PrivacyPreferencesPageState extends State<PrivacyPreferencesPage> {
  @override
  Widget build(BuildContext context) {
    final bool privacyMode = LocalPreferences().privacyMode.get();

    return Scaffold(
      appBar: AppBar(
        title: Text("preferences.privacyMode".t(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: InfoText(
                  child: Text(
                    "preferences.privacyMode.description".t(context),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              CheckboxListTile.adaptive(
                title:
                    Text("preferences.privacyMode.enableAtStartup".t(context)),
                value: privacyMode,
                onChanged: updatePrivacyMode,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updatePrivacyMode(bool? newPrivacyMode) async {
    if (newPrivacyMode == null) return;

    await LocalPreferences().privacyMode.set(newPrivacyMode);

    if (mounted) setState(() {});
  }
}
