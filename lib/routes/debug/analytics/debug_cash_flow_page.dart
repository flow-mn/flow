import "package:flow/data/exchange_rates.dart";
import "package:flow/data/money.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/primary_colors.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/debug/analytics/sankey_diagram.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

/// [dev] Cash-flow Sankey.
///
/// Income categories flow through a single total hub into spending categories
/// (plus a balancing "Saved" / "From reserves" node) for the current month.
/// Built from category-flow aggregation (`flowByCategories`) over existing
/// data.
class DebugCashFlowPage extends StatefulWidget {
  const DebugCashFlowPage({super.key});

  @override
  State<DebugCashFlowPage> createState() => _DebugCashFlowPageState();
}

class _DebugCashFlowPageState extends State<DebugCashFlowPage> {
  static const int _maxIncomeNodes = 4;
  static const int _maxExpenseNodes = 6;

  bool busy = false;
  bool missingRates = false;

  late String primaryCurrency;
  ExchangeRates? rates;

  List<SankeyDatum> sources = [];
  List<SankeyDatum> targets = [];
  double totalIncome = 0.0;
  double totalExpense = 0.0;

  @override
  void initState() {
    super.initState();

    primaryCurrency = UserPreferencesService().primaryCurrency;
    rates = ExchangeRatesService().getPrimaryCurrencyRates();

    fetch();
  }

