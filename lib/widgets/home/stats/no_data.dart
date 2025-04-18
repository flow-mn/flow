import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class NoData extends StatelessWidget {
  final VoidCallback? selectTimeRange;

  const NoData({super.key, this.selectTimeRange});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "tabs.stats.chart.noData".t(context),
              textAlign: TextAlign.center,
              style: context.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8.0),
            FlowIcon(
              FlowIconData.icon(Symbols.query_stats_rounded),
              size: 128.0,
              color: context.colorScheme.primary,
            ),
            const SizedBox(height: 8.0),
            if (selectTimeRange != null)
              Button(
                trailing: const Icon(Symbols.history_rounded, weight: 600.0),
                onTap: selectTimeRange,
                child: Text("select.timeRange".t(context)),
              ),
          ],
        ),
      ),
    );
  }
}
