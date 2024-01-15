import 'package:flow/entity/transaction.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/l10n/named_enum.dart';
import 'package:flow/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:pie_menu/pie_menu.dart';

class NewTransactionButton extends StatelessWidget {
  final Function(TransactionType type) onActionTap;

  const NewTransactionButton({super.key, required this.onActionTap});

  @override
  Widget build(BuildContext context) {
    return PieMenu(
      onPressed: () => onActionTap(TransactionType.expense),
      actions: [
        PieAction(
          tooltip: Text(TransactionType.transfer.localizedNameContext(context)),
          onSelect: () => onActionTap(TransactionType.transfer),
          child: const Icon(Symbols.compare_arrows_rounded),
        ),
        PieAction(
          tooltip: Text(TransactionType.income.localizedNameContext(context)),
          onSelect: () => onActionTap(TransactionType.income),
          child: const Icon(Symbols.stat_2_rounded),
        ),
        PieAction(
          tooltip: Text(TransactionType.expense.localizedNameContext(context)),
          onSelect: () => onActionTap(TransactionType.expense),
          child: const Icon(Symbols.stat_minus_2_rounded),
        ),
      ],
      child: Tooltip(
        message: "transaction.new".t(context),
        child: Material(
          color: context.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Icon(
              Symbols.add_rounded,
              fill: 0.0,
              color: context.colorScheme.background,
            ),
          ),
        ),
      ),
    );

    // return Tooltip(
    //   message: "transaction.new".t(context),
    //   child: Material(
    //     color: context.colorScheme.primary,
    //     shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.circular(32.0),
    //     ),
    //     child: InkWell(
    //       onTap: () => onActionTap(),
    //       borderRadius: BorderRadius.circular(32.0),
    //       child: Padding(
    //         padding: const EdgeInsets.all(20.0),
    //         child: Icon(
    //           Symbols.add_rounded,
    //           fill: 0.0,
    //           color: context.colorScheme.background,
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
