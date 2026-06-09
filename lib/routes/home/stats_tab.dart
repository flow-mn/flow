import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/home/stats/bento/analytics_bento.dart";
import "package:flow/widgets/time_range_selector.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab>
    with AutomaticKeepAliveClientMixin {
  TimeRange range = TimeRange.thisMonth();

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Frame.standalone(
            child: TimeRangeSelector(
              initialValue: range,
              onChanged: updateRange,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  const SizedBox(height: 16.0),
                  AnalyticsBento(range: range),
                  const SizedBox(height: 96.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void updateRange(TimeRange value) {
    range = value;

    if (!mounted) return;
    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;
}
