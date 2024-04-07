import 'package:flow/data/money_flow.dart';
import 'package:flow/entity/category.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/actions.dart';
import 'package:flow/routes/error_page.dart';
import 'package:flow/widgets/general/flow_icon.dart';
import 'package:flow/widgets/time_range_selector.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:moment_dart/moment_dart.dart';

class CategoryPage extends StatefulWidget {
  final int categoryId;
  final TimeRange? initialRange;

  const CategoryPage({super.key, required this.categoryId, this.initialRange});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late Category? category;

  late TimeRange range;

  @override
  void initState() {
    super.initState();

    category = ObjectBox().box<Category>().get(widget.categoryId);
    range = widget.initialRange ?? TimeRange.thisMonth();
  }

  @override
  Widget build(BuildContext context) {
    if (this.category == null) return const ErrorPage();

    final Category category = this.category!;

    final MoneyFlow flow = category.transactions
        .where((x) => range.contains(x.transactionDate))
        .flow;

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        actions: [
          IconButton(
            icon: const Icon(Symbols.edit_rounded),
            onPressed: () => edit(),
            tooltip: "general.edit".t(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: FlowIcon(
                  category.icon,
                  size: 60.0,
                  plated: true,
                ),
              ),
              TimeRangeSelector(
                initialValue: range,
                onChanged: (value) => setState(() => range = value),
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
              //   child: Text.rich(
              //     TextSpan(
              //       children: [
              //         TextSpan(
              //           text: flowThisMonth.flow.money,
              //         ),
              //         const TextSpan(text: " "),
              //         TextSpan(
              //           text:
              //               "(${"tabs.stats.timeRange.thisMonth".t(context)})",
              //         ),
              //       ],
              //     ),
              //     style: context.textTheme.bodyLarge,
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> edit() async {
    await context.push("/category/${category!.id}/edit");

    category = ObjectBox().box<Category>().get(widget.categoryId);

    if (mounted) {
      setState(() {});
    }
  }
}
