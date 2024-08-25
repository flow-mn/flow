import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/main.dart";
import "package:flow/prefs.dart";
import "package:flow/theme/navbar_theme.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/material.dart" hide Flow;
import "package:material_symbols_icons/symbols.dart";
import "package:pie_menu/pie_menu.dart";

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

    return ValueListenableBuilder(
        valueListenable:
            LocalPreferences().transactionButtonOrder.valueNotifier,
        builder: (context, buttonOrder, child) {
          buttonOrder ??= TransactionType.values;

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
              for (final transactionType in buttonOrder)
                PieAction(
                  tooltip: Text(transactionType.localizedNameContext(context)),
                  onSelect: () => widget.onActionTap(transactionType),
                  child: Icon(
                    transactionType.icon,
                    weight: 800.0,
                  ),
                  buttonTheme: PieButtonTheme(
                    backgroundColor:
                        transactionType.actionBackgroundColor(context),
                    iconColor: transactionType.actionColor(context),
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
        });
  }

  void onToggle(bool toggled) {
    _buttonRotationTurns = toggled ? 0.125 : 0.25;
    setState(() {});
  }
}
