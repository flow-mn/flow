import 'package:flow/data/currencies.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/general/bottom_sheet_frame.dart';
import 'package:flutter/material.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Pops with a valid [ISO 4217](https://en.wikipedia.org/wiki/ISO_4217) currency code [String]
class SelectCurrencySheet extends StatefulWidget {
  const SelectCurrencySheet({super.key});

  @override
  State<SelectCurrencySheet> createState() => _SelectCurrencySheetState();
}

class _SelectCurrencySheetState extends State<SelectCurrencySheet> {
  final ScrollController _scrollController = ScrollController();

  String _query = "";

  final Fuzzy<CurrencyData> _fuzzy = Fuzzy(iso4217Currencies,
      options: FuzzyOptions(keys: [
        WeightedKey(
            name: "Country Name",
            getter: (currencyData) => currencyData.country,
            weight: 0.85),
        WeightedKey(
            name: "Currency Name",
            getter: (currencyData) => currencyData.name,
            weight: 0.95),
        WeightedKey(
            name: "ISO 4217 Code",
            getter: (currencyData) => currencyData.code,
            weight: 0.5),
      ]));

  @override
  Widget build(BuildContext context) {
    // ISO4217Currencies.currencies.length

    final queryResults = _fuzzy.search(_query, 15);

    // Artificially deprioritize North Korean Won due to its unpopularity
    final kpwIndex =
        queryResults.indexWhere((element) => element.item.code == "KPW");
    if (kpwIndex > -1) {
      final kpw = queryResults.removeAt(kpwIndex);
      queryResults.add(kpw);
    }

    return BottomSheetFrame(
      child: Column(
        children: [
          const SizedBox(height: 16.0),
          Text(
            "account.edit.selectCurrency".t(context),
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8.0),
          Padding(
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
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemBuilder: (context, i) => ListTile(
                title: Text(queryResults[i].item.name),
                subtitle: Text(queryResults[i].item.country),
                trailing: Text(queryResults[i].item.code),
                onTap: () => select(queryResults[i].item.code),
              ),
              itemCount: queryResults.length,
            ),
          ),
        ],
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
