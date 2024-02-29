import 'package:flow/data/flow_analytics.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/actions.dart';
import 'package:flow/widgets/general/spinner.dart';
import 'package:flow/widgets/home/stats/group_pie_chart.dart';
import 'package:flow/widgets/month_selector_bar.dart';
import 'package:flutter/material.dart';
import 'package:moment_dart/moment_dart.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab>
    with AutomaticKeepAliveClientMixin {
  DateTime from = DateTime.now().startOfMonth();
  DateTime to = DateTime.now().endOfMonth();

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

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          width: double.infinity,
          child: MonthSelectorBar(
            year: from.year,
            month: from.month,
            onUpdate: (year, month) => setState(() {
              from = DateTime(year, month).startOfMonth();
              to = DateTime(year, month).endOfMonth();
              fetch(true);
            }),
          ),
        ),
        busy
            ? const Spinner()
            : AspectRatio(
                aspectRatio: 1.0,
                child: GroupPieChart(
                  data: analytics!.groupData,
                  flow: analytics!.flow,
                ),
              ),
      ],
    );
  }

  Future<void> fetch(bool byCategory) async {
    if (busy) return;

    setState(() {
      busy = true;
    });

    try {
      analytics = byCategory
          ? await ObjectBox().flowByCategories(from: from, to: to)
          : await ObjectBox().flowByAccounts(from: from, to: to);
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
