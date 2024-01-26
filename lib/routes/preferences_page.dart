import 'package:flow/l10n/flow_localizations.dart';
import 'package:flow/main.dart';
import 'package:flow/prefs.dart';
import 'package:flow/routes/preferences/language_selection_sheet.dart';
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
    final bool currentlyUsingDarkTheme = Flow.of(context).useDarkTheme;

    final IconData themeIcon = currentlyUsingDarkTheme
        ? Symbols.dark_mode_rounded
        : Symbols.light_mode_rounded;

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
      final ThemeMode newThemeMode =
          Flow.of(context).useDarkTheme ? ThemeMode.light : ThemeMode.dark;

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

      final selected = await showModalBottomSheet<Locale>(
        context: context,
        builder: (context) => LanguageSelectionSheet(
          currentLocale: current,
        ),
      );

      if (selected != null) {
        await LocalPreferences().localeOverride.set(selected);
      }
    } finally {
      _languageBusy = false;
    }
  }
}
