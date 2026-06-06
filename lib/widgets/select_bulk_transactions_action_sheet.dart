import "package:flow/l10n/extensions.dart";
import "package:flow/widgets/general/directional_chevron.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flow/widgets/transactions_selection_controller.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";

enum TransactionsBulkAction {
  confirmAll,
  delete,
  recover,
  changeCategory,
  changeAccount,
}

/// Pops with [TransactionsBulkAction]
class SelectBulkTransactionsActionSheet extends StatelessWidget {
  final TransactionsSelectionController controller;

  const SelectBulkTransactionsActionSheet({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final bool blockMutations = controller.hasAnyTransfer;
    final bool blockAccountForCurrency = controller.currencies.length > 1;

    final String? mutationDisabledHint = blockMutations
        ? "transaction.bulk.disabled.transfers".t(context)
        : null;
    final String? accountDisabledHint =
        mutationDisabledHint ??
        (blockAccountForCurrency
            ? "transaction.bulk.disabled.currencies".t(context)
            : null);

    return ModalSheet.scrollable(
      title: Text(
        "transaction.bulk.selected".t(context, controller.count),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (controller.allPending && controller.count > 0)
              ListTile(
                leading: const Icon(Symbols.check_rounded),
                title: Text("transaction.bulk.confirmAll".t(context)),
                trailing: const LeChevron(),
                onTap: () => context.pop(TransactionsBulkAction.confirmAll),
              ),
            if (controller.allDeleted)
              ListTile(
                leading: const Icon(Symbols.restore_page_rounded),
                title: Text("transaction.bulk.recover".t(context)),
                trailing: const LeChevron(),
                onTap: () => context.pop(TransactionsBulkAction.recover),
              )
            else
              ListTile(
                leading: const Icon(Symbols.delete_forever_rounded),
                title: Text("transaction.bulk.delete".t(context)),
                trailing: const LeChevron(),
                onTap: () => context.pop(TransactionsBulkAction.delete),
              ),
            ListTile(
              leading: const Icon(Symbols.label_rounded),
              title: Text("transaction.bulk.changeCategory".t(context)),
              subtitle: mutationDisabledHint == null
                  ? null
                  : Text(mutationDisabledHint),
              trailing: blockMutations ? null : const LeChevron(),
              enabled: !blockMutations,
              onTap: () => context.pop(TransactionsBulkAction.changeCategory),
            ),
            ListTile(
              leading: const Icon(Symbols.account_balance_wallet_rounded),
              title: Text("transaction.bulk.changeAccount".t(context)),
              subtitle: accountDisabledHint == null
                  ? null
                  : Text(accountDisabledHint),
              trailing: (blockMutations || blockAccountForCurrency)
                  ? null
                  : const LeChevron(),
              enabled: !(blockMutations || blockAccountForCurrency),
              onTap: () => context.pop(TransactionsBulkAction.changeAccount),
            ),
          ],
        ),
      ),
    );
  }
}
