import "package:flow/data/currencies.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/services/currency_registry.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:fuzzywuzzy/fuzzywuzzy.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";

/// Pops with a valid [ISO 4217](https://en.wikipedia.org/wiki/ISO_4217) currency code [String]
class SelectCurrencySheet extends StatefulWidget {
  final String? currentlySelected;

  /// Shown above the rest while the search query is empty
  final List<String> suggested;

  final String? titleOverride;

  const SelectCurrencySheet({
    super.key,
    this.currentlySelected,
    this.suggested = const [],
    this.titleOverride,
  });

  @override
  State<SelectCurrencySheet> createState() => _SelectCurrencySheetState();
}

class _SelectCurrencySheetState extends State<SelectCurrencySheet> {
  final ScrollController _scrollController = ScrollController();

  String _query = "";

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String normalizedQuery = _query.trim().toLowerCase();

    final List<CurrencyData> queryResults =
        (normalizedQuery.isNotEmpty
                ? extractTop<CurrencyData>(
                    query: normalizedQuery,
                    choices: CurrencyRegistryService().allCurrencies,
                    limit: CurrencyRegistryService().allCurrencies.length,
                    getter: (currencyData) =>
                        "${currencyData.code} ${currencyData.name} ${currencyData.country}",
                  ).map((result) => result.choice)
                : CurrencyRegistryService().allCurrencies)
            .groupBy((resultItem) => resultItem.code)
            .values
            .map((e) => e.firstOrNull)
            .nonNulls
            .toList();

    // Bring the selected item to top
    final int selectedItemIndex = queryResults.indexWhere(
      (element) => element.code == widget.currentlySelected,
    );

    if (selectedItemIndex > -1) {
      final CurrencyData selectedItem = queryResults.removeAt(
        selectedItemIndex,
      );
      queryResults.insert(0, selectedItem);
    }

    final Map<String, CurrencyData> groupedCurrencies =
        CurrencyRegistryService().groupedCurrencies;

    final List<CurrencyData> suggestions = normalizedQuery.isEmpty
        ? {
            if (widget.currentlySelected != null && widget.suggested.isNotEmpty)
              widget.currentlySelected!,
            ...widget.suggested,
          }.map((code) => groupedCurrencies[code]).nonNulls.toList()
        : const [];

    final Set<String> suggestedCodes = suggestions
        .map((currencyData) => currencyData.code)
        .toSet();

    // `null` marks the divider between suggestions and the rest
    final List<CurrencyData?> items = [
      ...suggestions,
      if (suggestions.isNotEmpty) null,
      ...queryResults
          .where((currencyData) => !suggestedCodes.contains(currencyData.code))
          .map((currencyData) => groupedCurrencies[currencyData.code]!),
    ];

    return ModalSheet.scrollable(
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TextField(
          onChanged: _updateQuery,
          onSubmitted: _updateQuery,
          autocorrect: false,
          enableSuggestions: false,
          spellCheckConfiguration: .disabled(),
          decoration: InputDecoration(
            hintText: "currency.searchHint".t(context),
            prefixIcon: const Icon(Symbols.search_rounded),
          ),
          autofocus: true,
        ),
      ),
      title: Text(
        widget.titleOverride ?? "account.edit.selectCurrency".t(context),
      ),
      scrollableContentMaxHeight:
          MediaQuery.of(context).size.height * 0.4 -
          MediaQuery.of(context).viewInsets.vertical,
      child: ListView.builder(
        controller: _scrollController,
        itemBuilder: (context, i) {
          final CurrencyData? transformedCurrencyData = items[i];

          if (transformedCurrencyData == null) {
            return const Divider();
          }

          return ListTile(
            selected: widget.currentlySelected == transformedCurrencyData.code,
            title: Text(transformedCurrencyData.name),
            subtitle: Text(
              transformedCurrencyData.country.titleCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              transformedCurrencyData.code,
              style: context.textTheme.bodyLarge?.copyWith(
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => select(transformedCurrencyData.code),
          );
        },
        itemCount: items.length,
      ),
    );
  }

  void _updateQuery(String value) {
    _query = value;
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    setState(() {});
  }

  void select(String code) {
    context.pop(code);
  }
}
