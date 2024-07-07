import 'package:flow/l10n/extensions.dart';
import 'package:flow/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class DeleteButton extends StatelessWidget {
  final Widget? label;

  final VoidCallback? onTap;

  final BorderRadius borderRadius;

  const DeleteButton({
    super.key,
    this.label,
    this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      elevation: 0.0,
      type: MaterialType.button,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 8.0,
          ),
          child: DefaultTextStyle(
            style: TextStyle(
              color: context.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Symbols.delete_forever_rounded,
                  color: context.colorScheme.error,
                ),
                const SizedBox(width: 8.0),
                label ?? Text("general.delete".t(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
