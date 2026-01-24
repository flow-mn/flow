import "package:flow/data/transaction_programmable_object.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction/extensions/default/transfer.dart";
import "package:flow/services/accounts.dart";
import "package:flow/services/categories.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/widgets/transaction_list_tile.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:uuid/uuid.dart";

class TpoPreviewListItem extends StatefulWidget {
  final TransactionProgrammableObject tpo;

  const TpoPreviewListItem({super.key, required this.tpo});

  @override
  State<TpoPreviewListItem> createState() => _TpoPreviewListItemState();
}

class _TpoPreviewListItemState extends State<TpoPreviewListItem> {
  Transaction? estimate;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _estimate();
    });
  }

  @override
  void didUpdateWidget(TpoPreviewListItem oldWidget) {
    if (widget.tpo != oldWidget.tpo) {
      _estimate();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: estimate == null
          ? SizedBox.shrink()
          : TransactionListTile(
              transaction: estimate!,
              recoverFromTrashFn: null,
              moveToTrashFn: null,
              combineTransfers: false,
            ),
    );
  }

  void _estimate() {
    final Account? selectedFromAccount =
        AccountsService().findOneActiveSync(widget.tpo.fromAccountUuid) ??
        AccountsService().findOneActiveSync(widget.tpo.fromAccount);
    final Account? selectedToAccount = widget.tpo.type == .transfer
        ? AccountsService().findOneActiveSync(widget.tpo.toAccountUuid) ??
              AccountsService().findOneActiveSync(widget.tpo.toAccount)
        : null;
    final Category? selectedCategory = widget.tpo.type == .transfer
        ? null
        : (CategoriesService().findOneSync(widget.tpo.categoryUuid) ??
              CategoriesService().findOneSync(widget.tpo.category));

    final Transaction transaction = Transaction(
      title: widget.tpo.title,
      description: widget.tpo.notes,
      amount: widget.tpo.amount?.toDouble() ?? 0.0,
      currency: UserPreferencesService().primaryCurrency,
      isPending: widget.tpo.isPending,
      transactionDate: widget.tpo.transactionDate,
      uuid: const Uuid().v4(),
    );

    if (widget.tpo.type == .transfer) {
      transaction.addExtensions([
        Transfer(
          uuid: const Uuid().v4(),
          fromAccountUuid: selectedFromAccount?.uuid ?? const Uuid().v4(),
          toAccountUuid: selectedToAccount?.uuid ?? const Uuid().v4(),
          relatedTransactionUuid: const Uuid().v4(),
        ),
      ]);
    }

    if (selectedFromAccount != null) {
      transaction.setAccount(selectedFromAccount);
    }
    if (selectedCategory != null) {
      transaction.setCategory(selectedCategory);
    }

    estimate = transaction;

    if (mounted) {
      setState(() {});
    }
  }
}
