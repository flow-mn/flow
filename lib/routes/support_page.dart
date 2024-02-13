import 'package:flow/data/flow_icon.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/utils/utils.dart';
import 'package:flow/widgets/action_card.dart';
import 'package:flow/widgets/general/flow_icon.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class SupportPage extends StatelessWidget {
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
              ActionCard(
                onTap: () => openUrl(
                    Uri.parse("https://github.com/flow-mn/flow/issues")),
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
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              ActionCard(
                onTap: () =>
                    openUrl(Uri.parse("https://github.com/flow-mn/flow")),
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
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              ActionCard(
                onTap: () =>
                    openUrl(Uri.parse("https://ko-fi.com/sadespresso")),
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
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
