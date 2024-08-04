import 'package:flow/data/money_flow.dart';
import 'package:flow/entity/category.dart';
import 'package:flow/entity/transaction.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/widgets/home/stats/group_pie_chart.dart';
import 'package:flow/widgets/home/stats/no_data.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moment_dart/moment_dart.dart';

class PieGraphView extends StatelessWidget {
  final Map<String, MoneyFlow> data;
  final TimeRange range;
  final void Function() changeMode;
  final TransactionType type;

  const PieGraphView({
    super.key,
    required this.data,
    required this.range,
    required this.changeMode,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return NoData(
        onTap: changeMode,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 96.0, top: 8.0),
      child: GroupPieChart(
        type: type,
        data: data,
        unresolvedDataTitle: "category.none".t(context),
        onReselect: (key) {
          if (!data.containsKey(key)) return;

          final associatedData = data[key]!.associatedData;

          if (associatedData is Category) {
            context.push(
                "/category/${associatedData.id}?range=${Uri.encodeQueryComponent(range.toString())}");
          }
        },
      ),
    );
  }
}
