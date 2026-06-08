import "package:flow/data/money.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flow/widgets/stats/cash_flow/cash_flow_figure.dart";
import "package:flow/widgets/stats/cash_flow/cash_flow_flow_bar.dart";
import "package:flow/widgets/trend.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";

/// Cash-flow hero summary: the net result (saved or overspent) headlined above
/// an in-vs-out proportion bar and the two side figures.
///
/// Mirrors the bento [CashFlowTile] preview so the full page and its dashboard
/// tile read as the same thing, just at different sizes.
class CashFlowSummary extends StatelessWidget {
  final Money income;
  final Money expense;
  final Money net;

  /// Optional projected end-of-range expense, shown as a footer beneath the
  /// in/out figures. When null the footer is omitted. [forecastLabel] is the
  /// caption (e.g. "Expense forecast for June") and [forecastComparison] the
  /// previous period's expense, used for the trend.
  final Money? forecast;
  final Money? forecastComparison;
  final String? forecastLabel;

  const CashFlowSummary({
    super.key,
    required this.income,
    required this.expense,
    required this.net,
    this.forecast,
    this.forecastComparison,
    this.forecastLabel,
  });

  @override
  Widget build(BuildContext context) {
    final bool saved = net.amount >= 0;
    final Color netColor = saved
        ? context.flowColors.income
        : context.flowColors.expense;

    return Frame(
      child: Surface(
        builder: (context) => Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: netColor.withAlpha(0x24),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      saved
                          ? Symbols.savings_rounded
                          : Symbols.trending_down_rounded,
                      color: netColor,
                      size: 22.0,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: .start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          (saved
                                  ? "tabs.stats.analytics.saved"
                                  : "tabs.stats.analytics.overspent")
                              .t(context),
                          style: context.textTheme.labelMedium?.copyWith(
                            color: context.colorScheme.onSecondary.withAlpha(
                              0x99,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        MoneyText(
                          saved ? net : -net,
                          autoSize: true,
                          maxLines: 1,
                          tapToToggleAbbreviation: true,
                          style: context.textTheme.displaySmall?.copyWith(
                            color: netColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              CashFlowFlowBar(income: income.amount, expense: expense.amount),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  CashFlowFigure(
                    label: "tabs.stats.analytics.in".t(context),
                    money: income,
                    color: context.flowColors.income,
                  ),
                  const Spacer(),
                  CashFlowFigure(
                    label: "tabs.stats.analytics.out".t(context),
                    money: expense,
                    color: context.flowColors.expense,
                    alignEnd: true,
                  ),
                ],
              ),
              if (forecast case final Money forecast) ...[
                const SizedBox(height: 16.0),
                Container(
                  height: 1.0,
                  color: context.colorScheme.onSurface.withAlpha(0x1a),
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        forecastLabel ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colorScheme.onSecondary.withAlpha(
                            0x99,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    MoneyText(
                      forecast,
                      displayAbsoluteAmount: true,
                      initiallyAbbreviated: true,
                      tapToToggleAbbreviation: true,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.flowColors.expense,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (forecastComparison case final Money previous) ...[
                      const SizedBox(width: 8.0),
                      Trend.fromMoney(current: forecast, previous: previous),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
