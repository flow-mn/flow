import "dart:async";
import "dart:io";

import "package:flow/constants.dart";
import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/prefs.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/action_card.dart";
import "package:flow/widgets/general/button.dart";
import "package:flutter/material.dart";
import "package:in_app_review/in_app_review.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class SupportPage extends StatelessWidget {
  static const EdgeInsets cardPadding = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 24.0,
  );

  static const ShapeBorder cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(16.0),
    ),
  );

  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool supportsReview =
        Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

    return Scaffold(
      appBar: AppBar(
        title: Text("support".t(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text("support.description".t(context)),
              const SizedBox(height: 16.0),
              if (supportsReview)
                ActionCard(
                  title: "support.leaveAReview".t(context),
                  subtitle: "support.leaveAReview.description".t(
                    context,
                    Platform.isAndroid ? "Google Play" : "App Store",
                  ),
                  icon: FlowIconData.icon(Symbols.rate_review_rounded),
                  trailing: Button(
                    backgroundColor: context.colorScheme.surface,
                    trailing: const Icon(Symbols.chevron_right_rounded),
                    child: Expanded(
                      child: Text(
                        "support.leaveAReview.action".t(context),
                      ),
                    ),
                    onTap: () => requestReview(),
                  ),
                ),
              const SizedBox(height: 16.0),
              ActionCard(
                title: "support.starOnGitHub".t(context),
                subtitle: "support.starOnGitHub.description".t(context),
                icon: FlowIconData.icon(Symbols.star_rounded),
                trailing: Button(
                  backgroundColor: context.colorScheme.surface,
                  trailing: const Icon(Symbols.chevron_right_rounded),
                  child: Expanded(
                    child: Text(
                      "visitGitHubRepo".t(context),
                    ),
                  ),
                  onTap: () => openUrl(flowGitHubRepoLink),
                ),
              ),
              const SizedBox(height: 16.0),
              ActionCard(
                title: "support.requestFeatures".t(context),
                subtitle: "support.requestFeatures.description".t(context),
                icon: FlowIconData.icon(Symbols.emoji_objects_rounded),
                trailing: Button(
                  backgroundColor: context.colorScheme.surface,
                  trailing: const Icon(Symbols.chevron_right_rounded),
                  child: Expanded(
                    child: Text(
                      "support.requestFeatures.action".t(context),
                    ),
                  ),
                  onTap: () => openUrl(flowGitHubIssuesLink),
                ),
              ),
              const SizedBox(height: 16.0),
              ActionCard(
                title: "support.contribute".t(context),
                subtitle: "support.contribute.description".t(context),
                icon: FlowIconData.icon(Symbols.code_rounded),
                trailing: Button(
                  backgroundColor: context.colorScheme.surface,
                  trailing: const Icon(Symbols.chevron_right_rounded),
                  child: Expanded(
                    child: Text(
                      "visitGitHubRepo".t(context),
                    ),
                  ),
                  onTap: () => openUrl(flowGitHubRepoLink),
                ),
              ),
              if (!(Platform.isIOS || Platform.isMacOS)) ...[
                const SizedBox(height: 16.0),
                ActionCard(
                  title: "support.donateDeveloper".t(context),
                  subtitle: "support.donateDeveloper.description".t(context),
                  icon: FlowIconData.icon(Symbols.favorite_rounded),
                  trailing: Button(
                    backgroundColor: context.colorScheme.surface,
                    trailing: const Icon(Symbols.chevron_right_rounded),
                    child: Expanded(
                      child: Text(
                        "support.donateDeveloper.action".t(context),
                      ),
                    ),
                    onTap: () => openUrl(maintainerKoFiLink),
                  ),
                ),
              ],
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  void requestReview() async {
    final bool platformSupported =
        Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

    if (!platformSupported) return;

    final InAppReview inAppReview = InAppReview.instance;

    try {
      final DateTime? lastRequested =
          LocalPreferences().lastRequestedAppStoreReview.get();
      final DateTime now = DateTime.now();

      if (lastRequested != null &&
          lastRequested <= now &&
          now.differenceInDays(lastRequested) < 30) {
        throw Exception(
          "App store review already requested in the last 30 days",
        );
      }

      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
        unawaited(
          LocalPreferences().lastRequestedAppStoreReview.set(DateTime.now()),
        );
      } else {
        throw Exception("In-app review is not available");
      }
    } catch (e) {
      await inAppReview.openStoreListing(appStoreId: "6477741670");
    }
  }
}
