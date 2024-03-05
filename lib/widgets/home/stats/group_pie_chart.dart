import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flow/data/flow_icon.dart';
import 'package:flow/data/money_flow.dart';
import 'package:flow/entity/account.dart';
import 'package:flow/entity/category.dart';
import 'package:flow/l10n/flow_localizations.dart';
import 'package:flow/main.dart';
import 'package:flow/theme/primary_colors.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/general/flow_icon.dart';
import 'package:flow/widgets/home/stats/legend_list_tile.dart';
import 'package:flutter/material.dart' hide Flow;

class GroupPieChart<T> extends StatefulWidget {
  final EdgeInsets chartPadding;

  final bool showSelectedSection;

  final bool showLegend;
  final bool sortLegend;

  final bool scrollLegendWithin;
  final EdgeInsets scrollPadding;

  final Map<String, MoneyFlow<T>> data;

  final String? unresolvedDataTitle;

  const GroupPieChart({
    super.key,
    required this.data,
    this.chartPadding = const EdgeInsets.all(24.0),
    this.scrollPadding = EdgeInsets.zero,
    this.showLegend = true,
    this.scrollLegendWithin = false,
    this.showSelectedSection = true,
    this.sortLegend = true,
    this.unresolvedDataTitle,
  });

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
    final MoneyFlow<T>? selectedSection =
        selectedKey == null ? null : data[selectedKey!];

    final double selectedSectionProc = selectedSection == null
        ? 0.0
        : (selectedSection.totalExpense /
            data.values.fold<double>(
                0,
                (previousValue, element) =>
                    previousValue + element.totalExpense));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showSelectedSection) ...[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selectedSection == null
                    ? "tabs.stats.chart.select.clickToSelect".t(context)
                    : resolveName(selectedSection.associatedData),
                style: context.textTheme.headlineSmall,
              ),
              Text(
                  "${selectedSection?.totalExpense.abs().money ?? "-"} • ${(100 * selectedSectionProc).toStringAsFixed(1)}%"),
            ],
          ),
          const SizedBox(height: 8.0),
        ],
        Padding(
          padding: widget.chartPadding,
          child: AspectRatio(
            aspectRatio: 1.0,
            child: LayoutBuilder(builder: (context, constraints) {
              final double size = constraints.maxWidth;

              final double centerHoleDiameter = math.min(96.0, size * 0.25);
              final double radius = (size - centerHoleDiameter) * 0.5;

              return PieChart(
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

                    final int index =
                        response.touchedSection!.touchedSectionIndex;

                    if (index > -1) {
                      selectedKey = data.entries.elementAt(index).key;
                      setState(() {});
                    }
                  }),
                  sectionsSpace: 2.0,
                  centerSpaceRadius: centerHoleDiameter / 2,
                  startDegreeOffset: -90.0,
                  sections: data.entries.indexed
                      .map(
                        (e) => sectionData(
                          data[e.$2.key]!,
                          selected: e.$2.key == selectedKey,
                          index: e.$1,
                          radius: radius,
                        ),
                      )
                      .toList(),
                ),
              );
            }),
          ),
        ),
        if (widget.showLegend) buildLegend(context),
      ],
    );
  }

  Widget buildLegendItem(
    BuildContext context,
    int index,
    MapEntry<String, MoneyFlow<T>> entry,
  ) {
    final bool usingDarkTheme = Flow.of(context).useDarkTheme;

    final Color color = (usingDarkTheme
        ? accentColors
        : primaryColors)[index % primaryColors.length];
    final Color backgroundColor = (usingDarkTheme
        ? primaryColors
        : accentColors)[index % primaryColors.length];

    return LegendListTile(
      key: ValueKey(entry.key),
      color: color,
      leading: resolveBadgeWidget(
        entry.value.associatedData,
        color: color,
        backgroundColor: backgroundColor,
      ),
      title: Text(resolveName(entry.value.associatedData)),
      trailing: Text(
        entry.value.totalExpense.moneyCompact,
        style: context.textTheme.bodyLarge,
      ),
      selected: entry.key == selectedKey,
      onTap: () => setState(() => selectedKey = entry.key),
    );
  }

  Widget buildLegend(BuildContext context) {
    final indexed = data.entries.toList().indexed.toList();
    if (widget.sortLegend) {
      indexed.sort(
        (a, b) => a.$2.value.totalExpense.compareTo(
          b.$2.value.totalExpense,
        ),
      );
    }

    if (widget.scrollLegendWithin) {
      return Expanded(
        child: ListView.builder(
          itemBuilder: (context, index) =>
              buildLegendItem(context, indexed[index].$1, indexed[index].$2),
          itemCount: indexed.length,
          padding: widget.scrollPadding,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children:
          indexed.map((e) => buildLegendItem(context, e.$1, e.$2)).toList(),
    );
  }

  PieChartSectionData sectionData(
    MoneyFlow<T> flow, {
    required double radius,
    bool selected = false,
    int index = 0,
  }) {
    final bool usingDarkTheme = Flow.of(context).useDarkTheme;

    final Color color = (usingDarkTheme
        ? accentColors
        : primaryColors)[index % primaryColors.length];
    final Color backgroundColor = (usingDarkTheme
        ? primaryColors
        : accentColors)[index % primaryColors.length];

    return PieChartSectionData(
      color: color,
      radius: radius,
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
      badgePositionPercentageOffset: 0.8,
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
        _ => widget.unresolvedDataTitle ?? "???"
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
