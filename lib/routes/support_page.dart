import "dart:io";

import "package:flow/constants.dart";
import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class SupportPage extends StatelessWidget {
  static const EdgeInsets cardPadding = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 24.0,
  );

  static const ShapeBorder cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16.0)));

  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
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
              Card(
                shape: cardShape,
                child: Padding(
                  padding: cardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FlowIcon(
                        FlowIconData.icon(Symbols.rate_review_rounded),
                        size: 80.0,
                        plated: true,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        "support.requestFeatures".t(context),
                        style: context.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        "support.requestFeatures.description".t(context),
                        style: context.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8.0),
                      Button(
                        trailing: const Icon(Symbols.chevron_right_rounded),
                        child: Expanded(
                          child: Text(
                            "support.requestFeatures.action".t(context),
                          ),
                        ),
                        onTap: () => openUrl(flowGitHubIssuesLink),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Card(
                shape: cardShape,
                child: Padding(
                  padding: cardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FlowIcon(
                        FlowIconData.icon(Symbols.code_rounded),
                        size: 80.0,
                        plated: true,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        "support.contribute".t(context),
                        style: context.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        "support.contribute.description".t(context),
                        style: context.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8.0),
                      Button(
                        trailing: const Icon(Symbols.chevron_right_rounded),
                        child: Expanded(
                          child: Text(
                            "visitGitHubRepo".t(context),
                          ),
                        ),
                        onTap: () => openUrl(flowGitHubRepoLink),
                      )
                    ],
                  ),
                ),
              ),
              if (!(Platform.isIOS || Platform.isMacOS)) ...[
                const SizedBox(height: 16.0),
                Card(
                  shape: cardShape,
                  child: Padding(
                    padding: cardPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FlowIcon(
                          FlowIconData.icon(Symbols.favorite_rounded),
                          size: 80.0,
                          plated: true,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          "support.donateDeveloper".t(context),
                          style: context.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          "support.donateDeveloper.description".t(context),
                          style: context.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8.0),
                        Button(
                          trailing: const Icon(Symbols.chevron_right_rounded),
                          child: Expanded(
                            child: Text(
                              "support.donateDeveloper.action".t(context),
                            ),
                          ),
                          onTap: () => openUrl(maintainerKoFiLink),
                        )
                      ],
                    ),
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
}
