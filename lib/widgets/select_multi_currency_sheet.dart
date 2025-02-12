import "package:flow/data/currencies.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// Pops with a list of valid [ISO 4217](https://en.wikipedia.org/wiki/ISO_4217) currency code [List<String>]
class SelectMultiCurrencySheet extends StatefulWidget {
  final List<String>? currentlySelected;
  final List<CurrencyData> currencies;

  const SelectMultiCurrencySheet({
    super.key,
    required this.currencies,
    this.currentlySelected,
  });

  @override
  State<SelectMultiCurrencySheet> createState() =>
      _SelectMultiCurrencySheetState();
}

class _SelectMultiCurrencySheetState extends State<SelectMultiCurrencySheet> {
  late Set<String> selectedUuids;

  @override
  void initState() {
    super.initState();
    selectedUuids = Set.from(widget.currentlySelected ?? (const []));
  }

  @override
  void didUpdateWidget(SelectMultiCurrencySheet oldWidget) {
    if (widget.currentlySelected != oldWidget.currentlySelected) {
      selectedUuids = Set.from(widget.currentlySelected ?? (const []));
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      title: Text("account.edit.selectCurrency".t(context)),
      scrollableContentMaxHeight: MediaQuery.of(context).size.height * 0.4 -
          MediaQuery.of(context).viewInsets.vertical,
      trailing: ModalOverflowBar(
        alignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: () => context.pop(<String>[]),
            icon: const Icon(Symbols.block_rounded),
            label: Text("transactions.query.clearSelection".t(context)),
          ),
          TextButton.icon(
            onPressed: pop,
            icon: const Icon(Symbols.check),
            label: Text("general.done".t(context)),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.currencies.map((currency) {
            final CurrencyData transformedCurrencyData =
                iso4217CurrenciesGrouped[currency.code]!;

            return CheckboxListTile /*.adaptive*/ (
              value: selectedUuids.contains(transformedCurrencyData.code),
              title: Text(
                transformedCurrencyData.name,
              ),
              subtitle: Text(
                transformedCurrencyData.country.titleCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              secondary: Text(
                transformedCurrencyData.code,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontFeatures: [const FontFeature.tabularFigures()],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onChanged: (value) => select(transformedCurrencyData.code, value),
            );
          }).toList(),
        ),
      ),
    );
  }

  void select(String code, bool? selected) {
    if (selected == null) return;

    if (selected) {
      selectedUuids.add(code);
    } else {
      selectedUuids.remove(code);
    }

    setState(() {});
  }

  void pop() {
    context.pop(selectedUuids.toList());
  }
}
