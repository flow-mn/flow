import 'package:fl_chart/fl_chart.dart';
import 'package:flow/data/flow_icon.dart';
import 'package:flow/data/money_flow.dart';
import 'package:flow/entity/account.dart';
import 'package:flow/entity/category.dart';
import 'package:flow/l10n/flow_localizations.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/general/flow_icon.dart';
import 'package:flow/widgets/home/stats/legend_list_tile.dart';
import 'package:flutter/material.dart';

class GroupPieChart<T> extends StatefulWidget {
  final Map<String, MoneyFlow<T>> data;

  const GroupPieChart({super.key, required this.data});

  @override
  State<GroupPieChart<T>> createState() => _GroupPieChartState<T>();
}

class _GroupPieChartState<T> extends State<GroupPieChart<T>> {
  late Map<String, MoneyFlow<T>> data;

  bool expense = true;

  String? selectedKey;

  @override
  void initState() {
    super.initState();

    data = widget.data;
  }

  @override
  void didUpdateWidget(GroupPieChart<T> oldWidget) {
    data = widget.data;

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 1.0,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(touchCallback: (event, response) {
                if (!event.isInterestedForInteractions ||
                    response == null ||
                    response.touchedSection == null) {
                  setState(() {
                    selectedKey = null;
                  });
                  return;
                }

                final int index = response.touchedSection!.touchedSectionIndex;

                if (index > -1) {
                  selectedKey = data.entries.elementAt(index).key;
                  setState(() {});
                }
              }),
              sectionsSpace: 2.0,
              centerSpaceRadius: 48.0,
              sections: data.entries
                  .map((e) => sectionData(data[e.key]!,
                      showBadge: e.key == selectedKey))
                  .toList(),
            ),
          ),
        ),
        ...data.entries.map((e) => LegendListTile(
              key: ValueKey(e.key),
              leading: resolveBadgeWidget(e.value.associatedData),
              title: Text(resolveName(e.value.associatedData)),
              trailing: Text(
                e.value.totalExpense.moneyCompact,
                style: context.textTheme.bodyLarge,
              ),
              selected: e.key == selectedKey,
              onTap: () => setState(() => selectedKey = e.key),
            ))
      ],
    );
  }

  PieChartSectionData sectionData(MoneyFlow<T> flow, {bool showBadge = false}) {
    return PieChartSectionData(
      color: context.colorScheme.secondary,
      radius: 80.0,
      value: flow.totalExpense.abs(),
      title: resolveName(flow.associatedData),
      showTitle: false,
      badgeWidget: showBadge ? resolveBadgeWidget(flow.associatedData) : null,
      badgePositionPercentageOffset: 1.0,
    );
  }

  String resolveName(Object? entity) => switch (entity) {
        Category category => category.name,
        Account account => account.name,
        _ => "???"
      };

  Widget? resolveBadgeWidget(Object? entity) => switch (entity) {
        Category category => FlowIcon(
            category.icon,
            plated: true,
          ),
        Account account => FlowIcon(
            account.icon,
            plated: true,
          ),
        _ => FlowIcon(
            FlowIconData.emoji("?"),
            plated: true,
          ),
      };
}
