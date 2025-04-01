import "dart:math";

import "package:flow/routes/transaction_page/input_amount_sheet.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/numpad_button.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class CalculatorButton extends StatelessWidget {
  final CalculatorOperation operation;
  final CalculatorOperation? currentOperation;

  final void Function(CalculatorOperation) onTap;

  const CalculatorButton({
    super.key,
    required this.operation,
    required this.onTap,
    this.currentOperation,
  });

  @override
  Widget build(BuildContext context) {
    final bool selected = operation == currentOperation;

    return NumpadButton(
      backgroundColor: selected ? context.colorScheme.primary : null,
      onTap: () => onTap(operation),
      child: Transform.scale(
        scale: operation == CalculatorOperation.divide ? 0.8 : 1.0,
        child: Transform.rotate(
          angle: operation == CalculatorOperation.divide ? (pi / 4.0) : 0,
          child: Icon(
            iconData,
            color: selected ? context.colorScheme.onPrimary : null,
          ),
        ),
      ),
    );
  }

  IconData get iconData => switch (operation) {
    CalculatorOperation.add => Symbols.add_rounded,
    CalculatorOperation.subtract => Symbols.remove_rounded,
    CalculatorOperation.multiply => Symbols.close_small_rounded,
    CalculatorOperation.divide => Symbols.percent_rounded,
  };
}
