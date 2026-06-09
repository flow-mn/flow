import "package:flow/l10n/extensions.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/home/stats/bento/calendar_tile.dart";
import "package:flow/widgets/home/stats/bento/cash_flow_tile.dart";
import "package:flow/widgets/home/stats/bento/map_tile.dart";
import "package:flow/widgets/home/stats/bento/net_worth_tile.dart";
import "package:flow/widgets/home/stats/bento/pace_tile.dart";
import "package:flow/widgets/home/stats/bento/recurring_tile.dart";
import "package:flow/widgets/home/stats/bento/top_categories_tile.dart";
import "package:flow/widgets/home/stats/bento/wrapped_tile.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

/// The Stats bento dashboard, split into two sections.
///
/// The top section is **range-bound**: [CashFlowTile], [PaceTile], and
/// [TopCategoriesTile] follow the [range] picked by the Stats tab's time-range
/// selector, so they belong directly beneath it.
///
/// Below an "Insights" header sits the **timeless** section: net worth,
/// wrapped, the spending calendar, recurring, and the spending map each show
/// their own natural window and ignore the selected month. Grouping them apart
/// keeps the range selector from implying control it doesn't have. The same
/// pages are also reachable from Profile → Insights.
class AnalyticsBento extends StatelessWidget {
  final TimeRange range;

  const AnalyticsBento({super.key, required this.range});

  @override
  Widget build(BuildContext context) {
    // Tiles have fixed heights, so cap text scaling to keep dense previews
    // from overflowing under large accessibility font settings.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: Frame(
        child: Column(
          crossAxisAlignment: .start,
          children: [
            // Range-bound — these respond to the selected time range. Cash
            // flow and pace share a row to stay compact; each takes half.
            Row(
              spacing: 12.0,
              children: [
                Expanded(child: CashFlowTile(range: range)),
                Expanded(child: PaceTile(range: range)),
              ],
            ),
            const SizedBox(height: 12.0),
            TopCategoriesTile(range: range),
            const SizedBox(height: 24.0),
            // Timeless — each shows its own natural window, independent of the
            // selected range.
            ListHeader(
              "tabs.stats.insights".t(context),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 12.0),
            const WrappedTile(),
            const SizedBox(height: 12.0),
            const NetWorthTile(),
            const SizedBox(height: 12.0),
            const Row(
              spacing: 12.0,
              children: [
                Expanded(child: CalendarTile()),
                Expanded(child: RecurringTile()),
              ],
            ),
            const SizedBox(height: 12.0),
            const MapTile(),
          ],
        ),
      ),
    );
  }
}
