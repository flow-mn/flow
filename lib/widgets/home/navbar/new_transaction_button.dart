import 'package:flow/entity/transaction.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/l10n/named_enum.dart';
import 'package:flow/main.dart';
import 'package:flow/theme/navbar_theme.dart';
import 'package:flow/theme/theme.dart';
import 'package:flutter/material.dart' hide Flow;
import 'package:material_symbols_icons/symbols.dart';
import 'package:pie_menu/pie_menu.dart';

class NewTransactionButton extends StatefulWidget {
  final Function(TransactionType type) onActionTap;

  const NewTransactionButton({super.key, required this.onActionTap});

  @override
  State<NewTransactionButton> createState() => _NewTransactionButtonState();
}

class _NewTransactionButtonState extends State<NewTransactionButton> {
  double _buttonRotationTurns = 0.0;

  @override
  Widget build(BuildContext context) {
    final NavbarTheme navbarTheme = Theme.of(context).extension<NavbarTheme>()!;

    return PieMenu(
      theme: Flow.of(context).pieTheme.copyWith(
            customAngle: 90.0,
            customAngleDiff: 48.0,
            radius: 108.0,
            customAngleAnchor: PieAnchor.center,
            leftClickShowsMenu: true,
            rightClickShowsMenu: true,
            delayDuration: Duration.zero,
          ),
      onToggle: onToggle,
      actions: [
        PieAction(
          tooltip: Text(TransactionType.transfer.localizedNameContext(context)),
          onSelect: () => widget.onActionTap(TransactionType.transfer),
          child: const Icon(
            Symbols.compare_arrows_rounded,
            weight: 800.0,
          ),
          buttonTheme: PieButtonTheme(
            backgroundColor: context.colorScheme.secondary,
            iconColor: context.colorScheme.onSecondary,
          ),
        ),
        PieAction(
          tooltip: Text(TransactionType.income.localizedNameContext(context)),
          onSelect: () => widget.onActionTap(TransactionType.income),
          child: const Icon(
            Symbols.stat_2_rounded,
            weight: 800.0,
          ),
          buttonTheme: PieButtonTheme(
            backgroundColor: context.flowColors.income,
            iconColor: context.colorScheme.onError,
          ),
        ),
        PieAction(
          tooltip: Text(TransactionType.expense.localizedNameContext(context)),
          onSelect: () => widget.onActionTap(TransactionType.expense),
          child: const Icon(
            Symbols.stat_minus_2_rounded,
            weight: 800.0,
          ),
          buttonTheme: PieButtonTheme(
            backgroundColor: context.flowColors.expense,
            iconColor: context.colorScheme.onError,
          ),
        ),
      ],
      child: StatefulBuilder(
        builder: (context, setState) => Tooltip(
          message: "transaction.new".t(context),
          child: Material(
            color: navbarTheme.transactionButtonBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: AnimatedRotation(
                turns: _buttonRotationTurns,
                duration: const Duration(milliseconds: 600),
                child: Icon(
                  Symbols.add_rounded,
                  fill: 0.0,
                  color: navbarTheme.transactionButtonForegroundColor,
                  weight: 600.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onToggle(bool toggled) {
    _buttonRotationTurns = toggled ? 0.125 : 0.25;
    setState(() {});
  }
}
