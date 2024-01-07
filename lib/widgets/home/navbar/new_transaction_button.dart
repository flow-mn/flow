import 'package:flow/l10n/extensions.dart';
import 'package:flow/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class NewTransactionButton extends StatelessWidget {
  final VoidCallback onActionTap;

  const NewTransactionButton({super.key, required this.onActionTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "transaction.new".t(context),
      child: Material(
        color: context.colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32.0),
        ),
        child: InkWell(
          onTap: () => onActionTap(),
          borderRadius: BorderRadius.circular(32.0),
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
  }
}
