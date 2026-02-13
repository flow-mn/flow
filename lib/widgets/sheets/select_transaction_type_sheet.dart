import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/widgets/general/directional_chevron.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class SelectTransactionTypeSheet extends StatelessWidget {
  final TransactionType? currentlySelected;

  const SelectTransactionTypeSheet({super.key, this.currentlySelected});

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      title: Text("enum.TransactionType".t(context)),
      trailing: ModalOverflowBar(
        alignment: .end,
        children: [
          TextButton.icon(
            onPressed: () => context.pop(null),
            icon: const Icon(Symbols.close_rounded),
            label: Text("general.cancel".t(context)),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: TransactionType.values
            .map(
              (value) => ListTile(
                title: Text(value.localizedNameContext(context)),
                selected: currentlySelected == value,
                trailing: const LeChevron(),
                onTap: () => context.pop(value),
              ),
            )
            .toList(),
      ),
    );
  }
}
