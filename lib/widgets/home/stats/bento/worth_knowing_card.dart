import "dart:async";

import "package:flow/data/insights/insight_engine.dart";
import "package:flow/prefs/insights_preferences.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/insights.dart";
import "package:flow/utils/primary_currency_dependent_state.dart";
import "package:flow/widgets/insights/insight_actions.dart";
import "package:flow/widgets/insights/insight_evidence_sheet.dart";
import "package:flow/widgets/insights/insight_formatter.dart";
import "package:flow/widgets/insights/insight_kinds_sheet.dart";
import "package:flow/widgets/insights/worth_knowing_view.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:moment_dart/moment_dart.dart";

final Logger _log = Logger("WorthKnowingCard");

/// A few computed observations about the selected month, above the Stats
/// tiles. Hidden for ranges other than a month.
class WorthKnowingCard extends StatefulWidget {
  final TimeRange range;

  const WorthKnowingCard({super.key, required this.range});

  @override
  State<WorthKnowingCard> createState() => _WorthKnowingCardState();
}

class _WorthKnowingCardState extends State<WorthKnowingCard>
    with PrimaryCurrencyDependentState<WorthKnowingCard> {
  bool busy = true;
  InsightReport? report;

  /// Drops results of fetches that a newer one replaced.
  int _generation = 0;

  DateTime? get month => switch (widget.range) {
    MonthTimeRange range => range.from,
    _ => null,
  };

  InsightFormatter get format => InsightFormatter(
    currency: primaryCurrency,
    obscure: TransitiveLocalPreferences().sessionPrivacyMode.get(),
    useCurrencySymbol: LocalPreferences().useCurrencySymbol.get(),
    preferFullAmounts: LocalPreferences().preferFullAmounts.get(),
  );

  late final Listenable _formatting = Listenable.merge([
    TransitiveLocalPreferences().sessionPrivacyMode.valueNotifier,
    LocalPreferences().useCurrencySymbol.valueNotifier,
    LocalPreferences().preferFullAmounts.valueNotifier,
    InsightsLocalPreferences().hiddenTypes.valueNotifier,
  ]);

  @override
  void initState() {
    super.initState();
    InsightsLocalPreferences().hiddenTypes.addListener(_onHiddenTypesChanged);
  }

  @override
  void dispose() {
    InsightsLocalPreferences().hiddenTypes.removeListener(
      _onHiddenTypesChanged,
    );
    super.dispose();
  }

  @override
  void didUpdateWidget(WorthKnowingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.range != oldWidget.range) fetch();
  }

  @override
  Widget build(BuildContext context) {
    final DateTime? month = this.month;

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: month == null || (!busy && report == null)
          ? const SizedBox(width: double.infinity)
          : ListenableBuilder(
              listenable: _formatting,
              builder: (context, _) => WorthKnowingView(
                report: report,
                stale:
                    report != null &&
                    (report!.month.year != month.year ||
                        report!.month.month != month.month),
                format: format,
                hiddenTypeCount:
                    InsightsLocalPreferences().hiddenTypeSet.length,
                onOpen: _open,
                onTrack: (insight) =>
                    InsightActions.trackAsRecurring(context, insight.series),
                onManageHidden: _manageHidden,
              ),
            ),
    );
  }

  void _onHiddenTypesChanged() => fetch();

  void _open(Insight insight) {
    final InsightReport? report = this.report;
    if (report == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => InsightEvidenceSheet(
        insight: insight,
        report: report,
        format: format,
      ),
    );
  }

  void _manageHidden() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => const InsightKindsSheet(),
  );

  @override
  Future<void> fetch() async {
    final int generation = ++_generation;
    final DateTime? month = this.month;

    if (month == null) {
      report = null;
      busy = false;
      if (mounted) setState(() {});
      return;
    }

    busy = true;

    try {
      final InsightReport next = await InsightsService().computeFor(
        month,
        hiddenTypes: InsightsLocalPreferences().hiddenTypeSet,
        sightings: InsightsLocalPreferences().sightingList,
      );
      if (generation != _generation) return;

      report = next;

      if (next.isInProgress && next.insights.isNotEmpty) {
        unawaited(
          InsightsLocalPreferences()
              .recordSightings(next.insights, DateTime.now())
              .catchError(
                (error, stackTrace) => _log.warning(
                  "Failed to record insight sightings",
                  error,
                  stackTrace,
                ),
              ),
        );
      }
    } catch (e, stackTrace) {
      _log.warning("Failed to compute insights", e, stackTrace);
      if (generation == _generation) report = null;
    } finally {
      if (generation == _generation) {
        busy = false;
        if (mounted) setState(() {});
      }
    }
  }
}
