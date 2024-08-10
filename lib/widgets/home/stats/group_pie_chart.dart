import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flow/data/chart_data.dart';
import 'package:flow/data/exchange_rates.dart';
import 'package:flow/data/flow_icon.dart';
import 'package:flow/entity/account.dart';
import 'package:flow/entity/category.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/main.dart';
import 'package:flow/theme/primary_colors.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/home/stats/pie_percent_badge.dart';
import 'package:flutter/material.dart' hide Flow;

class GroupPieChart<T> extends StatefulWidget {
  final EdgeInsets chartPadding;

  final bool scrollLegendWithin;

  final Map<String, ChartData<T>> data;

  final String? unresolvedDataTitle;

  final void Function(String key)? onReselect;

  final ExchangeRates? rates;

  static const double graphSizeMax = 320.0;
  static const double graphHoleSizeMin = 96.0;

  const GroupPieChart({
    super.key,
    required this.data,
    this.chartPadding = const EdgeInsets.all(24.0),
    this.scrollLegendWithin = false,
    this.unresolvedDataTitle,
    this.onReselect,
    this.rates,
  });

  @override
  State<GroupPieChart<T>> createState() => _GroupPieChartState<T>();
}

class _GroupPieChartState<T> extends State<GroupPieChart<T>> {
  late Map<String, ChartData<T>> data;

  double get totalValue {
    return data.values.fold<double>(
      0.0,
      (previousValue, element) => previousValue + element.money.amount,
    );
  }

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
    final ChartData<T>? selectedSection =
        selectedKey == null ? null : data[selectedKey!];

    final String selectedSectionTotal =
        selectedSection?.money.amount.abs().formatMoney() ?? "-";

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16.0),
        Text(
          "tabs.stats.chart.total".t(context),
          style: context.textTheme.labelMedium,
        ),
        Text(
          totalValue.formatMoney(),
          style: context.textTheme.headlineMedium,
        ),
        Padding(
          padding: widget.chartPadding,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: GroupPieChart.graphSizeMax,
              maxWidth: GroupPieChart.graphSizeMax,
            ),
            child: AspectRatio(
              aspectRatio: 1.0,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double size = constraints.maxWidth;

                  final double centerHoleDiameter =
                      math.max(size * 0.5, GroupPieChart.graphHoleSizeMin);
                  final double radius = (size - centerHoleDiameter) * 0.5;

                  return Stack(
                    children: [
                      PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {
                              if (!event.isInterestedForInteractions ||
                                  response == null ||
                                  response.touchedSection == null) {
                                return;
                              }

                              final int index =
                                  response.touchedSection!.touchedSectionIndex;

                              if (index > -1) {
                                final String newSelectedKey =
                                    data.entries.elementAt(index).key;

                                // if (!usingMouse &&
                                //     newSelectedKey == selectedKey) {
                                //   widget.onReselect?.call(newSelectedKey);
                                // }

                                setState(() {
                                  selectedKey = newSelectedKey;
                                });
                              }
                            },
                          ),
                          sectionsSpace: 0.0,
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
                      ),
                      Positioned.fill(
                        child: Center(
                          child: ClipOval(
                            child: Container(
                              width: centerHoleDiameter,
                              height: centerHoleDiameter,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    resolveName(
                                      selectedSection?.associatedData,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  AutoSizeText(
                                    selectedSectionTotal,
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.headlineSmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  PieChartSectionData sectionData(
    ChartData<T> data, {
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
      value: data.displayTotal,
      title: resolveName(data.associatedData),
      showTitle: false,
      badgeWidget: selected
          ? resolveBadgeWidget(
              data.associatedData,
              color: color,
              backgroundColor: backgroundColor,
              percent: data.displayTotal / totalValue,
            )
          : null,
      badgePositionPercentageOffset: 0.8,
      borderSide: selected
          ? BorderSide(
              color: backgroundColor,
              width: 3.0,
            )
          : null,
    );
  }

  String resolveName(Object? entity) => switch (entity) {
        Category category => category.name,
        Account account => account.name,
        _ => widget.unresolvedDataTitle ?? "-"
      };

  Widget? resolveBadgeWidget(
    Object? entity, {
    Color? color,
    Color? backgroundColor,
    required double percent,
  }) =>
      switch (entity) {
        Category category => PiePercentBadge(
            icon: category.icon,
            color: color,
            backgroundColor: backgroundColor ?? color?.withAlpha(0x40),
            percent: percent,
          ),
        Account account => PiePercentBadge(
            icon: account.icon,
            color: color,
            backgroundColor: backgroundColor ?? color?.withAlpha(0x40),
            percent: percent,
          ),
        _ => PiePercentBadge(
            icon: FlowIconData.emoji("?"),
            color: color,
            backgroundColor: backgroundColor ?? color?.withAlpha(0x40),
            percent: percent),
      };
}
