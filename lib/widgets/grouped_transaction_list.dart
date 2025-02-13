import "package:flow/data/transaction_filter.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/widgets/transaction_list_tile.dart";
import "package:flutter/material.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:moment_dart/moment_dart.dart";

class GroupedTransactionList extends StatefulWidget {
  final EdgeInsets listPadding;
  final EdgeInsets itemPadding;

  /// When null, same as [itemPadding]
  final EdgeInsets? headerPadding;

  /// Top padding for the first header
  final double firstHeaderTopPadding;

  /// Rendered in order.
  final Map<TimeRange, List<Transaction>> transactions;

  /// Rendered in order.
  final Map<TimeRange, List<Transaction>>? pendingTransactions;

  final Widget Function(
    bool pendingGroup,
    TimeRange range,
    List<Transaction> transactions,
  ) headerBuilder;

  /// Divider to displayed between future/past transactions. How it's divided
  /// is based on [anchor]
  final Widget? pendingDivider;

  /// A widget rendered after all pending transactions
  final Widget? pendingTrailing;

  /// Used to determine which transactions are considered future or past.
  ///
  /// For now, only [pendingDivider] makes use of this
  final DateTime? anchor;

  /// When set to true, displays one side of transfer transactions as empty [Container]s
  final bool shouldCombineTransferIfNeeded;

  final ScrollController? controller;

  final Widget? header;

  final TransactionGroupRange? groupBy;

  /// Set this to [true] to make it always unobscured
  ///
  /// Set this to [false] to make it always obscured
  ///
  /// Set this to [null] to use the default behavior
  final bool? overrideObscure;

  final bool? sliver;

  const GroupedTransactionList({
    super.key,
    required this.transactions,
    required this.headerBuilder,
    this.pendingTransactions,
    this.controller,
    this.header,
    this.pendingDivider,
    this.pendingTrailing,
    this.anchor,
    this.headerPadding,
    this.groupBy,
    this.listPadding = const EdgeInsets.symmetric(vertical: 16.0),
    this.itemPadding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 4.0,
    ),
    this.firstHeaderTopPadding = 8.0,
    this.shouldCombineTransferIfNeeded = false,
    this.overrideObscure,
    this.sliver = false,
  });

  @override
  State<GroupedTransactionList> createState() => _GroupedTransactionListState();
}

class _GroupedTransactionListState extends State<GroupedTransactionList> {
  late bool globalPrivacyMode;

  Widget? get header => widget.header;

  @override
  void initState() {
    super.initState();

    globalPrivacyMode = TransitiveLocalPreferences().sessionPrivacyMode.get();
    TransitiveLocalPreferences()
        .sessionPrivacyMode
        .addListener(_privacyModeUpdate);
  }

  @override
  void dispose() {
    TransitiveLocalPreferences()
        .sessionPrivacyMode
        .removeListener(_privacyModeUpdate);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool combineTransfers = widget.shouldCombineTransferIfNeeded &&
        LocalPreferences().combineTransferTransactions.get();

    final List<Object> flattened = [
      if (header != null) header!,
      if (widget.pendingTransactions != null)
        for (final entry in widget.pendingTransactions!.entries) ...[
          widget.headerBuilder(true, entry.key, entry.value),
          ...entry.value,
        ],
      if (widget.pendingTrailing != null) widget.pendingTrailing!,
      if (widget.pendingDivider != null &&
          widget.pendingTransactions?.isNotEmpty == true &&
          widget.transactions.isNotEmpty)
        widget.pendingDivider!,
      for (final entry in widget.transactions.entries) ...[
        widget.headerBuilder(false, entry.key, entry.value),
        ...entry.value,
      ],
    ];

    final EdgeInsets headerPadding = widget.headerPadding ?? widget.itemPadding;

    Widget itemBuilder(BuildContext context, int index) =>
        switch (flattened[index]) {
          (Padding widgetWithPadding) => widgetWithPadding,
          (Widget header) => Padding(
              padding: headerPadding.copyWith(
                top: index == 0
                    ? widget.firstHeaderTopPadding
                    : headerPadding.top,
              ),
              child: header,
            ),
          (Transaction transaction) => TransactionListTile(
              combineTransfers: combineTransfers,
              transaction: transaction,
              padding: widget.itemPadding,
              dismissibleKey: ValueKey(transaction.id),
              moveToTrashFn: () => transaction.moveToTrashBin(),
              recoverFromTrashFn: () => transaction.recoverFromTrashBin(),
              confirmFn: ([bool confirm = true]) {
                final bool updateTransactionDate = LocalPreferences()
                    .pendingTransactions
                    .updateDateUponConfirmation
                    .get();

                transaction.confirm(confirm, updateTransactionDate);
              },
              duplicateFn: () => transaction.duplicate(),
              overrideObscure: widget.overrideObscure,
              groupRange: widget.groupBy,
            ),
          (_) => Container(),
        };

    if (widget.sliver == true) {
      return SlidableAutoCloseBehavior(
        child: SliverList.builder(
          itemBuilder: itemBuilder,
          itemCount: flattened.length,
        ),
      );
    }

    return SlidableAutoCloseBehavior(
      child: ListView.builder(
        controller: widget.controller,
        padding: widget.listPadding,
        itemBuilder: itemBuilder,
        itemCount: flattened.length,
      ),
    );
  }

  _privacyModeUpdate() {
    globalPrivacyMode = TransitiveLocalPreferences().sessionPrivacyMode.get();
    if (!mounted) return;
    setState(() {});
  }
}
