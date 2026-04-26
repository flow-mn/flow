import "package:flow/data/chart_data.dart";
import "package:flow/data/money.dart";
import "package:flow/entity/category.dart";
import "package:flow/widgets/home/stats/group_list_tile.dart";
import "package:flow/widgets/home/stats/no_data.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:moment_dart/moment_dart.dart";

class GroupListView extends StatelessWidget {
  final Map<String, ChartData> data;
  final TimeRange range;
  final void Function() changeMode;

  const GroupListView({
    super.key,
    required this.data,
    required this.range,
    required this.changeMode,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return NoData(selectTimeRange: changeMode);
    }

    final Money totalAmount = data.values.fold<Money>(
      Money(0, data.values.first.money.currency),
      (previousValue, element) => previousValue + element.money,
    );

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 96.0, top: 8.0),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final entry = data.entries.elementAt(index);
        final chartData = entry.value;

        final double percent = totalAmount.amount != 0
            ? (chartData.displayTotal / totalAmount.amount.abs()) * 100
            : 0;

        return GroupListTile(
          chartData: chartData,
          percent: percent,
          onTap: () => _onTap(context, chartData.associatedData),
        );
      },
    );
  }

  void _onTap(BuildContext context, Object? entity) {
    if (entity is Category) {
      context.push(
        "/category/${entity.id}?range=${Uri.encodeQueryComponent(range.encodeShort())}",
      );
    }
  }
}
