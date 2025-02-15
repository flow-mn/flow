import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/theme/color_themes/registry.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/theme/names.dart";
import "package:flow/utils/extensions.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/theme_petal_selector.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class ThemePreferencesPage extends StatefulWidget {
  const ThemePreferencesPage({super.key});

  @override
  State<ThemePreferencesPage> createState() => _ThemePreferencesPageState();
}

class _ThemePreferencesPageState extends State<ThemePreferencesPage> {
  bool busy = false;
  bool appIconBusy = false;

  String selectedGroup = groups.keys.first;

  @override
  void initState() {
    super.initState();

    final String currentTheme = LocalPreferences().getCurrentTheme();

    groups.entries
            .firstWhereOrNull(
              (entry) => entry.value.any(
                (group) => group.name == currentTheme,
              ),
            )
            ?.key ??
        groups.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    final String currentTheme = LocalPreferences().getCurrentTheme();
    final String? currentThemeName = themeNames[currentTheme];

    final bool themeChangesAppIcon =
        LocalPreferences().theme.themeChangesAppIcon.get();

    return Scaffold(
      appBar: AppBar(
        title: Text("preferences.theme.choose".t(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Frame(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 12.0,
                    children: groups.keys
                        .map(
                          (group) => FilterChip(
                            label: Text(group),
                            selected: group == selectedGroup,
                            onSelected: (selected) {
                              if (!selected) return;
                              setState(() {
                                selectedGroup = group;
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              Center(
                child: ThemePetalSelector(
                  groups: groups[selectedGroup]!,
                  updateOnHover: true,
                ),
              ),
              if (currentThemeName != null) ...[
                Center(
                  child: Text(currentThemeName),
                ),
                const SizedBox(height: 12.0),
              ],
              CheckboxListTile /*.adaptive*/ (
                title: Text("preferences.theme.themeChangesAppIcon".t(context)),
                value: themeChangesAppIcon,
                onChanged: changeThemeChangesAppIcon,
                secondary: Icon(Symbols.photo_prints_rounded),
                activeColor: context.colorScheme.primary,
              ),
              // CheckboxListTile/*.adaptive*/(
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
              const SizedBox(height: 8.0),
              ...standaloneThemes.entries.map(
                (entry) => RadioListTile /*.adaptive*/ (
                  title: Text(themeNames[entry.value.name] ?? entry.value.name),
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
      trySetAppIcon(newValue
          ? allThemes[LocalPreferences().getCurrentTheme()]?.iconName
          : null);
    } finally {
      appIconBusy = false;
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
        trySetAppIcon(allThemes[name]?.iconName);
      }
    } finally {
      busy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }
}
