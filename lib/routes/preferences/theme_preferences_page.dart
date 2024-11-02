import "package:flow/l10n/extensions.dart";
import "package:flow/prefs.dart";
import "package:flow/theme/color_themes/registry.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/theme_petal_selector.dart";
import "package:flutter/material.dart";
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final String currentTheme = LocalPreferences().getCurrentTheme();
    // final bool themeChangesAppIcon =
    // LocalPreferences().themeChangesAppIcon.get();
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
              // const SizedBox(height: 16.0),
              // CheckboxListTile.adaptive(
              //   title: Text("preferences.theme.themeChangesAppIcon".t(context)),
              //   value: themeChangesAppIcon,
              //   onChanged: changeThemeChangesAppIcon,
              //   secondary: Icon(Symbols.photo_prints_rounded),
              // ),
              // CheckboxListTile.adaptive(
              //   title: Text("preferences.theme.enableDynamicTheme".t(context)),
              //   value: enableDynamicTheme,
              //   onChanged: changeEnableDynamicTheme,
              //   secondary: Icon(Symbols.palette),
              // ),
              const SizedBox(height: 16.0),
              ListHeader(
                "preferences.theme.other".t(context),
              ),
              RadioListTile.adaptive(
                title: Text(palenight.name),
                value: "palenight",
                groupValue: currentTheme,
                onChanged: (value) => handleChange(value),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void changeThemeChangesAppIcon(bool? newValue) {
    if (newValue == null) return;
    if (appIconBusy) return;

    try {
      appIconBusy = true;
      LocalPreferences().themeChangesAppIcon.set(newValue);
    } catch (e) {
      // Silent fail. TODO @sadespresso
    } finally {
      appIconBusy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void changeEnableDynamicTheme(bool? newValue) {
    if (newValue == null) return;
    if (dynamicThemeBusy) return;

    try {
      dynamicThemeBusy = true;
      LocalPreferences().enableDynamicTheme.set(newValue);
    } catch (e) {
      // Silent fail. TODO @sadespresso
    } finally {
      dynamicThemeBusy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void handleChange(String? name) async {
    if (name == null) return;
    if (busy) return;

    try {
      await LocalPreferences().themeName.set(name);
    } finally {
      busy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }
}
