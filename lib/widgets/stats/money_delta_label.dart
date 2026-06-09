import "package:flow/data/money.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";

/// A trending up/down arrow, the absolute [delta] amount, and a trailing
/// [suffixLabel] (e.g. "in this year"), colored by the sign of the delta.
///
/// Shared by the net worth page header and the net worth bento tile so both
/// render the change indicator identically.
class MoneyDeltaLabel extends StatelessWidget {
  final Money delta;
  final String suffixLabel;
  final double iconSize;
  final bool initiallyAbbreviated;
  final TextStyle? suffixStyle;

  const MoneyDeltaLabel({
    super.key,
    required this.delta,
    required this.suffixLabel,
    this.iconSize = 18.0,
    this.initiallyAbbreviated = false,
    this.suffixStyle,
  });

  @override
  Widget build(BuildContext context) {
    final bool up = delta.amount >= 0;
    final Color color = up
        ? context.flowColors.income
        : context.flowColors.expense;

    return Row(
      mainAxisSize: .min,
      children: [
        Icon(
          up ? Symbols.trending_up_rounded : Symbols.trending_down_rounded,
          color: color,
          size: iconSize,
        ),
        const SizedBox(width: 4.0),
        MoneyText(
          delta,
          displayAbsoluteAmount: true,
          initiallyAbbreviated: initiallyAbbreviated,
          style: context.textTheme.bodyMedium?.copyWith(color: color),
        ),
        const SizedBox(width: 6.0),
        Flexible(
          child: Text(
            suffixLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: suffixStyle ?? context.textTheme.bodyMedium?.semi(context),
          ),
        ),
      ],
    );
  }
}
