import "dart:async";

import "package:flow/data/exchange_rates.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/data/transactions_filter/time_range.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction_filter_preset.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/default_transaction_filter_head.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/pending_transactions_header.dart";
import "package:flow/widgets/general/wavy_divider.dart";
import "package:flow/widgets/grouped_transaction_list.dart";
import "package:flow/widgets/home/greetings_bar.dart";
import "package:flow/widgets/home/home/flow_cards.dart";
import "package:flow/widgets/home/home/no_transactions.dart";
import "package:flow/widgets/rates_missing_warning.dart";
import "package:flow/widgets/transactions_date_header.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

class HomeTab extends StatefulWidget {
  final ScrollController? scrollController;

  const HomeTab({super.key, this.scrollController});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  late final AppLifecycleListener _listener;
  late final Timer _timer;

  late int _plannedTransactionsNextNDays;

  late TransactionFilter defaultFilter;
  DateTime dateKey = Moment.startOfToday();

  late TransactionFilter currentFilter;

  TransactionFilter get currentFilterWithPlanned {
    final DateTime plannedTransactionTo = Moment.now()
        .add(Duration(days: _plannedTransactionsNextNDays))
        .startOfNextDay();

    final TimeRange? timeRange = currentFilter.range?.range;

    if (timeRange != null &&
        timeRange.contains(Moment.now()) &&
        !timeRange.contains(plannedTransactionTo)) {
      return currentFilter.copyWithOptional(
        range: Optional(
          TransactionFilterTimeRange.fromTimeRange(
            CustomTimeRange(
              timeRange.from,
              plannedTransactionTo,
            ),
          ),
        ),
      );
    }

    return currentFilter;
  }

  late final bool noTransactionsAtAll;

  @override
  void initState() {
    super.initState();
    _updatePlannedTransactionDays();
    LocalPreferences()
        .pendingTransactions
        .homeTimeframe
        .addListener(_updatePlannedTransactionDays);

    _rawUpdateDefaultFilter();

    currentFilter = defaultFilter.copyWithOptional();

    _listener = AppLifecycleListener(
      onShow: () => refreshDateKeyAndDefaultFilter(),
    );

    _timer = Timer.periodic(
        const Duration(seconds: 30), (_) => refreshDateKeyAndDefaultFilter());
  }

  @override
  void dispose() {
    _listener.dispose();
    LocalPreferences()
        .pendingTransactions
        .homeTimeframe
        .removeListener(_updatePlannedTransactionDays);
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final bool isFilterModified = currentFilter != defaultFilter;

    return StreamBuilder<List<Transaction>>(
      key: ValueKey(dateKey),
      stream: currentFilterWithPlanned
          .queryBuilder()
          .watch(triggerImmediately: true)
          .map(
            (event) =>
                event.find().filter(currentFilterWithPlanned.postPredicates),
          ),
      builder: (context, snapshot) {
        final DateTime now = Moment.now().startOfNextMinute();
        final ExchangeRates? rates =
            ExchangeRatesService().getPrimaryCurrencyRates();
        final List<Transaction>? transactions = snapshot.data;

        final Widget header = DefaultTransactionsFilterHead(
          defaultFilter: defaultFilter,
          current: currentFilter,
          onChanged: (value) {
            setState(() {
              currentFilter = value;
            });
          },
        );

        return CustomScrollView(
          primary: true,
          slivers: [
            PinnedHeaderSliver(
              child: Column(
                children: [
                  const Frame.standalone(
                    withSurface: true,
                    child: GreetingsBar(),
                  ),
                  header,
                ],
              ),
            ),
            switch ((transactions?.length ?? 0, snapshot.hasData)) {
              (0, true) => SliverFillRemaining(
                  child: NoTransactions(isFilterModified: isFilterModified),
                ),
              (_, true) =>
                buildGroupedList(context, now, transactions ?? [], rates),
              (_, false) => const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator /*.adaptive*/ (),
                  ),
                ),
            },
            SliverToBoxAdapter(
              child: const SizedBox(height: 96.0),
            ),
          ],
        );
      },
    );
  }

  Widget buildGroupedList(
    BuildContext context,
    DateTime now,
    List<Transaction> transactions,
    ExchangeRates? rates,
  ) {
    final bool showMissingExchangeRatesWarning = rates == null &&
        TransitiveLocalPreferences().transitiveUsesSingleCurrency.get();

    final Map<TimeRange, List<Transaction>> grouped = transactions
        .where((transaction) =>
            !transaction.transactionDate.isAfter(now) &&
            transaction.isPending != true)
        .groupByRange(rangeFn: currentFilter.groupBy.fromTransaction);

    final List<Transaction> pendingTransactions = transactions
        .where((transaction) =>
            transaction.transactionDate.isAfter(now) ||
            transaction.isPending == true)
        .toList();

    final int actionNeededCount = pendingTransactions
        .where((transaction) => transaction.confirmable())
        .length;

    final Map<TimeRange, List<Transaction>> pendingTransactionsGrouped =
        pendingTransactions.groupByRange(
      rangeFn: (transaction) =>
          CustomTimeRange(Moment.minValue, Moment.maxValue),
    );

    final bool shouldCombineTransferIfNeeded =
        currentFilter.accounts?.isNotEmpty != true;

    return GroupedTransactionList(
      sliver: true,
      header: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12.0),
          FlowCards(
            transactions: transactions,
            rates: rates,
          ),
          if (showMissingExchangeRatesWarning) ...[
            const SizedBox(height: 12.0),
            RatesMissingWarning(),
          ],
        ],
      ),
      controller: widget.scrollController,
      transactions: grouped,
      groupBy: currentFilter.groupBy,
      pendingTransactions: pendingTransactionsGrouped,
      shouldCombineTransferIfNeeded: shouldCombineTransferIfNeeded,
      pendingDivider: const WavyDivider(),
      listPadding: const EdgeInsets.only(
        top: 0,
        bottom: 80.0,
      ),
      headerBuilder: (
        pendingGroup,
        range,
        transactions,
      ) {
        if (pendingGroup) {
          return PendingTransactionsHeader(
            transactions: transactions,
            range: range,
            badgeCount: actionNeededCount,
          );
        }

        return TransactionListDateHeader(
          transactions: transactions,
          range: range,
        );
      },
    );
  }

  void _updatePlannedTransactionDays() {
    _plannedTransactionsNextNDays =
        LocalPreferences().pendingTransactions.homeTimeframe.get() ??
            PendingTransactionsLocalPreferences.homeTimeframeDefault;
    setState(() {});
  }

  void refreshDateKeyAndDefaultFilter() {
    if (!mounted) return;
    _rawUpdateDefaultFilter();
    setState(() {
      dateKey = Moment.startOfToday();
    });
  }

  void _rawUpdateDefaultFilter() {
    defaultFilter = UserPreferencesService()
            .defaultFilterPreset
            ?.filter
            .copyWithOptional() ??
        TransactionFilterPreset.defaultFilter;
  }

  @override
  bool get wantKeepAlive => true;
}
