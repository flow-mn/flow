import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/providers/accounts_provider.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/select_bulk_transactions_action_sheet.dart";
import "package:flow/widgets/sheets/select_account_sheet.dart";
import "package:flow/widgets/sheets/select_category_sheet.dart";
import "package:flow/widgets/transactions_selection_bar.dart";
import "package:flow/widgets/transactions_selection_controller.dart";
import "package:flutter/material.dart";

/// Wraps [child] with the bulk-selection bottom bar, action picker, and
/// `PopScope` exit handling. Pages own the [controller] and feed the
/// currently visible transactions; everything else is handled here.
class TransactionsSelectionScope extends StatefulWidget {
  final TransactionsSelectionController controller;
  final List<Transaction> visibleTransactions;
  final Widget child;

  const TransactionsSelectionScope({
    super.key,
    required this.controller,
    required this.visibleTransactions,
    required this.child,
  });

  @override
  State<TransactionsSelectionScope> createState() =>
      _TransactionsSelectionScopeState();
}

class _TransactionsSelectionScopeState
    extends State<TransactionsSelectionScope> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onSelectionChanged);
  }

  @override
  void didUpdateWidget(covariant TransactionsSelectionScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onSelectionChanged);
      widget.controller.addListener(_onSelectionChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSelectionChanged);
    super.dispose();
  }

  void _onSelectionChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Deferred to post-frame: recomputeFromVisible may notifyListeners.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.controller.recomputeFromVisible(widget.visibleTransactions);
    });

    final bool active = widget.controller.active;
    final double barInset = active
        ? MediaQuery.viewPaddingOf(context).bottom + _kBarContentHeight
        : 0.0;

    return PopScope(
      canPop: !active,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && active) widget.controller.clear();
      },
      child: Stack(
        children: [
          MediaQuery.removePadding(
            context: context,
            removeBottom: active,
            child: Padding(
              padding: EdgeInsets.only(bottom: barInset),
              child: widget.child,
            ),
          ),
          if (active)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: TransactionsSelectionBottomBar(
                controller: widget.controller,
                onClose: widget.controller.clear,
                onNext: _onNext,
                onSelectAll: () =>
                    widget.controller.addAll(widget.visibleTransactions),
              ),
            ),
        ],
      ),
    );
  }

  static const double _kBarContentHeight = 64.0;

  List<Transaction> _selectedFromVisible() {
    final Set<String> uuids = widget.controller.selectedUuids;
    return widget.visibleTransactions
        .where((t) => uuids.contains(t.uuid))
        .toList();
  }

  Future<void> _onNext() async {
    final TransactionsBulkAction? action =
        await showModalBottomSheet<TransactionsBulkAction>(
          context: context,
          isScrollControlled: true,
          builder: (context) => SelectBulkTransactionsActionSheet(
            controller: widget.controller,
          ),
        );
    if (action == null || !mounted) return;
    switch (action) {
      case TransactionsBulkAction.confirmAll:
        await _bulkConfirm();
      case TransactionsBulkAction.delete:
        await _bulkDelete();
      case TransactionsBulkAction.recover:
        await _bulkRecover();
      case TransactionsBulkAction.changeCategory:
        await _bulkChangeCategory();
      case TransactionsBulkAction.changeAccount:
        await _bulkChangeAccount();
    }
  }

  Future<bool> _confirmIfBulk(
    int count,
    String titleKey, {
    bool isDestructive = false,
  }) async {
    if (count <= 1) return true;
    final bool? ok = await context.showConfirmationSheet(
      title: titleKey.t(context, count),
      isDeletionConfirmation: isDestructive,
    );
    return ok == true;
  }

  Future<void> _bulkConfirm() async {
    final List<Transaction> selected = _selectedFromVisible();
    if (selected.isEmpty || !widget.controller.allPending) return;
    if (!await _confirmIfBulk(
      selected.length,
      "transaction.bulk.confirmAll.confirm",
    )) {
      return;
    }
    final bool updateDate = LocalPreferences()
        .pendingTransactions
        .updateDateUponConfirmation
        .get();
    final int count = BulkTransactions.confirm(
      selected,
      updateTransactionDate: updateDate,
    );
    widget.controller.clear();
    if (!mounted) return;
    context.showToast(
      text: "transaction.bulk.confirmed.success".t(context, count),
    );
  }

  Future<void> _bulkDelete() async {
    final List<Transaction> selected = _selectedFromVisible();
    if (selected.isEmpty) return;
    if (!await _confirmIfBulk(
      selected.length,
      "transaction.bulk.delete.confirm",
      isDestructive: true,
    )) {
      return;
    }
    final int count = BulkTransactions.moveToTrashBin(selected);
    widget.controller.clear();
    if (!mounted) return;
    context.showToast(
      text: "transaction.bulk.deleted.success".t(context, count),
    );
  }

  Future<void> _bulkRecover() async {
    final List<Transaction> selected = _selectedFromVisible();
    if (selected.isEmpty) return;
    if (!await _confirmIfBulk(
      selected.length,
      "transaction.bulk.recover.confirm",
    )) {
      return;
    }
    final int count = BulkTransactions.recoverFromTrashBin(selected);
    widget.controller.clear();
    if (!mounted) return;
    context.showToast(
      text: "transaction.bulk.recovered.success".t(context, count),
    );
  }

  Future<void> _bulkChangeCategory() async {
    final List<Transaction> selected = _selectedFromVisible();
    if (selected.isEmpty || widget.controller.hasAnyTransfer) return;

    final Optional<Category>? result = await showModalBottomSheet<
      Optional<Category>
    >(
      context: context,
      builder: (context) => const SelectCategorySheet(),
      isScrollControlled: true,
    );
    if (result == null || !mounted) return;
    if (!await _confirmIfBulk(
      selected.length,
      "transaction.bulk.changeCategory.confirm",
    )) {
      return;
    }

    final int count = BulkTransactions.setCategory(selected, result.value);
    widget.controller.clear();
    if (!mounted) return;
    context.showToast(
      text: "transaction.bulk.updated.success".t(context, count),
    );
  }

  Future<void> _bulkChangeAccount() async {
    final List<Transaction> selected = _selectedFromVisible();
    if (selected.isEmpty ||
        widget.controller.hasAnyTransfer ||
        widget.controller.currencies.length != 1) {
      return;
    }

    final String currency = widget.controller.currencies.first;
    final List<Account> candidates = AccountsProvider.of(context)
        .activeAccounts
        .where((a) => a.currency == currency)
        .toList();

    final Account? result = await showModalBottomSheet<Account>(
      context: context,
      builder: (context) => SelectAccountSheet(accounts: candidates),
      isScrollControlled: true,
    );
    if (result == null || !mounted) return;
    if (!await _confirmIfBulk(
      selected.length,
      "transaction.bulk.changeAccount.confirm",
    )) {
      return;
    }

    final int count = BulkTransactions.setAccount(selected, result);
    widget.controller.clear();
    if (!mounted) return;
    context.showToast(
      text: "transaction.bulk.updated.success".t(context, count),
    );
  }
}
