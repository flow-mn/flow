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

import "dart:async";
import "dart:developer";
import "dart:io";

import "package:flow/constants.dart";
import "package:flow/entity/profile.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs.dart";
import "package:flow/routes.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:intl/intl.dart";
import "package:moment_dart/moment_dart.dart";
import "package:package_info_plus/package_info_plus.dart";
import "package:pie_menu/pie_menu.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const String debugBuildSuffix = debugBuild ? " (dev)" : "";

  unawaited(PackageInfo.fromPlatform()
      .then((value) =>
          appVersion = "${value.version}+${value.buildNumber}$debugBuildSuffix")
      .catchError((e) {
    log("An error was occured while fetching app version: $e");
    return appVersion = "<unknown>+<0>$debugBuildSuffix";
  }));

  if (flowDebugMode) {
    FlowLocalizations.printMissingKeys();
  }

  /// [ObjectBox] MUST initialize before [LocalPreferences] because prefs
  /// access [ObjectBox] upon initialization.
  await ObjectBox.initialize();
  await LocalPreferences.initialize();

  /// Set `sortOrder` values if there are any unset (-1) values
  await ObjectBox().updateAccountOrderList(ignoreIfNoUnsetValue: true);

  ExchangeRatesService().init();

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
      supportedLocales: FlowLocalizations.supportedLanguages,
      locale: _locale,
      routerConfig: router,
      theme: lightTheme,
      darkTheme: darkTheme,
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
    final List<Locale> systemLocales =
        WidgetsBinding.instance.platformDispatcher.locales;

    final String? country = systemLocales
        .where(
          (element) => element.countryCode != null,
        )
        .firstOrNull
        ?.countryCode;

    final Locale overriddenLocale =
        LocalPreferences().localeOverride.value ?? _locale;

    _locale = Locale(
        overriddenLocale.languageCode, overriddenLocale.countryCode ?? country);
    Moment.setGlobalLocalization(
      MomentLocalizations.byLocale(overriddenLocale.code) ??
          MomentLocalizations.enUS(),
    );
    Intl.defaultLocale = overriddenLocale.code;
    setState(() {});
  }
}
