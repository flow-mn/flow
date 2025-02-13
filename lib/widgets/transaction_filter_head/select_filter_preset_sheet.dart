import "package:flow/data/transaction_filter.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction_filter_preset.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/transaction_filter_head/select_filter_preset_sheet/filter_preset_list_tile.dart";
import "package:flutter/material.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:objectbox/objectbox.dart";

/// Pops with an [Optional<TransactionFilter>] when a preset is selected.
class SelectFilterPresetSheet extends StatefulWidget {
  final TransactionFilter defaultFilter;
  final TransactionFilter? selected;

  final VoidCallback? onSaveAsNew;

  const SelectFilterPresetSheet({
    super.key,
    this.selected,
    required this.defaultFilter,
    this.onSaveAsNew,
  });

  @override
  State<SelectFilterPresetSheet> createState() =>
      _SelectFilterPresetSheetState();
}

class _SelectFilterPresetSheetState extends State<SelectFilterPresetSheet> {
  QueryBuilder<TransactionFilterPreset> transactionFilterPresetsQb() =>
      ObjectBox().box<TransactionFilterPreset>().query();

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      scrollableContentMaxHeight: MediaQuery.of(context).size.height * .5,
      title: Text("transactionFilterPreset".t(context)),
      trailing: ModalOverflowBar(
        alignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: pop,
            icon: const Icon(Symbols.close_rounded),
            label: Text("general.cancel".t(context)),
          ),
        ],
      ),
      child: StreamBuilder<List<TransactionFilterPreset>>(
          stream: transactionFilterPresetsQb()
              .watch(triggerImmediately: true)
              .map((event) => event.find()),
          builder: (context, presetsSnapshot) {
            if (!presetsSnapshot.hasData) {
              return Frame.standalone(child: Spinner.center());
            }

            final List<TransactionFilterPreset> presets =
                presetsSnapshot.requireData;

            final List<Account> accounts = ObjectBox().getAccounts(false);
            final List<Category> categories = ObjectBox().getCategories(false);

            return SlidableAutoCloseBehavior(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      onTap: () => context.pop(Optional(widget.defaultFilter)),
                      title: Text(
                        widget.defaultFilter.range?.preset
                                ?.localizedNameContext(context) ??
                            "Default filter",
                      ),
                      selected: widget.selected?.calculateDifferentFieldCount(
                              widget.defaultFilter) ==
                          0,
                      subtitle: Text(
                        "transactionFilterPreset.default".t(context),
                      ),
                    ),
                    ...presets.map((preset) {
                      final int? differenceCount = widget.selected
                          ?.calculateDifferentFieldCount(preset.filter);

                      final bool valid = preset.validate(
                        accounts: accounts.map((x) => x.uuid).toList(),
                        categories: categories.map((x) => x.uuid).toList(),
                      );

                      return FilterPresetListTile(
                        onTap: () => context.pop(Optional(preset.filter)),
                        delete: () => delete(preset),
                        valid: valid,
                        preset: preset,
                        selected: differenceCount == 0,
                      );
                    }),
                    if (widget.onSaveAsNew != null)
                      ListTile(
                        onTap: () => widget.onSaveAsNew!(),
                        title: Text(
                          "transactionFilterPreset.saveAsNew".t(context),
                        ),
                        trailing: Icon(Symbols.add_rounded),
                      ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  Future<bool> delete(TransactionFilterPreset preset) async {
    final bool? confirmation = await context.showConfirmDialog(
        isDeletionConfirmation: true,
        title: "transactionFilterPreset.delete".t(context),
        child: Text(
          "general.delete.permanentWarning".t(
            context,
          ),
        ));

    if (confirmation != true || !mounted) return false;

    return ObjectBox().box<TransactionFilterPreset>().remove(preset.id);
  }

  void pop() => context.pop();
}
