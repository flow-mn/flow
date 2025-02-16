import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/widgets/action_card.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class SetupOnboardingPage extends StatelessWidget {
  const SetupOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("setup.onboarding".t(context))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              ActionCard(
                onTap: () => context.push("/setup/profile"),
                icon: FlowIconData.icon(Symbols.book_4_spark_rounded),
                title: "setup.onboarding.freshStart".t(context),
                subtitle: "setup.onboarding.freshStart.description".t(context),
              ),
              const SizedBox(height: 16.0),
              ActionCard(
                onTap: () => context.push("/import?setupMode=true"),
                icon: FlowIconData.icon(Symbols.restore_page_rounded),
                title: "setup.onboarding.importExisting".t(context),
                subtitle: "setup.onboarding.importExisting.description".t(
                  context,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
