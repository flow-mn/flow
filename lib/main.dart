// Flow - A personal finance tracking app
//
// Copyright (C) 2024 Batmend Ganbaatar and authors of Flow

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:io';

import 'package:flow/entity/profile.dart';
import 'package:flow/l10n/flow_localizations.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/prefs.dart';
import 'package:flow/routes.dart';
import 'package:flow/theme/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pie_menu/pie_menu.dart';

const appVersion = "0.1.1+3";

final String namedVersion = appVersion.split("+").first;
final int buildNumber = int.parse(appVersion.split("+").last);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    FlowLocalizations.printMissingKeys();
  }

  /// [ObjectBox] MUST initialize before [LocalPreferences] because prefs
  /// access [ObjectBox] upon initialization.
  await ObjectBox.initialize();
  await LocalPreferences.initialize();

  runApp(const Flow());
}

class Flow extends StatefulWidget {
  const Flow({super.key});

  @override
  State<Flow> createState() => FlowState();

  static FlowState of(BuildContext context) =>
      context.findAncestorStateOfType<FlowState>()!;
}

class FlowState extends State<Flow> {
  Locale _locale = FlowLocalizations.supportedLanguages.first;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get useDarkTheme => (_themeMode == ThemeMode.system
      ? (MediaQuery.platformBrightnessOf(context) == Brightness.dark)
      : (_themeMode == ThemeMode.dark));

  PieTheme get pieTheme {
    return useDarkTheme ? pieThemeDark : pieThemeLight;
  }

  @override
  void initState() {
    super.initState();

    _reloadLocale();
    _reloadTheme();

    LocalPreferences().localeOverride.addListener(_reloadLocale);
    LocalPreferences().themeMode.addListener(_reloadTheme);

    if (ObjectBox().box<Profile>().count(limit: 1) == 0) {
      Profile.createDefaultProfile();
    }
  }

  @override
  void dispose() {
    LocalPreferences().localeOverride.removeListener(_reloadLocale);
    LocalPreferences().themeMode.removeListener(_reloadTheme);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      backgroundColor: lightTheme.colorScheme.background,
      textStyle: lightTheme.textTheme.bodyMedium,
      child: MaterialApp.router(
        onGenerateTitle: (context) => "appName".t(context),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          if (kDebugMode || Platform.isIOS)
            GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          FlowLocalizations.delegate,
        ],
        supportedLocales: FlowLocalizations.supportedLanguages,
        locale: LocalPreferences().localeOverride.value,
        routerConfig: router,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: _themeMode,
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  void _reloadTheme() {
    setState(() {
      _themeMode = LocalPreferences().themeMode.value ?? _themeMode;
    });
  }

  void _reloadLocale() {
    _locale = LocalPreferences().localeOverride.value ?? _locale;
    Moment.setGlobalLocalization(
      MomentLocalizations.byLocale(_locale.code) ?? MomentLocalizations.enUS(),
    );
    Intl.defaultLocale = _locale.code;
    setState(() {});
  }
}
