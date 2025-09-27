import "dart:io";

import "package:flow/l10n/extensions.dart";
import "package:flow/services/user_preferences.dart";
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

    final String currentTheme = UserPreferencesService().themeName;

    selectedGroup =
        groups.entries
            .firstWhereOrNull(
              (entry) => entry.value.any((group) => group.name == currentTheme),
            )
            ?.key ??
        groups.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    final String currentTheme = UserPreferencesService().themeName;
    final String? currentThemeName = themeNames[currentTheme];

    final bool themeChangesAppIcon =
        UserPreferencesService().themeChangesAppIcon;

    return Scaffold(
      appBar: AppBar(title: Text("preferences.theme.choose".t(context))),
      body: SingleChildScrollView(
        child: SafeArea(
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
                  onChanged: (scheme) =>
                      UserPreferencesService().themeName = scheme.name,
                ),
              ),
              if (currentThemeName != null) ...[
                Center(child: Text(currentThemeName)),
                const SizedBox(height: 12.0),
              ],
              // CheckboxListTile(
              //   title: Text("preferences.theme.enableDynamicTheme".t(context)),
              //   value: enableDynamicTheme,
              //   onChanged: changeEnableDynamicTheme,
              //   secondary: Icon(Symbols.palette),
              //   activeColor: context.colorScheme.primary,
              // ),
              if (Platform.isIOS) ...[
                CheckboxListTile(
                  title: Text(
                    "preferences.theme.themeChangesAppIcon".t(context),
                  ),
                  value: themeChangesAppIcon,
                  onChanged: changeThemeChangesAppIcon,
                  secondary: Icon(Symbols.photo_prints_rounded),
                  activeColor: context.colorScheme.primary,
                ),
                const SizedBox(height: 16.0),
              ],
              ListHeader("preferences.theme.other".t(context)),
              const SizedBox(height: 8.0),
              RadioGroup(
                groupValue: currentTheme,
                onChanged: (value) => handleChange(value),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: standaloneThemes.entries
                      .map(
                        (entry) => RadioListTile(
                          title: Text(
                            themeNames[entry.value.name] ?? entry.value.name,
                          ),
                          value: entry.key,
                          activeColor: context.colorScheme.primary,
                        ),
                      )
                      .toList(),
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
      UserPreferencesService().themeChangesAppIcon = newValue;
      trySetAppIcon(
        newValue
            ? allThemes[UserPreferencesService().themeName]?.iconName
            : null,
      );
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
      UserPreferencesService().themeName = name;
      if (UserPreferencesService().themeChangesAppIcon) {
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
