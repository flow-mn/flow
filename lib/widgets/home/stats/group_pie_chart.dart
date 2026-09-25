import "dart:math" as math;

import "package:fl_chart/fl_chart.dart";
import "package:flow/data/chart_data.dart";
import "package:flow/data/exchange_rates.dart";
import "package:flow/data/flow_icon.dart";
import "package:flow/data/money.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions/chart_data.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/home/stats/pie_percent_badge.dart";
import "package:flutter/material.dart";

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

  Money get totalAmount {
    return data.values.fold<Money>(
      Money(0, data.values.first.money.currency),
      (previousValue, element) => previousValue + element.money,
    );
  }

  String? selectedKey;

  /// Selection before the current touch, so only a re-tap opens a slice
  String? _keyAtTouchStart;

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
    final ChartData<T>? selectedSection = selectedKey == null
        ? null
        : data[selectedKey!];

    final Map<String, Color> colors = data.resolveColors(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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

                  final double centerHoleDiameter = math.max(
                    size * 0.5,
                    GroupPieChart.graphHoleSizeMin,
                  );
                  final double radius = (size - centerHoleDiameter) * 0.5;

                  return Stack(
                    children: [
                      PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(touchCallback: _onTouch),
                          sectionsSpace: 1.0,
                          centerSpaceRadius: centerHoleDiameter / 2,
                          startDegreeOffset: -90.0,
                          sections: data.entries.indexed
                              .map(
                                (e) => sectionData(
                                  data[e.$2.key]!,
                                  selected: e.$2.key == selectedKey,
                                  color: colors[e.$2.key]!,
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
                                    selectedSection == null
                                        ? "tabs.stats.chart.total".t(context)
                                        : resolveName(
                                            selectedSection.associatedData,
                                          ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  MoneyText(
                                    selectedSection?.money ?? totalAmount,
                                    displayAbsoluteAmount: true,
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.headlineSmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
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

  void _onTouch(FlTouchEvent event, PieTouchResponse? response) {
    final int index = response?.touchedSection?.touchedSectionIndex ?? -1;
    final String? key = index > -1 && index < data.length
        ? data.keys.elementAt(index)
        : null;

    // One tap fires both pan down and tap down, so check reselect on tap up
    if (event is FlPanDownEvent) {
      _keyAtTouchStart = selectedKey;
    }

    if (event is FlTapUpEvent) {
      if (key != null && key == _keyAtTouchStart) {
        widget.onReselect?.call(key);
      }
      return;
    }

    if (!event.isInterestedForInteractions || key == null) return;

    setState(() {
      selectedKey = key;
    });
  }

  PieChartSectionData sectionData(
    ChartData<T> data, {
    required double radius,
    required Color color,
    bool selected = false,
  }) {
    final Color backgroundColor =
        data.colorScheme?.secondary ??
        Color.alphaBlend(color.withAlpha(0x40), context.colorScheme.surface);

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
              percent: data.displayTotal / totalAmount.amount.abs(),
            )
          : null,
      badgePositionPercentageOffset: 0.8,
      borderSide: selected
          ? BorderSide(color: backgroundColor, width: 3.0)
          : null,
    );
  }

  String resolveName(Object? entity) => switch (entity) {
    Category category => category.name,
    Account account => account.name,
    _ => widget.unresolvedDataTitle ?? "-",
  };

  Widget? resolveBadgeWidget(
    Object? entity, {
    Color? color,
    Color? backgroundColor,
    required double percent,
  }) => switch (entity) {
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
      percent: percent,
    ),
  };
}
