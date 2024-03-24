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

import 'package:flow/constants.dart';
import 'package:flow/entity/profile.dart';
import 'package:flow/entity/transaction.dart';
import 'package:flow/l10n/flow_localizations.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/actions.dart';
import 'package:flow/prefs.dart';
import 'package:flow/routes.dart';
import 'package:flow/theme/navbar_theme.dart';
import 'package:flow/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:pie_menu/pie_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (flowDebugMode) {
    FlowLocalizations.printMissingKeys();
  }

  /// [ObjectBox] MUST initialize before [LocalPreferences] because prefs
  /// access [ObjectBox] upon initialization.
  await ObjectBox.initialize();
  await LocalPreferences.initialize();

  /// Set `sortOrder` values if there are any unset (-1) values
  await ObjectBox().updateAccountOrderList(ignoreIfNoUnsetValue: true);

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

  Color? primaryColorFromPrefs = Colors.white;

  @override
  void initState() {
    super.initState();

    _reloadLocale();
    _reloadTheme();

    _checkPrefsForPrimaryColor().then((color) {
      setState(() {
        if (color != null) {
          primaryColorFromPrefs = color;
        } else {
          primaryColorFromPrefs = context.colorScheme.primary;
        }
      });
    });

    LocalPreferences().localeOverride.addListener(_reloadLocale);
    LocalPreferences().themeMode.addListener(_reloadTheme);

    ObjectBox().box<Transaction>().query().watch().listen((event) {
      ObjectBox().invalidateAccountsTab();
    });

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
    return MaterialApp.router(
      onGenerateTitle: (context) => "appName".t(context),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        if (flowDebugMode || Platform.isIOS)
          GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlowLocalizations.delegate,
      ],
      locale: LocalPreferences().localeOverride.value,
      routerConfig: router,
      theme: _overrideThemeWithPrimaryColor(lightTheme, primaryColorFromPrefs,
          isLightMode: true),
      darkTheme:
          _overrideThemeWithPrimaryColor(darkTheme, primaryColorFromPrefs),
      // theme: lightTheme,
      // darkTheme: darkTheme,
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
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

ThemeData _overrideThemeWithPrimaryColor(ThemeData theme, Color? primaryColor,
    {bool isLightMode = false}) {
  return theme.copyWith(
    colorScheme: theme.colorScheme.copyWith(primary: primaryColor),
    listTileTheme: theme.listTileTheme.copyWith(iconColor: primaryColor),
    extensions: _mapExtensions(theme, primaryColor),
    textSelectionTheme: theme.textSelectionTheme.copyWith(
      cursorColor: primaryColor,
      selectionColor: primaryColor,
      selectionHandleColor: primaryColor,
    ),
  );
}

Iterable<ThemeExtension<dynamic>> _mapExtensions(
    ThemeData theme, Color? primaryColor) {
  return theme.extensions.entries.map((entry) {
    if (entry.value is NavbarTheme) {
      var navbarTheme = entry.value as NavbarTheme;
      return NavbarTheme(
        backgroundColor: theme.colorScheme.onSurface,
        activeIconColor: primaryColor ?? navbarTheme.activeIconColor,
        inactiveIconOpacity: 0.5,
        transactionButtonBackgroundColor:
            primaryColor ?? navbarTheme.transactionButtonBackgroundColor,
        transactionButtonForegroundColor:
            navbarTheme.transactionButtonForegroundColor,
      );
    } else {
      return entry.value;
    }
  });
}

Future<Color?> _checkPrefsForPrimaryColor() async {
  final prefs = LocalPreferences();
  return await prefs.getPrimaryColor();
}
