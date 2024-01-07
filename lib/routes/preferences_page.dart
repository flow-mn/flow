import 'package:flow/l10n/extensions.dart';
import 'package:flow/l10n/flow_localizations.dart';
import 'package:flow/prefs.dart';
import 'package:flow/widgets/home/prefs/action_tile.dart';
import 'package:flutter/material.dart' hide Flow;
import 'package:material_symbols_icons/symbols.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  bool _themeBusy = false;
  bool _languageBusy = false;

  @override
  Widget build(BuildContext context) {
    const IconData themeIcon = Symbols.dark_mode_rounded;
    // final IconData themeIcon = Flow.of(context).

    return Scaffold(
      appBar: AppBar(
        title: Text("preferences".t(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ActionTile(
                title: "preferences.themeMode".t(context),
                icon: themeIcon,
                onTap: () => updateTheme(),
              ),
              const SizedBox(height: 16.0),
              ActionTile(
                title: "preferences.language".t(context),
                icon: Symbols.language_rounded,
                onTap: () => updateLanguage(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateTheme() async {
    if (_themeBusy) return;

    _themeBusy = true;

    try {
      ThemeMode current = LocalPreferences().themeMode.get();

      if (current == ThemeMode.system) {
        current = switch (MediaQuery.of(context).platformBrightness) {
          Brightness.dark => ThemeMode.dark,
          Brightness.light => ThemeMode.light,
        };
      }

      final ThemeMode newThemeMode = switch (current) {
        ThemeMode.light => ThemeMode.dark,
        _ => ThemeMode.light,
      };

      await LocalPreferences().themeMode.set(newThemeMode);
    } finally {
      _themeBusy = false;
    }
  }

  void updateLanguage() async {
    if (_languageBusy) return;

    _languageBusy = true;

    try {
      Locale current = LocalPreferences().localeOverride.get() ??
          FlowLocalizations.supportedLanguages.first;

      // TODO show bottom sheet or dialog or dropdown menu

      await LocalPreferences().localeOverride.set(current.languageCode == "mn"
          ? const Locale("en", "US")
          : const Locale("mn", "MN"));
    } finally {
      _languageBusy = false;
    }
  }
}
