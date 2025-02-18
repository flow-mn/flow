import "package:flow/entity/transaction_filter_preset.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/utils.dart";
import "package:flutter/material.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:material_symbols_icons/symbols.dart";

class FilterPresetListTile extends StatefulWidget {
  final TransactionFilterPreset preset;
  final bool selected;
  final bool isDefault;
  final bool valid;

  final VoidCallback? onTap;
  final VoidCallback? delete;
  final VoidCallback? makeDefault;

  final Key? dismissibleKey;

  const FilterPresetListTile({
    super.key,
    required this.preset,
    required this.selected,
    required this.valid,
    this.isDefault = false,
    this.onTap,
    this.delete,
    this.makeDefault,
    this.dismissibleKey,
  });

  @override
  State<FilterPresetListTile> createState() => _FilterPresetListTileState();
}

class _FilterPresetListTileState extends State<FilterPresetListTile> {
  TransactionFilterPreset get preset => widget.preset;

  @override
  Widget build(BuildContext context) {
    final String? filterSummary =
        widget.valid ? preset.filter.summary(context) : null;

    final Widget listTile = ListTile(
      onTap: widget.onTap,
      title: Text(preset.name),
      enabled: widget.valid,
      subtitle:
          widget.valid
              ? (filterSummary == null ? null : Text(filterSummary))
              : Text("transactionFilterPreset.invalid".t(context)),
      trailing:
          widget.valid
              ? (widget.isDefault ? Icon(Symbols.star_rounded) : null)
              : Tooltip(
                message: "transactionFilterPreset.invalid.description".t(
                  context,
                ),
                child: Icon(Symbols.error_circle_rounded),
              ),
      selected: widget.selected,
    );

    final List<SlidableAction> endActionPanes = [
      if (widget.delete != null)
        SlidableAction(
          onPressed: (context) => widget.delete!(),
          icon: Symbols.delete_forever_rounded,
          backgroundColor: context.flowColors.expense,
        ),
    ];

    final List<SlidableAction> startActionPanes = [
      if (!widget.isDefault && widget.makeDefault != null)
        SlidableAction(
          onPressed: (context) => widget.makeDefault!(),
          icon: Symbols.star_rounded,
          backgroundColor: context.colorScheme.secondary,
        ),
    ];

    return Slidable(
      key: widget.dismissibleKey,
      groupTag: "filter_preset_list_tile",
      endActionPane:
          endActionPanes.isNotEmpty
              ? ActionPane(
                motion: const DrawerMotion(),
                children: endActionPanes,
              )
              : null,
      startActionPane:
          startActionPanes.isNotEmpty
              ? ActionPane(
                motion: const DrawerMotion(),
                children: startActionPanes,
              )
              : null,
      child: listTile,
    );
  }
}