  @override
  Widget build(BuildContext context) {
    final String month = DateTime.now().toMoment().format("MMMM");
    final bool hasData = sources.isNotEmpty && targets.isNotEmpty;
    final double net = totalIncome - totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: Text("Cash flow · $month (dev)"),
        elevation: 0.0,
        scrolledUnderElevation: 1.0,
        centerTitle: false,
        shadowColor: context.colorScheme.onSurface.withAlpha(0x40),
        backgroundColor: context.colorScheme.surface,
        surfaceTintColor: kTransparent,
      ),
      body: SafeArea(
        child: busy && sources.isEmpty
            ? const Spinner.center()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16.0),
                    _Summary(
                      income: Money(totalIncome, primaryCurrency),
                      expense: Money(totalExpense, primaryCurrency),
                      net: Money(net, primaryCurrency),
                    ),
                    const SizedBox(height: 16.0),
                    if (hasData) ...[
                      Frame(
                        child: SankeyDiagram(
                          sources: sources,
                          targets: targets,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      const ListHeader("Income"),
                      const SizedBox(height: 8.0),
                      _Legend(data: sources, currency: primaryCurrency),
                      const SizedBox(height: 16.0),
                      const ListHeader("Spending"),
                      const SizedBox(height: 8.0),
                      _Legend(data: targets, currency: primaryCurrency),
                    ] else
                      const Frame(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 48.0),
                          child: Center(
                            child: Text("No cash flow this month."),
                          ),
                        ),
                      ),
                    if (missingRates) ...[
                      const SizedBox(height: 12.0),
                      Frame(
                        child: Text(
                          "Some non-primary currency amounts were skipped "
                          "(missing exchange rates).",
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.flowColors.expense,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 96.0),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> fetch() async {
    if (!mounted) return;
    setState(() {
      busy = true;
    });

    bool missing = false;

    try {
      primaryCurrency = UserPreferencesService().primaryCurrency;
      rates = ExchangeRatesService().getPrimaryCurrencyRates();

      // Resolve theme colors before the await so we never read [context]
      // across an async gap.
      final Color otherColor = context.colorScheme.onSurface.withAlpha(0x66);
      final Color incomeColor = context.flowColors.income;
      final Color expenseColor = context.flowColors.expense;

      final analytics = await ObjectBox().flowByCategories(
        range: TimeRange.thisMonth(),
      );

      final List<SankeyDatum> incomeNodes = [];
      final List<SankeyDatum> expenseNodes = [];
      double income = 0.0;
      double expense = 0.0;
      int colorIndex = 0;

      for (final entry in analytics.flow.entries) {
        final flow = entry.value;
        final single = flow.merge(primaryCurrency, rates);
        missing = missing || single.hasMissingData;

        final String name = flow.associatedData?.name ?? "Uncategorized";
        final Color color =
            flow.associatedData?.colorScheme?.primary ??
            accentColors[colorIndex++ % accentColors.length];

        final double incomeAmount = single.totalIncome.amount;
        final double expenseAmount = single.totalExpense.amount.abs();

        if (incomeAmount > 0) {
          incomeNodes.add(
            SankeyDatum(label: name, value: incomeAmount, color: color),
          );
          income += incomeAmount;
        }
        if (expenseAmount > 0) {
          expenseNodes.add(
            SankeyDatum(label: name, value: expenseAmount, color: color),
          );
          expense += expenseAmount;
        }
      }

      final List<SankeyDatum> nextSources = _bucket(
        incomeNodes,
        _maxIncomeNodes,
        otherColor,
      );
      final List<SankeyDatum> nextTargets = _bucket(
        expenseNodes,
        _maxExpenseNodes,
        otherColor,
      );

      // Balance the two sides so the hub is fully covered: surplus becomes a
      // "Saved" target, a deficit becomes a "From reserves" source.
      final double net = income - expense;
      final double threshold = (income > expense ? income : expense) * 0.001;
      if (net > threshold) {
        nextTargets.add(
          SankeyDatum(label: "Saved", value: net, color: incomeColor),
        );
      } else if (net < -threshold) {
        nextSources.add(
          SankeyDatum(label: "From reserves", value: -net, color: expenseColor),
        );
      }

      sources = nextSources;
      targets = nextTargets;
      totalIncome = income;
      totalExpense = expense;
      missingRates = missing;
    } finally {
      busy = false;
      if (mounted) setState(() {});
    }
  }

  /// Keeps the top [max] nodes by value and rolls the rest into "Other".
  List<SankeyDatum> _bucket(
    List<SankeyDatum> nodes,
    int max,
    Color otherColor,
  ) {
    final List<SankeyDatum> sorted = [...nodes]
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sorted.length <= max) return sorted;

    final List<SankeyDatum> top = sorted.take(max - 1).toList();
    final double otherSum = sorted
        .skip(max - 1)
        .fold(0.0, (sum, node) => sum + node.value);

    return [
      ...top,
      SankeyDatum(label: "Other", value: otherSum, color: otherColor),
    ];
  }
}

class _Summary extends StatelessWidget {
  final Money income;
  final Money expense;
  final Money net;

  const _Summary({
    required this.income,
    required this.expense,
    required this.net,
  });

  @override
  Widget build(BuildContext context) {
    final bool saved = net.amount >= 0;

    return Frame(
      child: Wrap(
        spacing: 20.0,
        runSpacing: 8.0,
        children: [
          _SummaryItem(
            label: "In",
            money: income,
            color: context.flowColors.income,
          ),
          _SummaryItem(
            label: "Out",
            money: expense,
            color: context.flowColors.expense,
          ),
          _SummaryItem(
            label: saved ? "Saved" : "Overspent",
            money: saved ? net : -net,
            color: saved
                ? context.flowColors.income
                : context.flowColors.expense,
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final Money money;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.money,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: context.textTheme.labelMedium?.semi(context)),
        MoneyText(
          money,
          style: context.textTheme.titleMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final List<SankeyDatum> data;
  final String currency;

  const _Legend({required this.data, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Frame(
      child: Column(
        children: data.map((datum) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Container(
                  width: 12.0,
                  height: 12.0,
                  decoration: BoxDecoration(
                    color: datum.color,
                    borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    datum.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: 8.0),
                MoneyText(
                  Money(datum.value, currency),
                  style: context.textTheme.bodyMedium?.semi(context),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
