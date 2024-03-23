import 'package:flow/l10n/flow_localizations.dart';
import 'package:flow/main.dart';
import 'package:flow/prefs.dart';
import 'package:flow/routes/preferences/language_selection_sheet.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/select_currency_sheet.dart';
import 'package:flutter/material.dart' hide Flow;
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  bool _themeBusy = false;
  bool _currencyBusy = false;
  bool _languageBusy = false;

  @override
  Widget build(BuildContext context) {
    final ThemeMode currentThemeMode = Flow.of(context).themeMode;

    return Scaffold(
      appBar: AppBar(
        title: Text("preferences".t(context)),
      ),
      body: SafeArea(
        child: ListView(
          children: ListTile.divideTiles(
            tiles: [
              ListTile(
                title: Text("preferences.themeMode".t(context)),
                leading: switch (currentThemeMode) {
                  ThemeMode.system => const Icon(Symbols.routine_rounded),
                  ThemeMode.dark => const Icon(Symbols.light_mode_rounded),
                  ThemeMode.light => const Icon(Symbols.dark_mode_rounded),
                },
                subtitle: Text(switch (currentThemeMode) {
                  ThemeMode.system => "preferences.themeMode.system".t(context),
                  ThemeMode.dark => "preferences.themeMode.dark".t(context),
                  ThemeMode.light => "preferences.themeMode.light".t(context),
                }),
                onTap: () => updateTheme(),
                onLongPress: () => updateTheme(ThemeMode.system),
                trailing: const Icon(Symbols.chevron_right_rounded),
              ),
              ListTile(
                title: Text('Set Primary Color'),
                leading: Icon(Icons.color_lens),
                trailing: Icon(Icons.chevron_right),
                subtitle: Text(
                  switch (Flow.of(context).themeMode) {
                    ThemeMode.system =>
                      "preferences.themeMode.system".t(context),
                    ThemeMode.dark => "preferences.themeMode.dark".t(context),
                    ThemeMode.light => "preferences.themeMode.light".t(context),
                  },
                ),
              ),
              ListTile(
                title: Text("preferences.language".t(context)),
                leading: const Icon(Symbols.language_rounded),
                onTap: () => updateLanguage(),
                subtitle: Text(FlowLocalizations.of(context).locale.name),
                trailing: const Icon(Symbols.chevron_right_rounded),
              ),
              ListTile(
                title: Text("preferences.primaryCurrency".t(context)),
                leading: const Icon(Symbols.universal_currency_alt_rounded),
                onTap: () => updatePrimaryCurrency(),
                subtitle: Text(LocalPreferences().getPrimaryCurrency()),
                trailing: const Icon(Symbols.chevron_right_rounded),
              ),
              ListTile(
                title: Text("preferences.numpad".t(context)),
                leading: const Icon(Symbols.dialpad_rounded),
                onTap: openNumpadPrefs,
                subtitle: Text(
                  LocalPreferences().usePhoneNumpadLayout.get()
                      ? "preferences.numpad.layout.modern".t(context)
                      : "preferences.numpad.layout.classic".t(context),
                ),
                trailing: const Icon(Symbols.chevron_right_rounded),
              ),
              ListTile(
                title: Text("preferences.transfer".t(context)),
                leading: const Icon(Symbols.sync_alt_rounded),
                onTap: openTransferPrefs,
                subtitle: Text(
                  "preferences.transfer.description".t(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Symbols.chevron_right_rounded),
              ),
            ],
            color: context.colorScheme.onBackground.withAlpha(0x20),
          ).toList(),
        ),
      ),
    );
  }

  void updateTheme([ThemeMode? force]) async {
    if (_themeBusy) return;

    setState(() {
      _themeBusy = true;
    });

    try {
      final ThemeMode newThemeMode = force ??
          switch ((Flow.of(context).themeMode, Flow.of(context).useDarkTheme)) {
            (ThemeMode.light, _) => ThemeMode.dark,
            (ThemeMode.dark, _) => ThemeMode.light,
            (ThemeMode.system, true) => ThemeMode.light,
            (ThemeMode.system, false) => ThemeMode.dark,
          };

      await LocalPreferences().themeMode.set(newThemeMode);

      if (mounted) {
        // Even tho the whole app state refreshes, it doesn't get refreshed
        // if we switch from same ThemeMode as system from ThemeMode.system.
        // So this call is necessary
        setState(() {});
      }
    } finally {
      _themeBusy = false;
    }
  }

  void updateLanguage() async {
    if (_languageBusy) return;

    setState(() {
      _languageBusy = true;
    });

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

  void updatePrimaryCurrency() async {
    if (_currencyBusy) return;

    setState(() {
      _currencyBusy = true;
    });

    try {
      String current = LocalPreferences().getPrimaryCurrency();

      final selected = await showModalBottomSheet<String>(
        context: context,
        builder: (context) => SelectCurrencySheet(currentlySelected: current),
      );

      if (selected != null) {
        await LocalPreferences().primaryCurrency.set(selected);
      }
    } finally {
      _currencyBusy = false;
    }
  }

  void openNumpadPrefs() async {
    await context.push("/preferences/numpad");

    // Rebuild to update description text
    if (mounted) setState(() {});
  }

  void openTransferPrefs() async {
    await context.push("/preferences/transfer");
  }
}
