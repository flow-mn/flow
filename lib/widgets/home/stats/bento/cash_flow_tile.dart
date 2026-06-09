import "package:flow/data/money.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions.dart";
import "package:flow/utils/primary_currency_dependent_state.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/home/stats/bento/bento_tile.dart";
import "package:flow/widgets/stats/cash_flow/cash_flow_figure.dart";
import "package:flow/widgets/stats/cash_flow/cash_flow_flow_bar.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";

/// Bento preview of cash flow for the selected range: a hero net "Saved" or
/// "Overspent" figure, a single stacked in/out flow bar, and the labeled
/// income and expense totals anchored to each side of the bar.
class CashFlowTile extends StatefulWidget {
  final TimeRange range;

  const CashFlowTile({super.key, required this.range});

  @override
  State<CashFlowTile> createState() => _CashFlowTileState();
}

class _CashFlowTileState extends State<CashFlowTile>
    with PrimaryCurrencyDependentState<CashFlowTile> {
  bool busy = true;
  bool loaded = false;

  double income = 0.0;
  double expense = 0.0;

  @override
  void didUpdateWidget(CashFlowTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.range != oldWidget.range) fetch();
  }

  @override
  Widget build(BuildContext context) {
    final double net = income - expense;
    final bool saved = net >= 0;
    final bool empty = income <= 0 && expense <= 0;

    final Color netColor = saved
        ? context.flowColors.income
        : context.flowColors.expense;

    return BentoTile(
      label: "tabs.stats.analytics.cashFlow".t(context),
      icon: Symbols.swap_vert_rounded,
      height: 160.0,
      busy: busy && !loaded,
      onTap: () => context.push("/stats/cash-flow"),
      child: empty
          ? Text(
              "tabs.stats.analytics.cashFlow.noMovement".t(context),
              style: context.textTheme.bodySmall?.semi(context),
            )
          : Column(
              crossAxisAlignment: .start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) => Row(
                    crossAxisAlignment: .center,
                    children: [
                      Icon(
                        saved
                            ? Symbols.savings_rounded
                            : Symbols.trending_down_rounded,
                        color: netColor,
                        size: 18.0,
                      ),
                      const SizedBox(width: 6.0),
                      // Cap the label so a long localized "Overspent"
                      // ellipsizes instead of overflowing the narrow tile; the
                      // net figure keeps the rest and stays pinned right.
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth * 0.55,
                        ),
                        child: Text(
                          (saved
                                  ? "tabs.stats.analytics.saved"
                                  : "tabs.stats.analytics.overspent")
                              .t(context),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.labelMedium?.semi(context),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: MoneyText(
                          Money(saved ? net : -net, primaryCurrency),
                          style: context.textTheme.titleLarge?.copyWith(
                            color: netColor,
                            fontWeight: FontWeight.w700,
                          ),
                          autoSize: true,
                          initiallyAbbreviated: true,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12.0),
                CashFlowFlowBar(income: income, expense: expense),
                const SizedBox(height: 8.0),
                // Each figure claims half the row and scales down rather than
                // overflowing when the tile is narrow (e.g. paired with Pace).
                Row(
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: .scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: CashFlowFigure(
                          label: "tabs.stats.analytics.in".t(context),
                          money: Money(income, primaryCurrency),
                          color: context.flowColors.income,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: FittedBox(
                        fit: .scaleDown,
                        alignment: AlignmentDirectional.centerEnd,
                        child: CashFlowFigure(
                          label: "tabs.stats.analytics.out".t(context),
                          money: Money(expense, primaryCurrency),
                          color: context.flowColors.expense,
                          alignEnd: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  @override
  Future<void> fetch() async {
    try {
      final List<Transaction> transactions = await ObjectBox()
          .transcationsByRange(widget.range, includeTransfers: false);

      double nextIncome = 0.0;
      double nextExpense = 0.0;

      for (final Transaction transaction in transactions) {
        final double? converted = transaction.money.tryConvertAmount(
          primaryCurrency,
          rates,
        );
        if (converted == null) continue;

        if (transaction.type == TransactionType.income) {
          nextIncome += converted.abs();
        } else if (transaction.type == TransactionType.expense) {
          nextExpense += converted.abs();
        }
      }

      income = nextIncome;
      expense = nextExpense;
      loaded = true;
    } finally {
      busy = false;
      if (mounted) setState(() {});
    }
  }
}
