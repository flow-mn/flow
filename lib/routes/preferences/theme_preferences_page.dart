import "package:flow/l10n/extensions.dart";
import "package:flow/prefs.dart";
import "package:flow/routes/preferences/theme_preferences/theme_entry.dart";
import "package:flow/theme/color_themes/registry.dart";
import "package:flutter/material.dart";

class ThemePreferencesPage extends StatefulWidget {
  const ThemePreferencesPage({super.key});

  @override
  State<ThemePreferencesPage> createState() => _ThemePreferencesPageState();
}

class _ThemePreferencesPageState extends State<ThemePreferencesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  bool busy = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? preferencesTheme = LocalPreferences().themeName.get();
    final String currentTheme = validateThemeName(preferencesTheme)
        ? preferencesTheme!
        : lightThemes.keys.first;

    return Scaffold(
      appBar: AppBar(
        title: Text("preferences.theme.choose".t(context)),
        bottom: TabBar(
          tabs: [
            Tab(
              text: "preferences.theme.light".t(context),
            ),
            Tab(
              text: "preferences.theme.dark".t(context),
            ),
          ],
          controller: _tabController,
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            ListView(
              children: lightThemes.entries
                  .map(
                    (entry) => ThemeEntry(
                      entry: entry,
                      currentTheme: currentTheme,
                      handleChange: handleChange,
                    ),
                  )
                  .toList(),
            ),
            ListView(
              children: darkThemes.entries
                  .map(
                    (entry) => ThemeEntry(
                      entry: entry,
                      currentTheme: currentTheme,
                      handleChange: handleChange,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
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
