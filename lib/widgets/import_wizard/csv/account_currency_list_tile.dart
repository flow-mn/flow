import "package:flow/theme/helpers.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class AccountCurrencyListTile extends StatelessWidget {
  final String name;
  final String? currency;

  final VoidCallback? onTap;

  const AccountCurrencyListTile({
    super.key,
    required this.name,
    this.currency,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currency ?? "---",
            style: context.textTheme.bodyLarge?.copyWith(
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(width: 8.0),
          Icon(Symbols.arrow_drop_down_rounded),
        ],
      ),
      onTap: onTap,
    );
  }
}
