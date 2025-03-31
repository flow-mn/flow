import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/widgets/home/preferences/numpad_preferences/numpad_selector_radio.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flutter/material.dart";

class NumpadPreferencesPage extends StatefulWidget {
  const NumpadPreferencesPage({super.key});

  @override
  State<NumpadPreferencesPage> createState() => _NumpadPreferencesPageState();
}

class _NumpadPreferencesPageState extends State<NumpadPreferencesPage> {
  @override
  Widget build(BuildContext context) {
    final bool usePhoneNumpadLayout =
        LocalPreferences().usePhoneNumpadLayout.get();

    return Scaffold(
      appBar: AppBar(title: Text("preferences.numpad".t(context))),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              ListHeader("preferences.numpad.layout".t(context)),
              const SizedBox(height: 8.0),
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 600.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      spacing: 16.0,
                      children: [
                        Expanded(
                          child: NumpadSelectorRadio.classic(
                            onTap: () => updateLayoutPreference(false),
                            currentlyUsingPhoneLayout: usePhoneNumpadLayout,
                          ),
                        ),
                        Expanded(
                          child: NumpadSelectorRadio.phone(
                            onTap: () => updateLayoutPreference(true),
                            currentlyUsingPhoneLayout: usePhoneNumpadLayout,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32.0),
            ],
          ),
        ),
      ),
    );
  }

  void updateLayoutPreference(bool usePhoneLayout) async {
    await LocalPreferences().usePhoneNumpadLayout.set(usePhoneLayout);

    if (mounted) setState(() {});
  }
}
