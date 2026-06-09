import "package:flow/data/flow_standard_report.dart";
import "package:flow/data/money.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/primary_currency_dependent_state.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/home/stats/bento/bento_tile.dart";
import "package:flow/widgets/trend.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";

/// Bento preview of spending pace for the selected range.
///
/// When the range includes today it headlines the projected end-of-range
/// expense (extrapolating the average daily spend over the days left);
/// otherwise it shows the range's total spend. Either way it carries a trend
/// against the previous period and the average spent per day. Taps through to
/// the full forecast + averages on the cash-flow page.
class PaceTile extends StatefulWidget {
  final TimeRange range;

  const PaceTile({super.key, required this.range});

  @override
  State<PaceTile> createState() => _PaceTileState();
}

class _PaceTileState extends State<PaceTile>
    with PrimaryCurrencyDependentState<PaceTile> {
  bool busy = true;
  bool loaded = false;

  FlowStandardReport? report;

  @override
  void didUpdateWidget(PaceTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.range != oldWidget.range) fetch();
  }

  @override
  Widget build(BuildContext context) {
    final FlowStandardReport? report = this.report;

    final bool empty =
        report == null ||
        (report.incomeSum.amount.abs() <= 0 &&
            report.expenseSum.amount.abs() <= 0);

    return BentoTile(
      label: "tabs.stats.analytics.pace".t(context),
      icon: Symbols.speed_rounded,
      accent: context.flowColors.expense,
      height: 160.0,
      busy: busy && !loaded,
      onTap: () => context.push("/stats/cash-flow"),
      child: empty
          ? Text(
              "tabs.stats.analytics.cashFlow.noMovement".t(context),
              style: context.textTheme.bodySmall?.semi(context),
            )
          : _buildContent(context, report),
    );
  }

  Widget _buildContent(BuildContext context, FlowStandardReport report) {
    final bool forecasting = widget.range.contains(DateTime.now());

    final Money headline = forecasting
        ? (report.currentExpenseSumForecast ?? report.expenseSum)
        : report.expenseSum;

    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          (forecasting
                  ? "tabs.stats.analytics.pace.projected"
                  : "tabs.stats.analytics.pace.totalSpent")
              .t(context),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.labelMedium?.semi(context),
        ),
        const SizedBox(height: 2.0),
        Row(
          children: [
            Expanded(
              child: MoneyText(
                headline,
                displayAbsoluteAmount: true,
                style: context.textTheme.titleLarge?.copyWith(
                  color: context.flowColors.expense,
                  fontWeight: FontWeight.w700,
                ),
                autoSize: true,
                initiallyAbbreviated: true,
              ),
            ),
            if (report.previousExpenseSum != null) ...[
              const SizedBox(width: 8.0),
              Trend.fromMoney(
                current: headline,
                previous: report.previousExpenseSum,
              ),
            ],
          ],
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Flexible(
              child: Text(
                "tabs.stats.analytics.pace.perDay".t(context),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.semi(context),
              ),
            ),
            const SizedBox(width: 8.0),
            Flexible(
              child: MoneyText(
                report.dailyAvgExpenditure,
                displayAbsoluteAmount: true,
                style: context.textTheme.titleSmall?.copyWith(
                  color: context.flowColors.expense,
                  fontWeight: FontWeight.w600,
                ),
                autoSize: true,
                initiallyAbbreviated: true,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Future<void> fetch() async {
    try {
      final FlowStandardReport next = await FlowStandardReport.generate(
        widget.range,
        rates,
      );
      if (!mounted) return;
      report = next;
      loaded = true;
    } finally {
      busy = false;
      if (mounted) setState(() {});
    }
  }
}
