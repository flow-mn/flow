import "dart:io";

import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/routes/preferences_page.dart";
import "package:flow/services/local_auth.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:material_symbols_icons/symbols.dart";

final Logger _log = Logger("LockApp");

/// This widget expects [LocalAuthService] to be initialized
class LockApp extends StatefulWidget {
  const LockApp({super.key});

  @override
  State<LockApp> createState() => _LockAppState();
}

class _LockAppState extends State<LockApp> {
  @override
  Widget build(BuildContext context) {
    final bool requireLocalAuth = LocalPreferences().requireLocalAuth.get();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SwitchListTile /*.adaptive*/ (
          secondary: const Icon(Symbols.lock_rounded),
          title: Text("preferences.privacy.appLock".t(context)),
          value: requireLocalAuth,
          onChanged: updateRequireLocalAuth,
        ),
        if (Platform.isLinux) ...[
          const SizedBox(height: 8.0),
          Frame(
            child: InfoText(
              child: Text(
                "preferences.privacy.appLock.description#iOS".t(context),
              ),
            ),
          ),
        ],
        if (Platform.isAndroid) ...[
          const SizedBox(height: 8.0),
          Frame(
            child: InfoText(
              child: Text(
                "preferences.privacy.appLock.description#Android".t(context),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void updateRequireLocalAuth(bool? newRequireLocalAuth) async {
    if (newRequireLocalAuth == null) return;

    try {
      final bool auth = await LocalAuthService().authenticate();
      if (!auth) throw "Failed to authenticate, cannot change prefs";
    } catch (e, stackTrace) {
      _log.warning("Failed to update requireLocalAuth", e, stackTrace);
      if (mounted) {
        context.showErrorToast(error: "error.failedLocalAuth".t(context));
      }
      return;
    }

    await LocalPreferences().requireLocalAuth.set(newRequireLocalAuth);

    if (!mounted) return;

    PreferencesPage.of(context).reload();
    setState(() {});
  }
}
