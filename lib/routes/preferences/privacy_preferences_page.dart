import "package:flow/l10n/extensions.dart";
import "package:flow/prefs.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flutter/material.dart";

class StartupPrivacyPreferencesPage extends StatefulWidget {
  const StartupPrivacyPreferencesPage({super.key});

  @override
  State<StartupPrivacyPreferencesPage> createState() =>
      _StartupPrivacyPreferencesPageState();
}

class _StartupPrivacyPreferencesPageState
    extends State<StartupPrivacyPreferencesPage> {
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
              InfoText(
                child: Text(
                  "preferences.privacyMode.description".t(context),
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
