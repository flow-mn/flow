import "dart:async";

import "package:flow/data/actionable_nofications/actionable_notification.dart";
import "package:flow/data/exchange_rates.dart";
import "package:flow/data/single_currency_flow.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/data/transactions_filter/pending_time_range.dart";
import "package:flow/data/transactions_filter/time_range.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction_filter_preset.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/routes/home_page.dart";
import "package:flow/services/actionable_notifications.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/default_transaction_filter_head.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/money_text_builder.dart";
import "package:flow/widgets/general/pending_transactions_header.dart";
import "package:flow/widgets/general/wavy_divider.dart";
import "package:flow/widgets/grouped_transactions_list_view.dart";
import "package:flow/widgets/home/greetings_bar.dart";
import "package:flow/widgets/home/home/flow_cards.dart";
import "package:flow/widgets/home/home/no_transactions.dart";
import "package:flow/widgets/internal_notifications/internal_notification_section.dart";
import "package:flow/widgets/rates_missing_error_box.dart";
import "package:flow/widgets/transactions_date_header.dart";
import "package:flow/widgets/transactions_selection_controller.dart";
import "package:flow/widgets/transactions_selection_scope.dart";
import "package:flutter/material.dart";
import "package:flutter_slidable/flutter_slidable.dart";
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

  late PendingTimeRange _plannedTransactionsTimeRange;

  late TransactionFilter defaultFilter;
  DateTime dateKey = Moment.startOfToday();

  ActionableNotification? _actionableNotification;

  late TransactionFilter currentFilter;

  TransactionFilter get normalizedCurrentFilter =>
      currentFilter.copyWithOptional(isPending: Optional(null));

  TransactionFilter get pendingTransactionsFilter {
    final TimeRange? timeRange = currentFilter.range?.range;
    final TimeRange plannedTranasctionsTimeRange = _plannedTransactionsTimeRange
        .range(homeTimeRange: timeRange);

    return currentFilter.copyWithOptional(
      range: Optional(
        TransactionFilterTimeRange.fromTimeRange(
          CustomTimeRange(Moment.minValue, plannedTranasctionsTimeRange.to),
        ),
      ),
      isPending: Optional(true),
    );
  }

  late final bool noTransactionsAtAll;

  late final TransactionsSelectionController _selection;

  StreamSubscription<List<Transaction>>? _currentTransactionsSub;
  StreamSubscription<List<Transaction>>? _pendingTransactionsSub;
  List<Transaction>? _currentTransactions;
  List<Transaction>? _pendingTransactions;
  bool _readyToSubscribe = false;

  DateTime _now = Moment.now().startOfNextMinute();
  List<Transaction> _transactions = const [];
  Map<TimeRange, List<Transaction>> _grouped = const {};
  Map<TimeRange, List<Transaction>> _pendingGrouped = const {};
  int _actionNeededCount = 0;
  SingleCurrencyFlow? _combinedFlow;
  ExchangeRates? _combinedFlowRates;

  @override
  void initState() {
    super.initState();
    _selection = TransactionsSelectionController();
    _selection.addListener(_onSelectionChanged);
    _updatePlannedTransactionDays();

    _rawUpdateDefaultFilter();

    currentFilter = defaultFilter.copyWithOptional();

    _listener = AppLifecycleListener(
      onShow: () => refreshDateKeyAndDefaultFilter(),
    );

    _timer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => refreshDateKeyAndDefaultFilter(),
    );

    UserPreferencesService().valueNotifier.addListener(_rawUpdateDefaultFilter);
    UserPreferencesService().valueNotifier.addListener(
      _updatePlannedTransactionDays,
    );
    ActionableNotificationsService().notifications.addListener(
      _updateActionableNotification,
    );
    _updateActionableNotification();

    ExchangeRatesService().getPrimaryCurrencyRates();

    _readyToSubscribe = true;
    _subscribeToTransactions();
  }

  @override
  void dispose() {
    _currentTransactionsSub?.cancel();
    _pendingTransactionsSub?.cancel();
    _selection.removeListener(_onSelectionChanged);
    _selection.dispose();
    _listener.dispose();
    _timer.cancel();
    UserPreferencesService().valueNotifier.removeListener(
      _rawUpdateDefaultFilter,
    );
    UserPreferencesService().valueNotifier.removeListener(
      _updatePlannedTransactionDays,
    );
    ActionableNotificationsService().notifications.removeListener(
      _updateActionableNotification,
    );
    super.dispose();
  }

  /// Resubscribe to ObjectBox transaction streams using the current filter
  /// values. Cheap to call repeatedly; we only re-open queries when filter
  /// values actually changed upstream (e.g. via [onChanged], date rollover,
  /// or planned-range preference). The old StreamBuilders rebuilt and
  /// resubscribed on every frame — this avoids that.
  void _subscribeToTransactions() {
    if (!_readyToSubscribe) return;

    _currentTransactionsSub?.cancel();
    _currentTransactionsSub = normalizedCurrentFilter
        .queryBuilder()
        .watch(triggerImmediately: true)
        .map((event) => event.find())
        .listen((txns) {
          if (!mounted) return;
          setState(() {
            _currentTransactions = txns;
            _recomputeTransactions();
          });
        });

    _pendingTransactionsSub?.cancel();
    _pendingTransactionsSub = pendingTransactionsFilter
        .queryBuilder()
        .watch(triggerImmediately: true)
        .map((event) => event.find())
        .listen((txns) {
          if (!mounted) return;
          setState(() {
            _pendingTransactions = txns;
            _recomputeTransactions();
          });
        });
  }

  /// Kept out of [build], which also runs on every selection tap
  void _recomputeTransactions() {
    final DateTime now = Moment.now().startOfNextMinute();
    _now = now;
    final TransactionFilter normalizedFilter = normalizedCurrentFilter;
    final TimeRange? currentRange = normalizedFilter.range?.range;
    final List<TransactionPredicate> pendingPredicates =
        pendingTransactionsFilter.postPredicates;
    final List<TransactionPredicate> currentPredicates =
        normalizedFilter.postPredicates;

    final List<Transaction> transactions = [
      ...?_pendingTransactions?.where(
        (transaction) =>
            pendingPredicates.every((predicate) => predicate(transaction)) &&
            currentRange?.contains(transaction.transactionDate) != true,
      ),
      ...?_currentTransactions?.where(
        (transaction) =>
            currentPredicates.every((predicate) => predicate(transaction)),
      ),
    ];

    if (currentRange?.contains(now) == true) {
      final TimeRange cutoffPlanned = _plannedTransactionsTimeRange.range(
        homeTimeRange: currentRange,
      );

      transactions.removeWhere((transaction) {
        if (transaction.transactionDate <= now) return false;

        return transaction.transactionDate > cutoffPlanned.to;
      });
    }

    final List<Transaction> pendingTransactions = transactions
        .where(
          (transaction) =>
              transaction.isPending == true ||
              transaction.transactionDate.isAfter(now),
        )
        .toList();

    _transactions = transactions;
    _grouped = transactions
        .where(
          (transaction) =>
              !transaction.transactionDate.isAfter(now) &&
              transaction.isPending != true,
        )
        .groupByRange(rangeFn: currentFilter.groupBy.fromTransaction);
    _pendingGrouped = pendingTransactions.groupByRange(
      rangeFn: (transaction) =>
          CustomTimeRange(Moment.minValue, Moment.maxValue),
    );
    _actionNeededCount = pendingTransactions
        .where((transaction) => transaction.confirmable())
        .length;
    _combinedFlow = null;
  }

  SingleCurrencyFlow _getCombinedFlow(ExchangeRates? rates) {
    if (_combinedFlow case final SingleCurrencyFlow flow
        when identical(rates, _combinedFlowRates)) {
      return flow;
    }

    _combinedFlowRates = rates;
    return _combinedFlow =
        SingleCurrencyFlow(currency: UserPreferencesService().primaryCurrency)
          ..addAll(
            _transactions
                .where((transaction) {
                  if (transaction.isTransfer) return false;
                  if (transaction.transactionDate.isAfter(_now)) return false;
                  if (transaction.isPending == true) return false;
                  return true;
                })
                .map((t) => t.money),
            rates,
          );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final bool isFilterModified = currentFilter != defaultFilter;
    final List<Transaction> transactions = _transactions;
    final bool hasCurrent = _currentTransactions != null;

    final Widget header = DefaultTransactionsFilterHead(
      defaultFilter: defaultFilter,
      current: currentFilter,
      onChanged: (value) {
        setState(() {
          currentFilter = value;
          _recomputeTransactions();
        });
        _subscribeToTransactions();
      },
    );

    return TransactionsSelectionScope(
      controller: _selection,
      visibleTransactions: transactions,
      child: CustomScrollView(
        primary: true,
        slivers: [
          PinnedHeaderSliver(
            child: Container(
              color: context.colorScheme.surface,
              child: SafeArea(
                bottom: false,
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
            ),
          ),
          switch ((transactions.length, hasCurrent)) {
            (0, true) => SliverFillRemaining(
              child: NoTransactions(isFilterModified: isFilterModified),
            ),
            (_, true) => buildGroupedList(context, transactions),
            (_, false) => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
          },
          SliverToBoxAdapter(
            child: SafeArea(child: const SizedBox(height: 96.0)),
          ),
        ],
      ),
    );
  }

  Widget buildGroupedList(
    BuildContext context,
    List<Transaction> transactions,
  ) {
    return ValueListenableBuilder(
      valueListenable: ExchangeRatesService().exchangeRatesCache,
      builder: (context, ratesSet, _) {
        final ExchangeRates? rates = ratesSet?.get(
          UserPreferencesService().primaryCurrency,
        );

        final bool showMissingExchangeRatesWarning =
            rates == null &&
            TransitiveLocalPreferences().usesNonPrimaryCurrency.get();

        final bool shouldCombineTransferIfNeeded =
            currentFilter.accounts == null;

        final SingleCurrencyFlow combinedFlow = _getCombinedFlow(rates);

        return GroupedTransactionsListView(
          listType: GroupedTransactionsListViewType.sliverReorderable,
          selectionController: _selection,
          mainHeader: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TODO @sadespresso show iCloud errors if enabled, and platform is supported
              if (_actionableNotification != null) ...[
                SlidableAutoCloseBehavior(
                  child: ActionableNotificationSection(
                    notification: _actionableNotification!,
                    onDismiss: () => setState(() {
                      _actionableNotification = null;
                    }),
                  ),
                ),
              ],
              if (showMissingExchangeRatesWarning) ...[
                SizedBox(height: 8.0),
                RatesMissingErrorBox(),
              ],
              // TODO @sadespresso want to analyze transactions shown in current
              // view. For example, average amount of transaction, how often this
              // happens, total txn count, etc
              // if (defaultFilter != currentFilter) ...[
              //   Text("transactions.count".t(context, transactions.length)),
              //   const SizedBox(height: 4.0),
              // ],
              SizedBox(height: 8.0),
              FlowCards(
                totalExpense: combinedFlow.totalExpense,
                totalIncome: combinedFlow.totalIncome,
              ),
              SizedBox(height: 8.0),
              Align(
                alignment: AlignmentDirectional.topStart,
                child: MoneyTextBuilder(
                  money: combinedFlow.totalFlow,
                  abbreviate: true,
                  builder: (context, flowText, _) => Text(
                    [
                      flowText,
                      "transactions.count".t(
                        context,
                        transactions.renderableCount,
                      ),
                    ].join(" • "),
                    style: context.textTheme.bodyMedium?.semi(context),
                  ),
                ),
              ),
              SizedBox(height: 4.0),
            ],
          ),
          controller: widget.scrollController,
          transactions: _grouped,
          groupBy: currentFilter.groupBy,
          pendingTransactions: _pendingGrouped,
          shouldCombineTransferIfNeeded: shouldCombineTransferIfNeeded,
          pendingDivider: const WavyDivider(),
          headerBuilder: (pendingGroup, range, transactions) {
            if (pendingGroup) {
              return PendingTransactionsHeader(
                transactions: transactions,
                range: range,
                badgeCount: _actionNeededCount,
              );
            }

            return TransactionListDateHeader(
              transactions: transactions,
              range: range,
            );
          },
        );
      },
    );
  }

  void _updatePlannedTransactionDays() {
    _plannedTransactionsTimeRange =
        UserPreferencesService().homePendingTransactionsTimeRange;
    setState(() {
      if (_readyToSubscribe) _recomputeTransactions();
    });
    _subscribeToTransactions();
  }

  void refreshDateKeyAndDefaultFilter() {
    if (!mounted) return;
    final TransactionFilter oldDefaultFilter = defaultFilter;
    _rawUpdateDefaultFilter();
    final DateTime newDateKey = Moment.startOfToday();
    final DateTime newNow = Moment.now().startOfNextMinute();
    final bool dayChanged = newDateKey != dateKey;

    // Query streams don't depend on `now`, only re-open them on day rollover
    if (!dayChanged &&
        oldDefaultFilter == defaultFilter &&
        !_anyTransactionBetween(_now, newNow)) {
      _now = newNow;
      return;
    }

    setState(() {
      dateKey = newDateKey;
      _recomputeTransactions();
    });
    if (dayChanged) {
      _subscribeToTransactions();
    }
  }

  /// Whether a loaded transaction moved from upcoming to past
  bool _anyTransactionBetween(DateTime from, DateTime to) {
    if (!to.isAfter(from)) return false;

    bool crossed(Transaction transaction) =>
        transaction.transactionDate.isAfter(from) &&
        !transaction.transactionDate.isAfter(to);

    return (_currentTransactions?.any(crossed) ?? false) ||
        (_pendingTransactions?.any(crossed) ?? false);
  }

  void _rawUpdateDefaultFilter() {
    defaultFilter =
        UserPreferencesService().defaultFilterPreset?.filter
            .copyWithOptional() ??
        TransactionFilterPreset.defaultFilter;
  }

  void _updateActionableNotification() {
    if (_actionableNotification != null) return;

    _actionableNotification = ActionableNotificationsService().consume();

    setState(() {});
  }

  void _onSelectionChanged() {
    if (!mounted) return;

    HomePage.of(context).toggleNavVisibility(!_selection.active, 0);

    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;
}
