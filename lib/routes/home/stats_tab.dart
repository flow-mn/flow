import 'package:flow/data/flow_analytics.dart';
import 'package:flow/data/money_flow.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/actions.dart';
import 'package:flow/widgets/general/spinner.dart';
import 'package:flow/widgets/home/stats/group_pie_chart.dart';
import 'package:flow/widgets/time_range_selector.dart';
import 'package:flutter/material.dart';
import 'package:moment_dart/moment_dart.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab>
    with AutomaticKeepAliveClientMixin {
  TimeRange range = TimeRange.thisMonth();

  FlowAnalytics? analytics;

  bool busy = false;

  @override
  void initState() {
    super.initState();

    fetch(true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final Map<String, MoneyFlow> data = analytics == null
        ? {}
        : Map.fromEntries(
            analytics!.flow.entries
                .where((element) => element.value.totalExpense < 0),
          );

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          width: double.infinity,
          child: TimeRangeSelector(
            initialValue: range,
            onChanged: updateRange,
          ),
        ),
        busy
            ? const Spinner()
            : (data.isEmpty
                ? const Text("mty")
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GroupPieChart(
                        data: data,
                      ),
                    ],
                  )),
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
          ? await ObjectBox().flowByCategories(from: range.from, to: range.to)
          : await ObjectBox().flowByAccounts(from: range.from, to: range.to);
    } finally {
      busy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  bool get wantKeepAlive => true;
}

enum StatsTabTimeRangeMode {
  thisWeek,
  thisMonth,
  custom,
}
