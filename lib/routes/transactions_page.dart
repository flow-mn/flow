import "package:flow/data/flow_icon.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/data/transactions_filter/time_range.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/transitive.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/transactions.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/general/wavy_divider.dart";
import "package:flow/widgets/grouped_transactions_list_view.dart";
import "package:flow/widgets/rates_missing_error_box.dart";
import "package:flow/widgets/time_range_selector.dart";
import "package:flow/widgets/transactions_date_header.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

/// Generic transactions page that can be used to display list of transactions
///
/// This view does not respect [UserPreferences.combineTransfers] since it may
/// be used to show transactions of specific account, and there will be
/// scenarios where the other half of the transfer transaction is wouldn't be
/// shown.
class TransactionsPage extends StatefulWidget {
  final QueryBuilder<Transaction> Function(TimeRange range) queryFn;
  final TimeRange? initialRange;
  final String? title;

  const TransactionsPage({
    super.key,
    required this.queryFn,
    this.initialRange,
    this.title,
  });

  factory TransactionsPage.account({
    Key? key,
    required int accountId,
    String? title,
    Widget? header,
  }) {
    QueryBuilder<Transaction> queryBuilder(TimeRange? range) {
      Condition<Transaction> condition = Transaction_.account.equals(accountId);

      if (range != null) {
        condition = condition.and(
          Transaction_.transactionDate.betweenDate(range.from, range.to),
        );
      }

      return ObjectBox()
          .box<Transaction>()
          .query(condition)
          .order(Transaction_.transactionDate, flags: Order.descending);
    }

    return TransactionsPage(queryFn: queryBuilder, key: key, title: title);
  }

  factory TransactionsPage.all({Key? key, String? title, Widget? header}) {
    QueryBuilder<Transaction> queryBuilder(TimeRange range) =>
        TransactionFilter(
          sortBy: TransactionSortField.transactionDate,
          sortDescending: true,
          range: TransactionFilterTimeRange.fromTimeRange(range),
        ).queryBuilder();

    return TransactionsPage(queryFn: queryBuilder, key: key, title: title);
  }

  factory TransactionsPage.pending({
    Key? key,
    DateTime? anchor,
    String? title,
    Widget? header,
  }) {
    QueryBuilder<Transaction> queryBuilder(TimeRange range) =>
        TransactionsService().pendingTransactionsQb(
          anchor: anchor,
          range: range,
        );

    return TransactionsPage(queryFn: queryBuilder, key: key, title: title);
  }

  factory TransactionsPage.deleted({
    Key? key,
    DateTime? anchor,
    String? title,
    Widget? header,
  }) {
    QueryBuilder<Transaction> queryBuilder(TimeRange? range) =>
        TransactionsService().deletedTransactionsQb(range: range);

    return TransactionsPage(queryFn: queryBuilder, key: key, title: title);
  }

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  static TimeRange get defaultTimeRange => TimeRange.thisMonth();

  late TimeRange _timeRange;

  late final bool showExchangeRatesMissingWarning;

  @override
  void initState() {
    super.initState();
    _timeRange = widget.initialRange ?? defaultTimeRange;
    showExchangeRatesMissingWarning =
        TransitiveLocalPreferences().usesNonPrimaryCurrency.get() &&
        ExchangeRatesService().getPrimaryCurrencyRates() == null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: widget.title == null ? null : Text(widget.title!)),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            PinnedHeaderSliver(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showExchangeRatesMissingWarning) RatesMissingErrorBox(),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Frame(
                      child: TimeRangeSelector(
                        initialValue: _timeRange,
                        onChanged: (newRange) {
                          setState(() {
                            _timeRange = newRange;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverFillRemaining(
              child: StreamBuilder<List<Transaction>>(
                stream: widget
                    .queryFn(_timeRange)
                    .watch(triggerImmediately: true)
                    .map((event) => event.find()),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Spinner.center();
                  }

                  if (snapshot.requireData.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "transactions.query.noResult".t(context),
                              textAlign: TextAlign.center,
                              style: context.textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8.0),
                            FlowIcon(
                              FlowIconData.icon(Symbols.family_star_rounded),
                              size: 128.0,
                              color: context.colorScheme.primary,
                            ),
                            const SizedBox(height: 8.0),
                          ],
                        ),
                      ),
                    );
                  }

                  final DateTime now = DateTime.now().startOfNextMinute();

                  final Map<TimeRange, List<Transaction>> transactions =
                      snapshot.requireData
                          .where(
                            (transaction) =>
                                !transaction.transactionDate.isAfter(now) &&
                                transaction.isPending != true,
                          )
                          .groupByDate();
                  final Map<TimeRange, List<Transaction>> pendingTransactions =
                      snapshot.requireData
                          .where(
                            (transaction) =>
                                transaction.transactionDate.isAfter(now) ||
                                transaction.isPending == true,
                          )
                          .groupByDate();

                  final int totalTransactionsCount =
                      transactions.values.fold<int>(
                        0,
                        (previousValue, element) =>
                            /// Since the [GroupedTransactionList] below isn't able to combine
                            /// transfer transactions, we need to count them separately.
                            previousValue + element.length,
                      ) +
                      pendingTransactions.values.fold<int>(
                        0,
                        (previousValue, element) =>
                            /// Since the [GroupedTransactionList] below isn't able to combine
                            /// transfer transactions, we need to count them separately.
                            previousValue + element.length,
                      );

                  return GroupedTransactionsListView(
                    transactions: transactions,
                    pendingTransactions: pendingTransactions,
                    headerBuilder: (pendingGroup, range, transactions) =>
                        TransactionListDateHeader(
                          pendingGroup: pendingGroup,
                          range: range,
                          transactions: transactions,
                        ),
                    pendingDivider: WavyDivider(),
                    mainHeader: Frame(
                      child: Text(
                        "transactions.count".t(context, totalTransactionsCount),
                        style: context.textTheme.bodyMedium?.semi(context),
                      ),
                    ),
                    mainHeaderPadding: EdgeInsets.zero,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
