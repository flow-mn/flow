import "package:flow/entity/account.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class AccountPresetCard extends StatelessWidget {
  final Function(bool)? onSelect;
  final bool selected;

  final bool preexisting;

  final Account account;

  final BorderRadius borderRadius;

  const AccountPresetCard({
    super.key,
    required this.account,
    required this.onSelect,
    required this.selected,
    required this.preexisting,
    this.borderRadius = const BorderRadius.all(Radius.circular(24.0)),
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: selected ? 1.0 : 0.46,
      child: Surface(
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        builder: (context) => InkWell(
          onTap: onSelect == null ? null : () => onSelect!(!selected),
          borderRadius: borderRadius,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    FlowIcon(
                      account.icon,
                      size: 60.0,
                    ),
                    const SizedBox(width: 8.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          account.name,
                          style: context.textTheme.titleSmall,
                        ),
                        Text(
                          account.balance.formatMoney(),
                          style: context.textTheme.displaySmall,
                        ),
                      ],
                    ),
                    if (!preexisting) ...[
                      const Spacer(),
                      Icon(
                        selected ? Symbols.remove_rounded : Symbols.add_rounded,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
