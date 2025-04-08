import "dart:io";

import "package:app_settings/app_settings.dart";
import "package:flow/constants.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/routes/preferences/language_selection_sheet.dart";
import "package:flow/routes/preferences/sections/haptics.dart";
import "package:flow/routes/preferences/sections/lock_app.dart";
import "package:flow/routes/preferences/sections/privacy.dart";
import "package:flow/services/local_auth.dart";
import "package:flow/services/notifications.dart";
import "package:flow/theme/color_themes/registry.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/names.dart";
import "package:flow/widgets/general/direction_chevron.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/general/rtl_flipper.dart";
import "package:flow/widgets/select_currency_sheet.dart";
import "package:flutter/material.dart" hide Flow;
import "package:go_router/go_router.dart";
import "package:logging/logging.dart";
import "package:material_symbols_icons/symbols.dart";

final Logger _log = Logger("PreferencesPage");

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => PreferencesPageState();

  static PreferencesPageState of(BuildContext context) {
    return context.findAncestorStateOfType<PreferencesPageState>()!;
  }
}

class PreferencesPageState extends State<PreferencesPage> {
  bool _currencyBusy = false;
  bool _languageBusy = false;

  bool _showLockApp = false;

  @override
  void initState() {
    super.initState();

    LocalAuthService.initialize()
        .then((_) {
          _showLockApp = LocalAuthService.available;

          if (mounted) {
            setState(() {});
          }
        })
        .catchError((_) {
          _log.warning("Failed to initialize local auth service");
        });
  }

