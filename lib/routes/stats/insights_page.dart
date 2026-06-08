import "package:flow/l10n/extensions.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/home/stats/bento/calendar_tile.dart";
import "package:flow/widgets/home/stats/bento/map_tile.dart";
import "package:flow/widgets/home/stats/bento/net_worth_tile.dart";
import "package:flow/widgets/home/stats/bento/recurring_tile.dart";
import "package:flow/widgets/home/stats/bento/wrapped_tile.dart";
import "package:flow/widgets/stats/stats_app_bar.dart";
import "package:flutter/material.dart";

/// Index of the analytics ("Insights") pages.
///
/// Shows the same bento previews as the Stats tab's timeless section behind a
/// single Profile tab entry, so the insights are discoverable from one place
/// without crowding the menu. Only the range-independent tiles live here — the
/// range-bound ones (cash flow, top categories) stay on the Stats tab — so this
/// page needs no time-range selector. Each tile loads its own preview data and
/// pushes the corresponding `/stats/*` detail page on tap.
class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StatsAppBar(title: "tabs.stats.insights".t(context)),
      // Tiles have fixed heights, so cap text scaling to keep dense previews
      // from overflowing under large accessibility font settings.
      body: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.3,
        child: SingleChildScrollView(
          child: SafeArea(
            top: false,
            child: Frame(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  const SizedBox(height: 16.0),
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
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
