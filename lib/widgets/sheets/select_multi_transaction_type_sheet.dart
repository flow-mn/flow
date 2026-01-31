import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// Pops with a list of selected [TransactionType]s.
class SelectMultiTransactionTypeSheet extends StatefulWidget {
  final Iterable<TransactionType>? currentlySelected;

  const SelectMultiTransactionTypeSheet({super.key, this.currentlySelected});

  @override
  State<SelectMultiTransactionTypeSheet> createState() =>
      _SelectMultiTransactionTypeSheetState();
}

class _SelectMultiTransactionTypeSheetState
    extends State<SelectMultiTransactionTypeSheet> {
  late Set<TransactionType> _selectedTypes;

  @override
  void initState() {
    super.initState();
    _selectedTypes = widget.currentlySelected?.toSet() ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      title: Text("enum.TransactionType".t(context)),
      trailing: ModalOverflowBar(
        alignment: .end,
        children: [
          TextButton.icon(
            onPressed: () => context.pop(<TransactionType>[]),
            icon: const Icon(Symbols.block_rounded, fill: 0.0),
            label: Text("transactions.query.clearSelection".t(context)),
          ),
          TextButton.icon(
            onPressed: pop,
            icon: const Icon(Symbols.check_rounded),
            label: Text("general.done".t(context)),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: TransactionType.values
            .map(
              (value) => CheckboxListTile(
                title: Text(value.localizedNameContext(context)),
                value: _selectedTypes.contains(value),
                onChanged: (isSelected) {
                  setState(() {
                    if (isSelected == true) {
                      _selectedTypes.add(value);
                    } else {
                      _selectedTypes.remove(value);
                    }
                  });
                },
              ),
            )
            .toList(),
      ),
    );
  }

  void pop() {
    context.pop(_selectedTypes.toList());
  }
}
