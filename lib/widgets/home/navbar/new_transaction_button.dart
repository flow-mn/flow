import "package:flow/data/flow_button_type.dart";
import "package:flow/entity/user_preferences.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/services/integrations/eny.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/navbar_theme.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions/directionality.dart";
import "package:flutter/material.dart" hide Flow;
import "package:material_symbols_icons/symbols.dart";
import "package:pie_menu/pie_menu.dart";

class NewTransactionButton extends StatefulWidget {
  final Function(FlowButtonType type) onActionTap;

  const NewTransactionButton({super.key, required this.onActionTap});

  @override
  State<NewTransactionButton> createState() => _NewTransactionButtonState();
}

class _NewTransactionButtonState extends State<NewTransactionButton> {
  double _buttonRotationTurns = 0.0;

  @override
  Widget build(BuildContext context) {
    final NavbarTheme navbarTheme = Theme.of(context).extension<NavbarTheme>()!;

    return AnimatedBuilder(
      animation: Listenable.merge([
        UserPreferencesService().valueNotifier,
        EnyService().apiKey,
      ]),
      builder: (context, _) {
        final UserPreferences userPreferences = UserPreferencesService().value;
        final bool enyConnected = EnyService().apiKey.value?.isNotEmpty == true;

        final List<FlowButtonType> buttonOrder = context.isLtr
            ? userPreferences.transactionButtonOrder
            : userPreferences.transactionButtonOrder.reversed.toList();

        if (!enyConnected) {
          // If Eny is not connected, show only 3 buttons + Eny button
          buttonOrder.removeWhere((type) => type == .eny);
        }

        return PieMenu(
          theme: context.pieTheme.copyWith(
            customAngle: 90.0,
            customAngleDiff: 48.0,
            radius: 108.0,
            customAngleAnchor: PieAnchor.center,
            leftClickShowsMenu: true,
            rightClickShowsMenu: true,
            regularPressShowsMenu: true,
            longPressDuration: Duration.zero,
          ),
          onToggle: onToggle,
          actions: buttonOrder
              .map(
                (transactionType) => PieAction(
                  tooltip: Text(transactionType.localizedNameContext(context)),
                  onSelect: () => widget.onActionTap(transactionType),
                  child: Icon(transactionType.icon, weight: 800.0),
                  buttonTheme: PieButtonTheme(
                    backgroundColor: transactionType.actionBackgroundColor(
                      context,
                    ),
                    iconColor: transactionType.actionColor(context),
                  ),
                ),
              )
              .toList(),
          child: StatefulBuilder(
            builder: (context, setState) => Tooltip(
              message: "transaction.new".t(context),
              child: Material(
                color: navbarTheme.transactionButtonBackgroundColor,
                shape: RoundedRectangleBorder(borderRadius: .circular(32.0)),
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
      },
    );
  }

  void onToggle(bool toggled) {
    _buttonRotationTurns = toggled ? 0.125 : 0.25;
    setState(() {});
  }
}
