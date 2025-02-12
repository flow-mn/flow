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
import "dart:ui";

import "package:dynamic_color/dynamic_color.dart";
import "package:flow/constants.dart";
import "package:flow/entity/profile.dart";
import "package:flow/graceful_migrations.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/routes.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/notifications.dart";
import "package:flow/services/transactions.dart";
import "package:flow/theme/color_themes/registry.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:intl/intl.dart";
import "package:moment_dart/moment_dart.dart";
import "package:package_info_plus/package_info_plus.dart";
import "package:window_manager/window_manager.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await windowManager.ensureInitialized();
  }

  const String debugBuildSuffix = debugBuild ? " (dev)" : "";

  unawaited(PackageInfo.fromPlatform()
      .then((value) =>
          appVersion = "${value.version}+${value.buildNumber}$debugBuildSuffix")
      .catchError((e) {
    log("[Flow Startup] An error was occured while fetching app version: $e");
    return appVersion = "<unknown>+<0>$debugBuildSuffix";
  }));

  if (flowDebugMode) {
    FlowLocalizations.printMissingKeys();
  }

  /// [ObjectBox] MUST initialize before [LocalPreferences] because prefs
  /// access [ObjectBox] upon initialization.
  await ObjectBox.initialize();
  await LocalPreferences.initialize();
  unawaited(NotificationsService().initialize());

  /// Set `sortOrder` values if there are any unset (-1) values
  await ObjectBox().updateAccountOrderList(ignoreIfNoUnsetValue: true);

  unawaited(
      TransactionsService().synchronizeNotifications().catchError((error) {
    log("[Flow Startup] Failed to synchronize notifications", error: error);
  }));
  ExchangeRatesService().init();

  try {
    LocalPreferences().privacyMode.addListener(
          () => TransitiveLocalPreferences().sessionPrivacyMode.set(
                LocalPreferences().privacyMode.get(),
              ),
        );
  } catch (e) {
    log("[Flow Startup] Failed to add listener updates prefs.sessionPrivacyMode");
  }

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

  ThemeFactory _themeFactory = ThemeFactory.fromThemeName(null);

  ThemeMode get themeMode => _themeMode;

  bool get useDarkTheme => (_themeMode == ThemeMode.system
      ? (PlatformDispatcher.instance.platformBrightness == Brightness.dark)
      : (_themeMode == ThemeMode.dark));

  @override
  void initState() {
    super.initState();

    _reloadLocale();
    _reloadTheme();

    LocalPreferences().localeOverride.addListener(_reloadLocale);
    LocalPreferences().theme.themeName.addListener(_reloadTheme);
    LocalPreferences().primaryCurrency.addListener(_refreshExchangeRates);

    TransactionsService().addListener(_synchronizePlannedNotifications);

    if (ObjectBox().box<Profile>().count(limit: 1) == 0) {
      Profile.createDefaultProfile();
    } else {
      // To migrate profile image path from old to new (since 0.10.0)
      nonImportantMigrateProfileImagePath();
    }

    migrateLocalPrefsRequirePendingTransactionConfrimation();
  }

  @override
  void dispose() {
    LocalPreferences().localeOverride.removeListener(_reloadLocale);
    LocalPreferences().theme.themeName.removeListener(_reloadTheme);
    LocalPreferences().primaryCurrency.removeListener(_refreshExchangeRates);

    TransactionsService().removeListener(_synchronizePlannedNotifications);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (dynamicLight, dynamicDark) {
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
          theme: _themeFactory.materialTheme,
          themeMode: _themeMode,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }

  void _reloadTheme() {
    final String? themeName = LocalPreferences().theme.themeName.value;

    log("[Theme] Reloading theme $themeName");

    FlowColorScheme theme = getTheme(
      themeName,
      preferDark: useDarkTheme,
    );

    setState(() {
      _themeMode = theme.mode;
      _themeFactory = ThemeFactory(theme);
    });
  }

  void _reloadLocale() {
    final List<Locale> systemLocales =
        WidgetsBinding.instance.platformDispatcher.locales;

    final List<Locale> favorableLocales = systemLocales
        .where(
          (locale) => FlowLocalizations.supportedLanguages.any(
              (flowSupportedLocalization) =>
                  flowSupportedLocalization.languageCode ==
                  locale.languageCode),
        )
        .toList();

    final Locale overriddenLocale = LocalPreferences().localeOverride.value ??
        favorableLocales.firstOrNull ??
        _locale;

    _locale =
        Locale(overriddenLocale.languageCode, overriddenLocale.countryCode);
    Moment.setGlobalLocalization(
      MomentLocalizations.byLocale(overriddenLocale.code) ??
          MomentLocalizations.enUS(),
    );

    Intl.defaultLocale = overriddenLocale.code;
    setState(() {});
  }

  void _refreshExchangeRates() {
    ExchangeRatesService().tryFetchRates(
      LocalPreferences().getPrimaryCurrency(),
    );
  }

  void _synchronizePlannedNotifications() {
    TransactionsService().synchronizeNotifications().catchError((error) {
      log("[Flow Startup] Failed to synchronize notifications", error: error);
    });
  }
}
