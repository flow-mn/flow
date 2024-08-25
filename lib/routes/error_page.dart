import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class ErrorPage extends StatelessWidget {
  final String? error;

  const ErrorPage({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FlowIcon(
                  FlowIconData.emoji("😪"),
                  size: 80.0,
                  plated: true,
                ),
                const SizedBox(height: 12.0),
                Text(
                  error ?? "error.route.404".t(context),
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.flowColors.expense,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                if (context.canPop()) ...[
                  const SizedBox(height: 16.0),
                  Button(
                    onTap: () => context.pop(),
                    leading: const Icon(Symbols.chevron_left_rounded),
                    child: Text("general.back".t(context)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
