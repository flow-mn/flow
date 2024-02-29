import 'package:fl_chart/fl_chart.dart';
import 'package:flow/data/money_flow.dart';
import 'package:flow/entity/account.dart';
import 'package:flow/entity/category.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/general/flow_icon.dart';
import 'package:flutter/material.dart';

class GroupPieChart<T> extends StatelessWidget {
  final Map<String, MoneyFlow> flow;
  final Map<String, T> data;

  const GroupPieChart({super.key, required this.flow, required this.data});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 8.0,
        centerSpaceRadius: 48.0,
        startDegreeOffset: -90,
        sections: flow.entries
            .map(
              (e) => PieChartSectionData(
                color: context.colorScheme.secondary,
                radius: 80.0,
                value: e.value.totalExpense.abs(),
                title: resolveName(data[e.key]),
                showTitle: false,
                badgeWidget: resolveBadgeWidget(data[e.key]),
              ),
            )
            .toList(),
      ),
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
        _ => null,
      };
}
