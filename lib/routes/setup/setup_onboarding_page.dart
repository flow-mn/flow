import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/action_card.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class SetupOnboardingPage extends StatelessWidget {
  const SetupOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("setup.onboarding".t(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              ActionCard(
                onTap: () => context.push("/setup/profile"),
                builder: (context) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FlowIcon(
                        FlowIconData.icon(Symbols.book_4_spark_rounded),
                        size: 80.0,
                        plated: true,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        "setup.onboarding.freshStart".t(context),
                        style: context.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        "setup.onboarding.freshStart.description".t(context),
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              ActionCard(
                onTap: () => context.push("/import"),
                builder: (context) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FlowIcon(
                        FlowIconData.icon(Symbols.restore_page_rounded),
                        size: 80.0,
                        plated: true,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        "setup.onboarding.importExisting".t(context),
                        style: context.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        "setup.onboarding.importExisting.description"
                            .t(context),
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
