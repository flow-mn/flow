import 'package:flex_color_picker/flex_color_picker.dart';
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
                title: Text("preferences.theme.setPrimaryColor".t(context)),
                leading: const Icon(Icons.color_lens),
                trailing: const Icon(Icons.chevron_right),
                subtitle: _buildCurrentPrimaryThemeName(context),
                onTap: () => updatePrimaryColor(context),
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

  Widget _buildCurrentPrimaryThemeName(BuildContext context) {
    try {
      final Color primaryColor = Theme.of(context).colorScheme.primary;

      final primaryColorName = ColorNames.guess(primaryColor);

      return Text(primaryColorName);
    } catch (e) {
      return Text("error.preferences.unknownColor".t(context));
    }
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

  void updatePrimaryColor(BuildContext context) async {
    if (_themeBusy) return;

    setState(() {
      _themeBusy = true;
    });

    try {
      final selected = await openColorPickerDialog(context);
      if (selected) {
        _openConfirmDialog();
      }
    } finally {
      _themeBusy = false;
    }
  }

  void _openConfirmDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("preferences.theme.setPrimaryColorDialog.title".t(context)),
        content:
            Text("preferences.theme.setPrimaryColorDialog.content".t(context)),
        // Text("".t(context)),
        // content:
        //     Text("preferences.primaryColor.confirmDialogMessage".t(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("general.confirm.okay",
                style: Theme.of(context).textTheme.titleSmall),
          ),
        ],
      ),
    );
  }

  Future<bool> openColorPickerDialog(BuildContext context) async {
    return ColorPicker(
      // Use the dialogPickerColor as start color.
      color: context.colorScheme.primary,
      // Update the dialogPickerColor using the callback.
      onColorChanged: (Color color) async {
        await LocalPreferences().setPrimaryColor(color);
      },
      width: 40,
      height: 40,
      borderRadius: 4,
      spacing: 5,
      runSpacing: 5,
      wheelDiameter: 155,
      showMaterialName: true,
      showColorName: true,
      showColorCode: true,
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        longPressMenu: true,
        copyButton: true,
        pasteButton: true,
      ),
      materialNameTextStyle: Theme.of(context).textTheme.bodySmall,
      colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
      colorCodeTextStyle: Theme.of(context).textTheme.bodySmall,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.wheel: true,
        ColorPickerType.accent: false,
      },
    ).showPickerDialog(
      context,
      transitionBuilder: (BuildContext context, Animation<double> a1,
          Animation<double> a2, Widget widget) {
        final double curvedValue =
            Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Opacity(
            opacity: a1.value,
            child: widget,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
      constraints:
          const BoxConstraints(minHeight: 460, minWidth: 300, maxWidth: 320),
    );
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
