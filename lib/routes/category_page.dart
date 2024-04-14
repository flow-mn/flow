import 'dart:developer';

import 'package:flow/data/money_flow.dart';
import 'package:flow/entity/category.dart';
import 'package:flow/entity/transaction.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/actions.dart';
import 'package:flow/objectbox/objectbox.g.dart';
import 'package:flow/routes/error_page.dart';
import 'package:flow/widgets/category/transactions_info.dart';
import 'package:flow/widgets/flow_card.dart';
import 'package:flow/widgets/general/spinner.dart';
import 'package:flow/widgets/grouped_transaction_list.dart';
import 'package:flow/widgets/home/transactions_date_header.dart';
import 'package:flow/widgets/no_result.dart';
import 'package:flow/widgets/time_range_selector.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:moment_dart/moment_dart.dart';

class CategoryPage extends StatefulWidget {
  static const EdgeInsets _defaultHeaderPadding = EdgeInsets.fromLTRB(
    16.0,
    16.0,
    16.0,
    8.0,
  );

  final int categoryId;
  final TimeRange? initialRange;

  final EdgeInsets headerPadding;
  final EdgeInsets listPadding;

  const CategoryPage({
    super.key,
    required this.categoryId,
    this.initialRange,
    this.listPadding = const EdgeInsets.symmetric(vertical: 16.0),
    this.headerPadding = _defaultHeaderPadding,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  bool busy = false;

  List<Transaction>? transactions;

  late Category? category;

  late TimeRange range;

  @override
  void initState() {
    super.initState();

    category = ObjectBox().box<Category>().get(widget.categoryId);
    range = widget.initialRange ?? TimeRange.thisMonth();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    if (this.category == null) return const ErrorPage();

    final bool noTransactions = (transactions?.length ?? 0) == 0;

    final Category category = this.category!;

    final MoneyFlow flow = transactions?.flow ?? MoneyFlow();

    const double firstHeaderTopPadding = 0.0;

    final Widget header = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TimeRangeSelector(
          initialValue: range,
          onChanged: onRangeChange,
        ),
        const SizedBox(height: 8.0),
        TransactionsInfo(
          count: transactions?.length,
          flow: flow.flow,
          icon: category.icon,
        ),
        const SizedBox(height: 12.0),
        Row(
          children: [
            Expanded(
              child: FlowCard(
                flow: flow.totalIncome,
                type: TransactionType.income,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: FlowCard(
                flow: flow.totalExpense,
                type: TransactionType.expense,
              ),
            ),
          ],
        ),
      ],
    );

    final EdgeInsets headerPaddingOutOfList = widget.headerPadding +
        widget.listPadding.copyWith(bottom: 0, top: 0) +
        const EdgeInsets.only(top: firstHeaderTopPadding);

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
        child: switch (busy) {
          true => Padding(
              padding: headerPaddingOutOfList,
              child: Column(
                children: [
                  header,
                  const Expanded(child: Spinner.center()),
                ],
              ),
            ),
          false when noTransactions => Padding(
              padding: headerPaddingOutOfList,
              child: Column(
                children: [
                  header,
                  const Expanded(child: NoResult()),
                ],
              ),
            ),
          _ => GroupedTransactionList(
              header: header,
              transactions: transactions?.groupByDate() ?? {},
              listPadding: widget.listPadding,
              headerPadding: widget.headerPadding,
              firstHeaderTopPadding: firstHeaderTopPadding,
              headerBuilder: (range, rangeTransactions) =>
                  TransactionListDateHeader(
                transactions: rangeTransactions,
                date: range.from,
              ),
            )
        },
      ),
    );
  }

  Future<void> fetch() async {
    if (busy) return;

    setState(() {
      busy = true;
    });

    final Query<Transaction> transactionsQuery = ObjectBox()
        .box<Transaction>()
        .query(
          Transaction_.category.equals(category!.id).and(
                Transaction_.transactionDate.betweenDate(
                  range.from,
                  range.to,
                ),
              ),
        )
        .order(Transaction_.transactionDate, flags: Order.descending)
        .build();

    try {
      transactions = await transactionsQuery.findAsync();
    } catch (e) {
      transactions = [];
      log("Error fetching transactions: $e");
    } finally {
      busy = false;
      transactionsQuery.close();
      if (mounted) {
        setState(() {});
      }
    }
  }

  void onRangeChange(TimeRange newRange) {
    range = newRange;
    fetch();
  }

  Future<void> edit() async {
    await context.push("/category/${category!.id}/edit");

    category = ObjectBox().box<Category>().get(widget.categoryId);

    if (mounted) {
      setState(() {});
    }
  }
}
