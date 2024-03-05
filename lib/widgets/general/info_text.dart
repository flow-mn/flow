import 'package:flow/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class InfoText extends StatelessWidget {
  final Widget child;

  const InfoText({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Symbols.info_rounded,
          fill: 0,
          color: context.flowColors.semi,
          size: 16.0,
        ),
        const SizedBox(width: 8.0),
        Flexible(
          child: DefaultTextStyle(
            style: context.textTheme.bodySmall!.semi(context),
            child: child,
          ),
        ),
      ],
    );
  }
}
