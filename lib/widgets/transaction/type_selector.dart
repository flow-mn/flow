import "package:flow/entity/transaction.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class TypeSelector extends StatelessWidget {
  final TransactionType current;

  final bool canEdit;

  final Function(TransactionType) onChange;

  const TypeSelector({
    super.key,
    required this.current,
    required this.onChange,
    this.canEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!canEdit) return Text(current.localizedNameContext(context));

    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: DropdownButton<TransactionType>(
        style: context.textTheme.titleSmall,
        underline: SizedBox.shrink(),
        icon: const Icon(Symbols.arrow_drop_down_rounded),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        borderRadius: .circular(8.0),
        value: current,
        enableFeedback: LocalPreferences().enableHapticFeedback.get(),
        elevation: 2,
        items: TransactionType.values
            .map(
              (type) => DropdownMenuItem(
                value: type,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 12.0,
                  children: [
                    Icon(type.icon, size: 20.0, color: type.color(context)),
                    Text(
                      type.localizedNameContext(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            )
            .toList(),
        onChanged: (TransactionType? value) {
          if (value == null) return;

          onChange(value);
        },
      ),
    );
  }
}
