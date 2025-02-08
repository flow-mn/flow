import "dart:developer";

import "package:flow/data/currencies.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/data/transactions_filter/time_range.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/utils/optional.dart";
import "package:flow/widgets/select_multi_currency_sheet.dart";
import "package:flow/widgets/transaction_filter_head.dart";
import "package:flow/widgets/transaction_filter_head/select_group_range_sheet.dart";
import "package:flow/widgets/transaction_filter_head/select_multi_account_sheet.dart";
import "package:flow/widgets/transaction_filter_head/select_multi_category_sheet.dart";
import "package:flow/widgets/transaction_filter_head/select_transaction_filter_time_range_sheet.dart";
import "package:flow/widgets/transaction_filter_head/transaction_filter_chip.dart";
import "package:flow/widgets/transaction_filter_head/transaction_search_sheet.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class DefaultTransactionsFilterHead extends StatefulWidget {
  final TransactionFilter current;
  final TransactionFilter defaultFilter;

  final EdgeInsets padding;

  final void Function(TransactionFilter) onChanged;

  const DefaultTransactionsFilterHead({
    super.key,
    required this.current,
    required this.onChanged,
    this.defaultFilter = TransactionFilter.empty,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
  });

  @override
  State<DefaultTransactionsFilterHead> createState() =>
      _DefaultTransactionsFilterHeadState();
}

class _DefaultTransactionsFilterHeadState
    extends State<DefaultTransactionsFilterHead> {
  late TransactionFilter _filter;

  TransactionFilter get filter => _filter;
  set filter(TransactionFilter value) {
    _filter = value;
    widget.onChanged(value);
  }

  @override
  void initState() {
    super.initState();
    _filter = widget.current;
  }

  @override
  void didUpdateWidget(DefaultTransactionsFilterHead oldWidget) {
    if (oldWidget.current != widget.current) {
      _filter = widget.current;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return TransactionFilterHead(
      padding: widget.padding,
      filterChips: [
        TransactionFilterChip<TransactionSearchData>(
          translationKey: "transactions.query.filter.keyword",
          avatar: const Icon(Symbols.search_rounded),
          onSelect: onSearch,
          defaultValue: widget.defaultFilter.searchData,
          value: _filter.searchData,
          highlightOverride: _filter.searchData.normalizedKeyword != null,
        ),
        TransactionFilterChip<TransactionFilterTimeRange>(
          translationKey: "transactions.query.filter.timeRange",
          avatar: const Icon(Symbols.history_rounded),
          onSelect: onSelectRange,
          defaultValue: widget.defaultFilter.range,
          value: _filter.range,
        ),
        TransactionFilterChip<List<Account>>(
          translationKey: "transactions.query.filter.accounts",
          avatar: const Icon(Symbols.wallet_rounded),
          onSelect: onSelectAccounts,
          defaultValue: widget.defaultFilter.accounts,
          value: _filter.accounts?.isNotEmpty == true ? _filter.accounts : null,
        ),
        TransactionFilterChip<List<Category>>(
          translationKey: "transactions.query.filter.categories",
          avatar: const Icon(Symbols.category_rounded),
          onSelect: onSelectCategories,
          defaultValue: widget.defaultFilter.categories,
          value: _filter.categories?.isNotEmpty == true
              ? _filter.categories
              : null,
        ),
        TransactionFilterChip<List<String>>(
          translationKey: "transactions.query.filter.currency",
          avatar: const Icon(Symbols.universal_currency_alt_rounded),
          onSelect: onSelectCurrency,
          defaultValue: widget.defaultFilter.currencies,
          value: _filter.currencies?.isNotEmpty == true
              ? _filter.currencies
              : null,
        ),
        TransactionFilterChip<TransactionGroupRange>(
          translationKey: "transactions.query.filter.groupBy",
          avatar: const Icon(Symbols.atr_rounded),
          onSelect: onSelectGroupBy,
          defaultValue: widget.defaultFilter.groupBy,
          value: _filter.groupBy,
        ),
      ],
    );
  }

  void onSearch() async {
    final TransactionSearchData? searchData =
        await showModalBottomSheet<TransactionSearchData>(
      context: context,
      builder: (context) => TransactionSearchSheet(
        searchData: filter.searchData,
      ),
      isScrollControlled: true,
    );

    if (searchData != null) {
      setState(() {
        filter = filter.copyWithOptional(searchData: searchData);
      });
    }
  }

  void onSelectAccounts() async {
    final List<Account>? accounts = await showModalBottomSheet<List<Account>>(
      context: context,
      builder: (context) => SelectMultiAccountSheet(
        accounts: ObjectBox().getAccounts(),
        selectedUuids: filter.accounts?.map((account) => account.uuid).toList(),
      ),
      isScrollControlled: true,
    );

    if (accounts != null) {
      setState(() {
        filter = filter.copyWithOptional(accounts: Optional(accounts));
      });
    }
  }

  void onSelectCategories() async {
    final List<Category>? categories =
        await showModalBottomSheet<List<Category>>(
      context: context,
      builder: (context) => SelectMultiCategorySheet(
        categories: ObjectBox().getCategories(),
        selectedUuids:
            filter.categories?.map((category) => category.uuid).toList(),
      ),
      isScrollControlled: true,
    );

    if (categories != null) {
      setState(() {
        filter = filter.copyWithOptional(categories: Optional(categories));
      });
    }
  }

  void onSelectCurrency() async {
    final Set<String> possibleCurrencies =
        ObjectBox().getAccounts().map((account) => account.currency).toSet();

    final List<String>? newCurrencies =
        await showModalBottomSheet<List<String>>(
      context: context,
      builder: (context) => SelectMultiCurrencySheet(
        currencies: possibleCurrencies
            .map((code) => iso4217CurrenciesGrouped[code])
            .nonNulls
            .toList(),
        currentlySelected: filter.currencies,
      ),
      isScrollControlled: true,
    );

    log("newCurrencies $newCurrencies");

    if (newCurrencies != null) {
      setState(() {
        filter = filter.copyWithOptional(currencies: Optional(newCurrencies));
      });
    }
  }

  void onSelectGroupBy() async {
    final TransactionGroupRange? newGroupBy =
        await showModalBottomSheet<TransactionGroupRange>(
      context: context,
      builder: (context) => SelectGroupRangeSheet(
        selected: filter.groupBy,
      ),
      isScrollControlled: true,
    );

    if (newGroupBy != null) {
      setState(() {
        filter = filter.copyWithOptional(groupBy: Optional(newGroupBy));
      });
    }
  }

  void onSelectRange() async {
    final TransactionFilterTimeRange? newTransactionFilterTimeRange =
        await showTransactionFilterTimeRangeSelectorSheet(
      context,
      initialValue: _filter.range,
    );

    if (!mounted || newTransactionFilterTimeRange == null) return;

    setState(() {
      filter = filter.copyWithOptional(
        range: Optional(
          newTransactionFilterTimeRange,
        ),
      );
    });
  }
}
