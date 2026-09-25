import "package:flow/data/chart_data.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/utils/extensions/chart_data.dart";
import "package:flow/widgets/home/stats/group_list_tile.dart";
import "package:flow/widgets/home/stats/group_summary_card.dart";
import "package:flow/widgets/home/stats/no_data.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:moment_dart/moment_dart.dart";

class GroupListView extends StatelessWidget {
  /// Expected to be sorted by amount, descending
  final Map<String, ChartData> data;
  final TimeRange range;
  final TransactionType type;
  final bool byCategory;
  final void Function() changeMode;

  const GroupListView({
    super.key,
    required this.data,
    required this.range,
    required this.type,
    required this.byCategory,
    required this.changeMode,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return NoData(selectTimeRange: changeMode);
    }

    final Map<String, Color> colors = data.resolveColors(context);
    final double total = data.displayTotal;
    final double maxAmount = data.values.first.displayTotal;

    final List<ChartData> sorted = data.values.toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: GroupSummaryCard(
            data: data,
            colors: colors,
            type: type,
            byCategory: byCategory,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 96.0),
          sliver: SliverList.builder(
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final ChartData chartData = sorted[index];

              return GroupListTile(
                chartData: chartData,
                percent: total > 0 ? chartData.displayTotal / total * 100 : 0,
                barFactor: maxAmount > 0
                    ? chartData.displayTotal / maxAmount
                    : 0,
                color: colors[chartData.key]!,
                onTap: () => _onTap(context, chartData.associatedData),
              );
            },
          ),
        ),
      ],
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
