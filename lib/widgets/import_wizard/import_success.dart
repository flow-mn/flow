import "dart:async";

import "package:flow/data/flow_icon.dart";
import "package:flow/entity/profile.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/logging.dart";
import "package:flow/objectbox.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:objectbox/objectbox.dart";

class ImportSuccess extends StatelessWidget {
  final bool setupMode;

  /// Defaults to `context.pop()`
  final void Function(BuildContext context)? onDoneOverride;

  const ImportSuccess({
    super.key,
    this.onDoneOverride,
    required this.setupMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Spacer(),
          FlowIcon(
            FlowIconData.icon(Symbols.check_circle_outline_rounded),
            size: 80.0,
            color: context.flowColors.income,
          ),
          const SizedBox(height: 16.0),
          Text(
            "sync.import.success".t(context),
            style: context.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          if (!setupMode) ...[
            const SizedBox(height: 16.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Symbols.info_rounded,
                  fill: 0,
                  color: context.flowColors.semi,
                  size: 16.0,
                ),
                const SizedBox(width: 8.0),
                Flexible(
                  child: Text(
                    "sync.import.emergencyBackup.successful".t(context),
                    style: context.textTheme.bodySmall?.semi(context),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24.0),
          Align(
            alignment: setupMode ? Alignment.topRight : Alignment.center,
            child: Button(
              onTap: () => onDone(context),
              leading: setupMode ? null : const Icon(Symbols.check_rounded),
              trailing:
                  setupMode ? const Icon(Symbols.chevron_right_rounded) : null,
              child: Text(
                setupMode ? "setup.next".t(context) : "general.done".t(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onDone(BuildContext context) {
    if (onDoneOverride != null) {
      return onDoneOverride!(context);
    }

    if (setupMode) {
      unawaited(
        LocalPreferences().completedInitialSetup
            .set(true)
            .then((_) {
              mainLogger.fine("Setup completed");
            })
            .catchError((_) {
              mainLogger.fine("Failed to set setup completion flag");
            }),
      );

      final Query<Profile> query = ObjectBox().box<Profile>().query().build();

      final bool exists = query.findFirst() != null;

      query.close();

      if (!context.mounted) return;

      if (exists) {
        GoRouter.of(context).popUntil((route) => route.path == "/setup");

        context.pushReplacement("/");
      } else {
        context.push("/setup/profile");
      }
    } else {
      Navigator.of(context).pop();
    }
  }
}
