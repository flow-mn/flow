import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/empty_state.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";

class NoData extends StatelessWidget {
  final VoidCallback? selectTimeRange;

  const NoData({super.key, this.selectTimeRange});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: FlowIconData.icon(Symbols.query_stats_rounded),
      title: Text("tabs.stats.chart.noData".t(context)),
      trailing: selectTimeRange != null
          ? Button(
              trailing: const Icon(Symbols.history_rounded, weight: 600.0),
              onTap: selectTimeRange,
              child: Text("select.timeRange".t(context)),
            )
          : null,
    );
  }
}
