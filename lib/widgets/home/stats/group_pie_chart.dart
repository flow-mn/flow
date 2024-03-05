import 'package:fl_chart/fl_chart.dart';
import 'package:flow/data/flow_icon.dart';
import 'package:flow/data/money_flow.dart';
import 'package:flow/entity/account.dart';
import 'package:flow/entity/category.dart';
import 'package:flow/l10n/flow_localizations.dart';
import 'package:flow/theme/primary_colors.dart';
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
                  // setState(() {
                  //   selectedKey = null;
                  // });
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
              startDegreeOffset: -90.0,
              sections: data.entries.indexed
                  .map(
                    (e) => sectionData(
                      data[e.$2.key]!,
                      selected: e.$2.key == selectedKey,
                      index: e.$1,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        ...(data.entries.toList().indexed.toList()
              ..sort((a, b) =>
                  a.$2.value.totalExpense.compareTo(b.$2.value.totalExpense)))
            .map((e) {
          final color = primaryColors[e.$1 % primaryColors.length];
          final backgroundColor = accentColors[e.$1 % primaryColors.length];

          return LegendListTile(
            key: ValueKey(e.$2.key),
            color: color,
            leading: resolveBadgeWidget(
              e.$2.value.associatedData,
              color: color,
              backgroundColor: backgroundColor,
            ),
            title: Text(resolveName(e.$2.value.associatedData)),
            trailing: Text(
              e.$2.value.totalExpense.moneyCompact,
              style: context.textTheme.bodyLarge,
            ),
            selected: e.$2.key == selectedKey,
            onTap: () => setState(() => selectedKey = e.$2.key),
          );
        })
      ],
    );
  }

  PieChartSectionData sectionData(
    MoneyFlow<T> flow, {
    bool selected = false,
    int index = 0,
  }) {
    final color = primaryColors[index % primaryColors.length];
    final backgroundColor = accentColors[index % primaryColors.length];

    return PieChartSectionData(
      color: color,
      radius: 80.0,
      value: flow.totalExpense.abs(),
      title: resolveName(flow.associatedData),
      showTitle: false,
      badgeWidget: selected
          ? resolveBadgeWidget(
              flow.associatedData,
              color: color,
              backgroundColor: backgroundColor,
            )
          : null,
      badgePositionPercentageOffset: 1.1,
      borderSide: selected
          ? BorderSide(
              color: context.colorScheme.primary,
              width: 2.0,
              strokeAlign: BorderSide.strokeAlignInside,
            )
          : BorderSide.none,
    );
  }

  String resolveName(Object? entity) => switch (entity) {
        Category category => category.name,
        Account account => account.name,
        _ => "???"
      };

  Widget? resolveBadgeWidget(Object? entity,
          {Color? color, Color? backgroundColor}) =>
      switch (entity) {
        Category category => FlowIcon(
            category.icon,
            plated: true,
            color: color,
            plateColor: backgroundColor ?? color?.withAlpha(0x40),
          ),
        Account account => FlowIcon(
            account.icon,
            plated: true,
            color: color,
            plateColor: backgroundColor ?? color?.withAlpha(0x40),
          ),
        _ => FlowIcon(
            FlowIconData.emoji("?"),
            plated: true,
            color: color,
            plateColor: backgroundColor ?? color?.withAlpha(0x40),
          ),
      };
}
