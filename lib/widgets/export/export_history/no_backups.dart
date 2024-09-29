import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class NoBackups extends StatelessWidget {
  const NoBackups({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "sync.export.history.empty".t(context),
              textAlign: TextAlign.center,
              style: context.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8.0),
            FlowIcon(
              FlowIconData.icon(Symbols.history_rounded),
              size: 128.0,
              color: context.colorScheme.primary,
            ),
            const SizedBox(height: 8.0),
            Text(
              "sync.export.history.empty.description".t(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
