import 'package:flow/data/currencies.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/utils/utils.dart';
import 'package:flow/widgets/general/modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:fuzzy/data/result.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Pops with a valid [ISO 4217](https://en.wikipedia.org/wiki/ISO_4217) currency code [String]
class SelectCurrencySheet extends StatefulWidget {
  final String? currentlySelected;

  const SelectCurrencySheet({super.key, this.currentlySelected});

  @override
  State<SelectCurrencySheet> createState() => _SelectCurrencySheetState();
}

class _SelectCurrencySheetState extends State<SelectCurrencySheet> {
  final ScrollController _scrollController = ScrollController();

  String _query = "";

  final Fuzzy<CurrencyData> _fuzzy = Fuzzy(
    iso4217Currencies,
    options: FuzzyOptions(
      keys: [
        WeightedKey(
          name: "Country Name",
          getter: (currencyData) => currencyData.country,
          weight: 0.85,
        ),
        WeightedKey(
          name: "Currency Name",
          getter: (currencyData) => currencyData.name,
          weight: 0.95,
        ),
        WeightedKey(
          name: "ISO 4217 Code",
          getter: (currencyData) => currencyData.code,
          weight: 0.5,
        ),
      ],
    ),
  );

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ISO4217Currencies.currencies.length

    final List<Result<CurrencyData>> queryResults = _fuzzy
        .search(_query, 15)
        .groupBy((resultItem) => resultItem.item.code)
        .values
        .map((e) => e.firstOrNull)
        .nonNulls
        .toList();

    // Artificially deprioritize North Korean Won due to its unpopularity
    final int kpwIndex =
        queryResults.indexWhere((element) => element.item.code == "KPW");

    if (kpwIndex > -1) {
      final Result<CurrencyData> kpw = queryResults.removeAt(kpwIndex);
      queryResults.add(kpw);
    }

    // Bring the selected item to top
    final int selectedItemIndex = queryResults
        .indexWhere((element) => element.item.code == widget.currentlySelected);

    if (selectedItemIndex > -1) {
      final Result<CurrencyData> selectedItem =
          queryResults.removeAt(selectedItemIndex);
      queryResults.insert(0, selectedItem);
    }

    return ModalSheet.scrollable(
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TextField(
          onChanged: _updateQuery,
          onSubmitted: _updateQuery,
          decoration: InputDecoration(
            hintText: "currency.searchHint".t(context),
            prefixIcon: const Icon(Symbols.search_rounded),
          ),
        ),
      ),
      title: Text("account.edit.selectCurrency".t(context)),
      scrollableContentMaxHeight: MediaQuery.of(context).size.height * 0.4 -
          MediaQuery.of(context).viewInsets.vertical,
      child: ListView.builder(
        controller: _scrollController,
        itemBuilder: (context, i) {
          final CurrencyData transformedCurrencyData =
              iso4217CurrenciesGrouped[queryResults[i].item.code]!;

          return ListTile(
            selected: widget.currentlySelected == transformedCurrencyData.code,
            title: Text(
              transformedCurrencyData.name,
            ),
            subtitle: Text(
              transformedCurrencyData.country,
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
        itemCount: queryResults.length,
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
