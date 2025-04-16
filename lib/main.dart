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
import "dart:io";
import "dart:ui";

import "package:flow/constants.dart";
import "package:flow/data/flow_icon.dart";
import "package:flow/entity/profile.dart";
import "package:flow/graceful_migrations.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/logging.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/providers/accounts_provider.dart";
import "package:flow/providers/categories.dart";
import "package:flow/routes.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/local_auth.dart";
import "package:flow/services/notifications.dart";
import "package:flow/services/sync.dart";
import "package:flow/services/transactions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/color_themes/registry.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:intl/intl.dart";
import "package:logging/logging.dart";
import "package:logging_appenders/logging_appenders.dart";
import "package:material_symbols_icons/material_symbols_icons.dart";
import "package:moment_dart/moment_dart.dart";
import "package:package_info_plus/package_info_plus.dart";
import "package:path/path.dart" as path;
import "package:path_provider/path_provider.dart"
    show getApplicationSupportDirectory;
import "package:window_manager/window_manager.dart";

RotatingFileAppender? mainLogAppender;

void main() async {
  Logger.root.level = Level.ALL;

  WidgetsFlutterBinding.ensureInitialized();

  PrintAppender(formatter: ColorFormatter()).attachToLogger(Logger.root);

  initializeFileLogger();

  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    startupLog.fine("Initializing window manager");
    await windowManager.ensureInitialized().catchError((error) {
      startupLog.severe("Failed to initialize window manager", error);
    });
  }

  initializePackageVersion();

  if (flowDebugMode) {
    FlowLocalizations.printMissingKeys();
  }

  startupLog.fine("Initializing ObjectBox database");

  /// [ObjectBox] MUST initialize before [LocalPreferences] because prefs
  /// access [ObjectBox] upon initialization.
  await ObjectBox.initialize();
  startupLog.fine("Initializing local preferences (shared prefs)");
  await LocalPreferences.initialize();

  /// Set `sortOrder` values if there are any unset (-1) values
  await ObjectBox().updateAccountOrderList(ignoreIfNoUnsetValue: true);
  startupLog.fine("Updating account order list");

  initializeNotifications();

  startupLog.fine("Clearing stale transactions from trash bin");
  unawaited(
    TransactionsService().clearStaleTrashBinEntries().catchError((error) {
      startupLog.severe("Failed to clear stale trash bin entries", error);
    }),
  );

  startupLog.fine("Initializing exchange rates service");
  ExchangeRatesService().init();

  try {
    startupLog.fine("Initializing user preferences service");
    UserPreferencesService().initialize();
  } catch (e) {
    startupLog.severe("Failed to initialize UserPreferencesService", e);
  }

  try {
    startupLog.fine("Initializing SyncService");
    SyncService();
  } catch (e, stackTrace) {
    startupLog.severe("Failed to initialize SyncService", e, stackTrace);
  }

  startupLog.fine("Finally telling Flutter to run the app widget");
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

  late bool _tempLock;

  bool get useDarkTheme =>
      (_themeMode == ThemeMode.system
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

    _tempLock = LocalPreferences().requireLocalAuth.get();

    TransactionsService().addListener(_synchronizePlannedNotifications);

    if (ObjectBox().box<Profile>().count(limit: 1) == 0) {
      Profile.createDefaultProfile();
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      migrateRemoveTitleFromUntitledTransactions();
    });

    _tryUnlockTempLock();
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
      builder: (context, child) {
        return AccountsProviderScope(
          child: CategoriesProviderScope(
            child: GestureDetector(
              behavior:
                  _tempLock
                      ? HitTestBehavior.opaque
                      : HitTestBehavior.deferToChild,
              onTap: _tryUnlockTempLock,
              child: IgnorePointer(
                ignoring: _tempLock,
                child: Stack(
                  children: [
                    child ?? Container(),
                    if (_tempLock)
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                          child: SizedBox.expand(
                            child: Center(
                              child: FlowIcon(
                                FlowIconData.icon(Symbols.lock_rounded),
                                size: 80.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _reloadTheme() {
    final String? themeName = LocalPreferences().theme.themeName.value;

    themeLogger.info("Reloading $themeName");

    FlowColorScheme theme = getTheme(themeName, preferDark: useDarkTheme);

    setState(() {
      _themeMode = theme.mode;
      _themeFactory = ThemeFactory(theme);
    });
  }

  void _reloadLocale() {
    final List<Locale> systemLocales =
        WidgetsBinding.instance.platformDispatcher.locales;

    final List<Locale> favorableLocales =
        systemLocales
            .where(
              (locale) => FlowLocalizations.supportedLanguages.any(
                (flowSupportedLocalization) =>
                    flowSupportedLocalization.languageCode ==
                    locale.languageCode,
              ),
            )
            .toList();

    final Locale overriddenLocale =
        LocalPreferences().localeOverride.value ??
        favorableLocales.firstOrNull ??
        _locale;

    _locale = Locale(
      overriddenLocale.languageCode,
      overriddenLocale.countryCode,
    );

    mainLogger.fine("Setting locale to ${_locale.code}");

    final MomentLocalization newMomentLocalization =
        MomentLocalizations.byLocale(overriddenLocale.code) ??
        MomentLocalizations.byLanguage(
          overriddenLocale.languageCode.toLowerCase(),
        ) ??
        MomentLocalizations.enUS();

    mainLogger.fine(
      "Setting moment_dart localization to ${newMomentLocalization.locale}",
    );

    Moment.setGlobalLocalization(newMomentLocalization);

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
      startupLog.severe("Failed to synchronize notifications", error);
    });
  }

  void _tryUnlockTempLock() async {
    try {
      await LocalAuthService.initialize();
      if (!LocalAuthService.available || !LocalAuthService.platformSupported) {
        _tempLock = false;
      }
      if (!_tempLock) {
        mainLogger.fine("Ignoring local auth initialization");
        return;
      }
      final authenticated = await LocalAuthService().authenticate();
      _tempLock = !authenticated;

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      mainLogger.severe("Failed to initialize LocalAuthService", e);
    }
  }
}

void initializeFileLogger() async {
  try {
    final Directory supportDirectory = await getApplicationSupportDirectory();

    try {
      final String logsDir = path.join(supportDirectory.path, "logs");
      Directory(logsDir).createSync(recursive: true);
      mainLogAppender = RotatingFileAppender(
        baseFilePath: path.join(
          logsDir,
          flowDebugMode ? "flow_debug.log" : "flow.log",
        ),
        keepRotateCount: 5,
      )..attachToLogger(Logger.root);
    } catch (e) {
      startupLog.severe("Failed to initialize log file appender", e);
    }
  } catch (e) {
    startupLog.severe("Failed to get application support directory", e);
  }
}

void initializePackageVersion() async {
  try {
    const String debugBuildSuffix = debugBuild ? " (dev)" : "";

    final value = await PackageInfo.fromPlatform();
    appVersion = "${value.version}+${value.buildNumber}$debugBuildSuffix";
    downloadedFrom = value.installerStore;

    startupLog.fine("Loaded package info");
    startupLog.fine("App version: $appVersion");
    startupLog.fine("Store: ${value.installerStore}");
  } catch (e) {
    startupLog.warning("An error was occured while fetching app version", e);
  }
}

void initializeNotifications() async {
  assert(LocalPreferences().runtimeType == LocalPreferences);

  await NotificationsService().initialize();

  unawaited(
    TransactionsService().synchronizeNotifications().catchError((error) {
      startupLog.severe("Failed to synchronize notifications", error);
    }),
  );

  if (UserPreferencesService().remindDailyAt case Duration requireRemindAt) {
    startupLog.info(
      "Scheduling daily reminder notifications at ${requireRemindAt.inMinutes} minutes past midnight",
    );
    unawaited(
      NotificationsService().scheduleDailyReminders(requireRemindAt).catchError(
        (error) {
          startupLog.severe(
            "Failed to schedule daily reminder notifications",
            error,
          );
        },
      ),
    );
  } else {
    startupLog.fine("No daily reminder set, skipping scheduling");
  }
}
