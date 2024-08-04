import 'package:flow/data/flow_analytics.dart';
import 'package:flow/data/money_flow.dart';
import 'package:flow/entity/transaction.dart';
import 'package:flow/l10n/flow_localizations.dart';
import 'package:flow/l10n/named_enum.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/actions.dart';
import 'package:flow/prefs.dart';
import 'package:flow/routes/home/stats_tab/pie_graph_view.dart';
import 'package:flow/widgets/general/spinner.dart';
import 'package:flow/widgets/time_range_selector.dart';
import 'package:flow/widgets/utils/time_and_range.dart';
import 'package:flutter/material.dart';
import 'package:moment_dart/moment_dart.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  TimeRange range = TimeRange.thisMonth();

  FlowAnalytics? analytics;

  bool busy = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    fetch(true);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, MoneyFlow> expenses = analytics == null
        ? {}
        : Map.fromEntries(
            analytics!.flow.entries
                .where((element) => element.value.totalExpense < 0)
                .toList()
              ..sort(
                (a, b) => b.value.totalExpense.compareTo(a.value.totalExpense),
              ),
          );
    final Map<String, MoneyFlow> incomes = analytics == null
        ? {}
        : Map.fromEntries(
            analytics!.flow.entries
                .where((element) => element.value.totalIncome > 0)
                .toList()
              ..sort(
                (a, b) => a.value.totalIncome.compareTo(b.value.totalIncome),
              ),
          );

    return Column(
      children: [
        Material(
          elevation: 1.0,
          child: Container(
            padding: const EdgeInsets.all(16.0).copyWith(bottom: 8.0),
            width: double.infinity,
            child: TimeRangeSelector(
              initialValue: range,
              onChanged: updateRange,
            ),
          ),
        ),
        if (busy)
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Spinner(),
          )
        else ...[
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: TransactionType.expense.localizedTextKey.t(context)),
              Tab(text: TransactionType.income.localizedTextKey.t(context)),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                PieGraphView(
                  data: expenses,
                  changeMode: changeMode,
                  range: range,
                  type: TransactionType.expense,
                ),
                PieGraphView(
                  data: incomes,
                  changeMode: changeMode,
                  range: range,
                  type: TransactionType.income,
                ),
              ],
            ),
          )
        ],
      ],
    );
  }

  void updateRange(TimeRange newRange) {
    setState(() {
      range = newRange;
    });

    fetch(true);
  }

  Future<void> fetch(bool byCategory) async {
    if (busy) return;

    setState(() {
      busy = true;
    });

    try {
      analytics = byCategory
          ? await ObjectBox().flowByCategories(
              from: range.from,
              to: range.to,
              currencyOverride: LocalPreferences().getPrimaryCurrency(),
            )
          : await ObjectBox().flowByAccounts(
              from: range.from,
              to: range.to,
              currencyOverride: LocalPreferences().getPrimaryCurrency(),
            );
    } finally {
      busy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> changeMode() async {
    final TimeRange? newRange = await showTimeRangePickerSheet(
      context,
      initialValue: range,
    );

    if (!mounted || newRange == null) return;

    setState(() {
      range = newRange;
    });
  }
}
