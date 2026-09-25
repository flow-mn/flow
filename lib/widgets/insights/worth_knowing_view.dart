import "package:flow/data/insights/insight_engine.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flow/widgets/insights/insight_formatter.dart";
import "package:flow/widgets/insights/insight_summary.dart";
import "package:flow/widgets/insights/worth_knowing_row.dart";
import "package:flow/widgets/stats/missing_rates_notice.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";

/// The Worth knowing card for a computed [report]. Renders nothing when the
/// engine has too little history to say anything.
class WorthKnowingView extends StatelessWidget {
  /// Null while the first report is on its way.
  final InsightReport? report;

  /// Whether [report] is for another month than the one being loaded.
  final bool stale;

  final InsightFormatter format;

  final int hiddenTypeCount;

  final ValueChanged<Insight> onOpen;
  final ValueChanged<RecurringChargeInsight> onTrack;
  final VoidCallback onManageHidden;

  const WorthKnowingView({
    super.key,
    required this.report,
    required this.format,
    required this.onOpen,
    required this.onTrack,
    required this.onManageHidden,
    this.stale = false,
    this.hiddenTypeCount = 0,
  });

  static bool isVisible(InsightReport? report) => switch (report?.status) {
    null || InsightReportStatus.ready || InsightReportStatus.tooEarly => true,
    _ => false,
  };

  @override
  Widget build(BuildContext context) {
    final InsightReport? report = this.report;

    if (!isVisible(report)) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Surface(
        clipBehavior: .antiAlias,
        builder: (context) => AnimatedOpacity(
          opacity: stale ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16.0,
                  hiddenTypeCount > 0 ? 4.0 : 16.0,
                  hiddenTypeCount > 0 ? 4.0 : 16.0,
                  hiddenTypeCount > 0 ? 0.0 : 4.0,
                ),
                child: Row(
                  children: [
                    Icon(
                      Symbols.lightbulb_rounded,
                      color: context.colorScheme.primary,
                      size: 18.0,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        "tabs.stats.worthKnowing".t(context).toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.flowColors.semi,
                          letterSpacing: 0.6,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (hiddenTypeCount > 0)
                      IconButton(
                        onPressed: onManageHidden,
                        tooltip: "tabs.stats.worthKnowing.kinds".t(context),
                        visualDensity: VisualDensity.compact,
                        iconSize: 18.0,
                        color: context.flowColors.semi,
                        icon: const Icon(Symbols.visibility_off_rounded),
                      ),
                  ],
                ),
              ),
              if (report == null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 20.0),
                  child: Container(
                    width: 180.0,
                    height: 12.0,
                    decoration: BoxDecoration(
                      color: context.colorScheme.onSurface.withAlpha(0x14),
                      borderRadius: .all(Radius.circular(6.0)),
                    ),
                  ),
                )
              else if (report.insights.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                  child: Text(
                    (report.isInProgress
                            ? "tabs.stats.worthKnowing.nothingUnusual"
                            : "tabs.stats.worthKnowing.nothingUnusualPast")
                        .t(context, {
                          "month": report.month.toMoment().format("MMMM"),
                        }),
                    style: context.textTheme.bodyMedium?.semi(context),
                  ),
                )
              else
                for (final (int index, Insight insight)
                    in report.insights.indexed) ...[
                  if (index > 0)
                    Divider(
                      height: 1.0,
                      thickness: 1.0,
                      indent: 16.0,
                      endIndent: 16.0,
                      color: context.colorScheme.onSurface.withAlpha(0x17),
                    ),
                  WorthKnowingRow(
                    summary: InsightSummary.of(
                      context,
                      insight: insight,
                      report: report,
                      format: format,
                    ),
                    onTap: () => onOpen(insight),
                    action: insight is RecurringChargeInsight
                        ? ActionChip(
                            avatar: Icon(
                              Symbols.add_rounded,
                              color: context.colorScheme.primary,
                            ),
                            label: Text(
                              "tabs.stats.worthKnowing.track".t(context),
                            ),
                            labelStyle: context.textTheme.labelMedium?.copyWith(
                              color: context.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            side: BorderSide(
                              color: context.colorScheme.primary.withAlpha(
                                0x80,
                              ),
                            ),
                            shape: const StadiumBorder(),
                            visualDensity: VisualDensity.compact,
                            onPressed: () => onTrack(insight),
                          )
                        : null,
                  ),
                ],
              if (report?.hasMissingRates == true)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: MissingRatesNotice(
                    message: "tabs.stats.analytics.missingRatesAmounts".t(
                      context,
                    ),
                  ),
                ),
              if (report != null && report.insights.isNotEmpty)
                const SizedBox(height: 4.0),
            ],
          ),
        ),
      ),
    );
  }
}