  @override
  Widget build(BuildContext context) {
    final FlowColorScheme currentTheme = getTheme(
      LocalPreferences().theme.themeName.get(),
    );

    final bool enableGeo = LocalPreferences().enableGeo.get();
    final bool autoAttachTransactionGeo =
        LocalPreferences().autoAttachTransactionGeo.get();
    final bool pendingTransactionsRequireConfrimation =
        LocalPreferences().pendingTransactions.requireConfrimation.get();

    return Scaffold(
      appBar: AppBar(title: Text("preferences".t(context))),
      body: SafeArea(
        child: ListView(
          children: [
            ListTile(
              title: Text("preferences.sync".t(context)),
              leading: const Icon(Symbols.sync_rounded),
              onTap: () => _pushAndRefreshAfter("/preferences/sync"),
              trailing: DirectionChevron(),
            ),
            if (flowDebugMode || NotificationsService.schedulingSupported)
              ListTile(
                title: Text("preferences.reminders".t(context)),
                leading: const Icon(Symbols.notifications_rounded),
                onTap: () => _pushAndRefreshAfter("/preferences/reminders"),
                trailing: RTLFlipper(
                  child: const Icon(Symbols.chevron_right_rounded),
                ),
              ),
            ListTile(
              title: Text("preferences.language".t(context)),
              leading: const Icon(Symbols.language_rounded),
              onTap: () => _updateLanguage(),
              subtitle: Text(FlowLocalizations.of(context).locale.endonym),
              trailing: DirectionChevron(),
            ),
            ListTile(
              title: Text("preferences.primaryCurrency".t(context)),

              leading: const Icon(Symbols.universal_currency_alt_rounded),
              onTap: () => _updatePrimaryCurrency(),
              subtitle: Text(LocalPreferences().getPrimaryCurrency()),
              trailing: DirectionChevron(),
            ),
            ListTile(
              title: Text("preferences.transfer".t(context)),
              leading: const Icon(Symbols.sync_alt_rounded),
              onTap: () => _pushAndRefreshAfter("/preferences/transfer"),
              subtitle: Text(
                "preferences.transfer.description".t(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: DirectionChevron(),
            ),
            ListTile(
              title: Text("preferences.trashBin".t(context)),
              leading: const Icon(Symbols.delete_rounded),
              onTap: () => _pushAndRefreshAfter("/preferences/trashBin"),
              trailing: DirectionChevron(),
            ),
            ListTile(
              title: Text("preferences.moneyFormatting".t(context)),
              leading: const Icon(Symbols.numbers_rounded),
              onTap: () => _pushAndRefreshAfter("/preferences/moneyFormatting"),
              trailing: DirectionChevron(),
            ),
            const SizedBox(height: 24.0),
            ListHeader("preferences.transactions".t(context)),
            const SizedBox(height: 8.0),
            ListTile(
              title: Text("preferences.transactions.pending".t(context)),
              subtitle: Text(
                pendingTransactionsRequireConfrimation
                    ? "general.enabled".t(context)
                    : "general.disabled".t(context),
              ),
              leading: const Icon(Symbols.schedule_rounded),
              onTap:
                  () =>
                      _pushAndRefreshAfter("/preferences/pendingTransactions"),
              trailing: DirectionChevron(),
            ),
            ListTile(
              title: Text("preferences.transactions.geo".t(context)),
              leading: const Icon(Symbols.location_pin_rounded),
              onTap: () => _pushAndRefreshAfter("/preferences/transactionGeo"),
              subtitle: Text(
                enableGeo
                    ? (autoAttachTransactionGeo
                        ? "preferences.transactions.geo.auto.enabled".t(context)
                        : "general.enabled".t(context))
                    : "general.disabled".t(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: DirectionChevron(),
            ),
            ListTile(
              leading: const Icon(Symbols.list_rounded),
              title: Text("preferences.transactions.listTile".t(context)),
              onTap:
                  () => _pushAndRefreshAfter(
                    "/preferences/transactionListItemAppearance",
                  ),
              trailing: DirectionChevron(),
            ),
            const SizedBox(height: 24.0),
            ListHeader("preferences.appearance".t(context)),
            const SizedBox(height: 8.0),
            ListTile(
              title: Text("preferences.theme".t(context)),
              leading:
                  currentTheme.isDark
                      ? const Icon(Symbols.dark_mode_rounded)
                      : const Icon(Symbols.light_mode_rounded),
              subtitle: Text(
                themeNames[currentTheme.name] ?? currentTheme.name,
              ),
              onTap: _openTheme,
              trailing: DirectionChevron(),
            ),
            ListTile(
              title: Text("preferences.numpad".t(context)),
              leading: const Icon(Symbols.dialpad_rounded),
              onTap: () => _pushAndRefreshAfter("/preferences/numpad"),
              subtitle: Text(
                LocalPreferences().usePhoneNumpadLayout.get()
                    ? "preferences.numpad.layout.modern".t(context)
                    : "preferences.numpad.layout.classic".t(context),
              ),
              trailing: DirectionChevron(),
            ),
            ListTile(
              title: Text("preferences.transactionButtonOrder".t(context)),
              leading: const Icon(Symbols.action_key_rounded),
              onTap:
                  () => _pushAndRefreshAfter(
                    "/preferences/transactionButtonOrder",
                  ),
              subtitle: Text(
                "preferences.transactionButtonOrder.description".t(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: DirectionChevron(),
            ),
            const SizedBox(height: 24.0),
            ListHeader("preferences.privacy".t(context)),
            const SizedBox(height: 8.0),
            const Privacy(),
            if (_showLockApp) ...[const SizedBox(height: 8.0), const LockApp()],
            const SizedBox(height: 24.0),
            ListHeader("preferences.hapticFeedback".t(context)),
            const SizedBox(height: 8.0),
            const Haptics(),
            const SizedBox(height: 16.0),
            Frame(
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => context.push("/_debug/logs"),
                  child: Text("View debug logs"),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  void _updateLanguage() async {
    if (Platform.isIOS) {
      await LocalPreferences().localeOverride.remove().catchError((
        e,
        stackTrace,
      ) {
        _log.warning("Failed to remove locale override", e, stackTrace);
      });
      try {
        await AppSettings.openAppSettings(type: AppSettingsType.appLocale);
        return;
      } catch (e, stackTrace) {
        _log.warning(
          "Failed to open system app settings on iOS",
          e,
          stackTrace,
        );
      }
    }

    if (_languageBusy || !mounted) return;

    setState(() {
      _languageBusy = true;
    });

    try {
      Locale current =
          LocalPreferences().localeOverride.get() ??
          FlowLocalizations.supportedLanguages.first;

      final selected = await showModalBottomSheet<Locale>(
        context: context,
        builder: (context) => LanguageSelectionSheet(currentLocale: current),
        isScrollControlled: true,
      );

      if (selected != null) {
        await LocalPreferences().localeOverride.set(selected);
      }
    } finally {
      _languageBusy = false;
    }
  }

  void _updatePrimaryCurrency() async {
    if (_currencyBusy) return;

    setState(() {
      _currencyBusy = true;
    });

    try {
      String current = LocalPreferences().getPrimaryCurrency();

      final selected = await showModalBottomSheet<String>(
        context: context,
        builder: (context) => SelectCurrencySheet(currentlySelected: current),
      );

      if (selected != null) {
        await LocalPreferences().primaryCurrency.set(selected);
      }
    } finally {
      _currencyBusy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  void _pushAndRefreshAfter(String path) async {
    await context.push(path);

    // Rebuild to update description text
    if (mounted) setState(() {});
  }

  void _openTheme() async {
    await context.push("/preferences/theme");

    final bool themeChangesAppIcon =
        LocalPreferences().theme.themeChangesAppIcon.get();

    trySetAppIcon(
      themeChangesAppIcon
          ? allThemes[LocalPreferences().theme.themeName.get()]?.iconName
          : null,
    );

    // Rebuild to update description text
    if (mounted) setState(() {});
  }

  void reload() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }
}
