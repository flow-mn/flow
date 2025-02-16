import "package:flow/entity/transaction_filter_preset.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/utils.dart";
import "package:flutter/material.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:material_symbols_icons/symbols.dart";

class DefaultFilterPresetListTile extends StatefulWidget {
  final bool selected;
  final bool isDefault;

  final VoidCallback? onTap;
  final VoidCallback? makeDefault;

  final Key? dismissibleKey;

  const DefaultFilterPresetListTile({
    super.key,
    required this.selected,
    this.isDefault = false,
    this.onTap,
    this.makeDefault,
    this.dismissibleKey,
  });

  @override
  State<DefaultFilterPresetListTile> createState() =>
      _DefaultFilterPresetListTileState();
}

class _DefaultFilterPresetListTileState
    extends State<DefaultFilterPresetListTile> {
  @override
  Widget build(BuildContext context) {
    final String filterSummary =
        TransactionFilterPreset.defaultFilter.summary(context);

    final Widget listTile = ListTile(
      onTap: widget.onTap,
      title: Text(
        TransactionFilterPreset.defaultFilter.range!.preset
                ?.localizedNameContext(context) ??
            "Default preset (last 30 days)",
      ),
      subtitle: Text(filterSummary),
      trailing: (widget.isDefault ? Icon(Symbols.star_rounded) : null),
      selected: widget.selected,
    );

    final List<SlidableAction> startActionPanes = [
      if (!widget.isDefault && widget.makeDefault != null)
        SlidableAction(
          onPressed: (context) => widget.makeDefault!(),
          icon: Symbols.star_rounded,
          backgroundColor: context.colorScheme.secondary,
        )
    ];

    return Slidable(
      key: widget.dismissibleKey,
      groupTag: "filter_preset_list_tile",
      startActionPane: startActionPanes.isNotEmpty
          ? ActionPane(
              motion: const DrawerMotion(),
              children: startActionPanes,
            )
          : null,
      child: listTile,
    );
  }
}
