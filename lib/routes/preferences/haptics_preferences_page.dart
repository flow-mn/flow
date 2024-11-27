import "package:flow/l10n/extensions.dart";
import "package:flow/prefs.dart";
import "package:flutter/material.dart";

class HapticsPreferencesPage extends StatefulWidget {
  const HapticsPreferencesPage({super.key});

  @override
  State<HapticsPreferencesPage> createState() => _HapticsPreferencesPageState();
}

class _HapticsPreferencesPageState extends State<HapticsPreferencesPage> {
  @override
  Widget build(BuildContext context) {
    final bool enableHapticFeedback =
        LocalPreferences().enableHapticFeedback.get();

    return Scaffold(
      appBar: AppBar(
        title: Text("preferences.hapticFeedback".t(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              CheckboxListTile.adaptive(
                title:
                    Text("preferences.hapticFeedback.description".t(context)),
                value: enableHapticFeedback,
                onChanged: updateEnableHapticFeedback,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateEnableHapticFeedback(bool? newEnableHapticFeedback) async {
    if (newEnableHapticFeedback == null) return;

    await LocalPreferences().enableHapticFeedback.set(newEnableHapticFeedback);

    if (mounted) setState(() {});
  }
}
