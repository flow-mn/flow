import "package:flow/l10n/extensions.dart";
import "package:flow/prefs.dart";
import "package:flow/theme/color_themes/registry.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/theme_petal_selector.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";
// import "package:material_symbols_icons/symbols.dart";

class ThemePreferencesPage extends StatefulWidget {
  const ThemePreferencesPage({super.key});

  @override
  State<ThemePreferencesPage> createState() => _ThemePreferencesPageState();
}

class _ThemePreferencesPageState extends State<ThemePreferencesPage> {
  bool busy = false;
  bool appIconBusy = false;
  bool dynamicThemeBusy = false;
  bool oledThemeBusy = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final String currentTheme = LocalPreferences().getCurrentTheme();
    final bool isDark = getTheme(currentTheme).isDark;

    final bool themeChangesAppIcon =
        LocalPreferences().theme.themeChangesAppIcon.get();
    final bool enableOledTheme = LocalPreferences().theme.enableOledTheme.get();
    // final bool enableDynamicTheme = LocalPreferences().enableDynamicTheme.get();

    return Scaffold(
      appBar: AppBar(
        title: Text("preferences.theme.choose".t(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ThemePetalSelector(
                  updateOnHover: true,
                ),
              ),
              const SizedBox(height: 16.0),
              CheckboxListTile.adaptive(
                title: Text("preferences.theme.themeChangesAppIcon".t(context)),
                value: themeChangesAppIcon,
                onChanged: changeThemeChangesAppIcon,
                secondary: Icon(Symbols.photo_prints_rounded),
                activeColor: context.colorScheme.primary,
              ),
              CheckboxListTile.adaptive(
                title: Text("preferences.theme.enableOledTheme".t(context)),
                value: enableOledTheme,
                onChanged: changeEnableOledTheme,
                secondary: Icon(Symbols.brightness_4),
                activeColor: context.colorScheme.primary,
                enabled: isDark,
              ),
              // CheckboxListTile.adaptive(
              //   title: Text("preferences.theme.enableDynamicTheme".t(context)),
              //   value: enableDynamicTheme,
              //   onChanged: changeEnableDynamicTheme,
              //   secondary: Icon(Symbols.palette),
              //   activeColor: context.colorScheme.primary,
              // ),
              const SizedBox(height: 16.0),
              ListHeader(
                "preferences.theme.other".t(context),
              ),
              ...otherThemes.entries.map(
                (entry) => RadioListTile.adaptive(
                  title: Text(entry.value.name),
                  value: entry.key,
                  groupValue: currentTheme,
                  onChanged: (value) => handleChange(value),
                  activeColor: context.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void changeThemeChangesAppIcon(bool? newValue) async {
    if (newValue == null) return;
    if (appIconBusy) return;

    try {
      appIconBusy = true;
      await LocalPreferences().theme.themeChangesAppIcon.set(newValue);
      trySetThemeIcon(newValue ? LocalPreferences().getCurrentTheme() : null);
    } finally {
      appIconBusy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void changeEnableDynamicTheme(bool? newValue) async {
    if (newValue == null) return;
    if (dynamicThemeBusy) return;

    try {
      dynamicThemeBusy = true;
      await LocalPreferences().theme.enableDynamicTheme.set(newValue);
    } finally {
      dynamicThemeBusy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void changeEnableOledTheme(bool? newValue) async {
    if (newValue == null) return;
    if (oledThemeBusy) return;

    try {
      oledThemeBusy = true;
      await LocalPreferences().theme.enableOledTheme.set(newValue);
    } finally {
      oledThemeBusy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void handleChange(String? name) async {
    if (name == null) return;
    if (busy) return;

    try {
      await LocalPreferences().theme.themeName.set(name);
      if (LocalPreferences().theme.themeChangesAppIcon.get()) {
        trySetThemeIcon(name);
      }
    } finally {
      busy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }
}
