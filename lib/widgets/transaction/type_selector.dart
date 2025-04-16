import "package:flow/entity/transaction.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class TypeSelector extends StatelessWidget {
  final TransactionType current;

  final bool canEdit;

  final Function(TransactionType) onChange;

  const TypeSelector({
    super.key,
    required this.current,
    required this.onChange,
    this.canEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!canEdit) return Text(current.localizedNameContext(context));

    return DropdownButton<TransactionType>(
      style: context.textTheme.titleSmall,
      underline: Container(),
      icon: const Icon(Symbols.arrow_drop_down_rounded),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      borderRadius: BorderRadius.circular(8.0),
      value: current,
      items:
          TransactionType.values
              .map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.localizedNameContext(context)),
                ),
              )
              .toList(),
      onChanged: (TransactionType? value) {
        if (value == null) return;

        onChange(value);
      },
    );
  }
}
