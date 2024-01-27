import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/general/spinner.dart';
import 'package:flutter/material.dart';

class FlatButton extends StatelessWidget {
  final bool busy;
  final Widget? trailing;
  final Widget child;

  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  const FlatButton({
    super.key,
    required this.child,
    this.busy = false,
    this.trailing,
    this.onPressed,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final renderChild = trailing == null
        ? child
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              child,
              const SizedBox(width: 8.0),
              busy ? const Spinner() : trailing!,
            ],
          );

    return ElevatedButton(
      style: ButtonStyle(
        padding: trailing == null
            ? const MaterialStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              )
            : MaterialStatePropertyAll(
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0)
                    .copyWith(right: 12.0),
              ),
        elevation: MaterialStateProperty.all(0.0),
        backgroundColor:
            MaterialStatePropertyAll(context.colorScheme.secondary),
        foregroundColor:
            MaterialStatePropertyAll(context.colorScheme.onSecondary),
      ),
      onPressed: onPressed,
      onLongPress: onLongPress,
      child: renderChild,
    );
  }
}
