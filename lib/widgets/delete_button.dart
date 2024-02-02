import 'package:flow/l10n/extensions.dart';
import 'package:flow/theme/theme.dart';
import 'package:flutter/material.dart';

class DeleteButton extends StatelessWidget {
  final Widget? label;

  final VoidCallback? onTap;

  const DeleteButton({
    super.key,
    this.label,
    this.onTap,
  });

  static const BorderRadius borderRadius =
      BorderRadius.all(Radius.circular(16.0));

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.flowColors.expense,
      shape: const RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      elevation: 0.0,
      type: MaterialType.button,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 12.0,
          ),
          child: DefaultTextStyle(
            style: TextStyle(
              color: context.colorScheme.background,
              fontWeight: FontWeight.w500,
            ),
            child: label ??
                Text(
                  "general.delete".t(context),
                ),
          ),
        ),
      ),
    );
  }
}
