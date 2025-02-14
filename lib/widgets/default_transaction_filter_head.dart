import "dart:developer";

import "package:flow/data/currencies.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/data/transactions_filter/time_range.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction_filter_preset.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/utils/extensions.dart";
import "package:flow/utils/optional.dart";
import "package:flow/widgets/select_multi_currency_sheet.dart";
import "package:flow/widgets/transaction_filter_head.dart";
import "package:flow/widgets/transaction_filter_head/create_filter_preset_sheet.dart";
import "package:flow/widgets/transaction_filter_head/select_filter_preset_sheet.dart";
import "package:flow/widgets/transaction_filter_head/select_group_range_sheet.dart";
import "package:flow/widgets/transaction_filter_head/select_multi_account_sheet.dart";
import "package:flow/widgets/transaction_filter_head/select_multi_category_sheet.dart";
import "package:flow/widgets/transaction_filter_head/select_transaction_filter_time_range_sheet.dart";
import "package:flow/widgets/transaction_filter_head/transaction_filter_chip.dart";
import "package:flow/widgets/transaction_filter_head/transaction_search_sheet.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
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

  late bool showCurrencyFilterChip;

  TransactionFilter get filter => _filter;
  set filter(TransactionFilter value) {
    _filter = value;
    widget.onChanged(value);
  }

  @override
  void initState() {
    super.initState();
    _filter = widget.current;

    TransitiveLocalPreferences()
        .transitiveUsesSingleCurrency
        .addListener(_updateShowCurrencyFilterChip);
    showCurrencyFilterChip =
        !TransitiveLocalPreferences().transitiveUsesSingleCurrency.get();
  }

  @override
  void didUpdateWidget(DefaultTransactionsFilterHead oldWidget) {
    if (oldWidget.current != widget.current) {
      _filter = widget.current;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    TransitiveLocalPreferences()
        .transitiveUsesSingleCurrency
        .removeListener(_updateShowCurrencyFilterChip);
    super.dispose();
  }

  QueryBuilder<TransactionFilterPreset> transactionFilterPresetsQb() =>
      ObjectBox().box<TransactionFilterPreset>().query();

  QueryBuilder<Account> accountsQb() => ObjectBox()
      .box<Account>()
      .query(Account_.archived.isNull().or(Account_.archived.notEquals(true)))
      .order(Account_.sortOrder);

  QueryBuilder<Category> categoriesQb() => ObjectBox().box<Category>().query();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TransactionFilterPreset>>(
      stream: transactionFilterPresetsQb()
          .watch(triggerImmediately: true)
          .map((event) => event.find()),
      builder: (context, transactionPresetsSnapshot) {
        return StreamBuilder<List<Account>>(
            stream: accountsQb()
                .watch(triggerImmediately: true)
                .map((event) => event.find()),
            builder: (context, accountsSnapshot) {
              return StreamBuilder<List<Category>>(
                  stream: categoriesQb()
                      .watch(triggerImmediately: true)
                      .map((event) => event.find()),
                  builder: (context, categoriesSnapshot) {
                    final int differentFieldCount = widget.defaultFilter
                        .calculateDifferentFieldCount(_filter);

                    if (accountsSnapshot.hasData &&
                        categoriesSnapshot.hasData &&
                        !_filter.validate(
                          accounts: accountsSnapshot.requireData
                              .map((account) => account.uuid)
                              .toList(),
                          categories: categoriesSnapshot.requireData
                              .map((category) => category.uuid)
                              .toList(),
                        )) {
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        filter = widget.defaultFilter;
                        if (mounted) {
                          setState(() {});
                        }
                      });
                    }

                    return TransactionFilterHead(
                      padding: widget.padding,
                      filterChips: [
                        if (transactionPresetsSnapshot.hasData)
                          FilterChip(
                            showCheckmark: false,
                            label: Text(differentFieldCount.toString()),
                            selected: differentFieldCount > 0,
                            avatar: const Icon(Symbols.filter_list_rounded),
                            onSelected: (_) => _showFilterPresetSelectionSheet(
                              transactionPresetsSnapshot.requireData,
                            ),
                          ),
                        TransactionFilterChip<TransactionSearchData>(
                          translationKey: "transactions.query.filter.keyword",
                          avatar: const Icon(Symbols.search_rounded),
                          onSelect: onSearch,
                          defaultValue: widget.defaultFilter.searchData,
                          value: _filter.searchData,
                          highlightOverride:
                              _filter.searchData.normalizedKeyword != null,
                        ),
                        TransactionFilterChip<TransactionFilterTimeRange>(
                          translationKey: "transactions.query.filter.timeRange",
                          avatar: const Icon(Symbols.history_rounded),
                          onSelect: onSelectRange,
                          defaultValue: widget.defaultFilter.range,
                          value: _filter.range,
                        ),
                        if (accountsSnapshot.hasData)
                          TransactionFilterChip<Set<Account>>(
                            translationKey:
                                "transactions.query.filter.accounts",
                            avatar: const Icon(Symbols.wallet_rounded),
                            onSelect: onSelectAccounts,
                            defaultValue: widget.defaultFilter.accounts
                                ?.map((uuid) => accountsSnapshot.requireData
                                    .firstWhere(
                                        (account) => account.uuid == uuid))
                                .toSet(),
                            value: _filter.accounts?.isNotEmpty == true
                                ? _filter.accounts
                                    ?.map(
                                      (uuid) => accountsSnapshot.requireData
                                          .firstWhereOrNull(
                                        (account) => account.uuid == uuid,
                                      ),
                                    )
                                    .nonNulls
                                    .toSet()
                                : null,
                            // value: _filter.accounts?.isNotEmpty == true ? _filter.accounts : null,
                          ),
                        TransactionFilterChip<Set<Category>>(
                          translationKey:
                              "transactions.query.filter.categories",
                          avatar: const Icon(Symbols.category_rounded),
                          onSelect: onSelectCategories,
                          defaultValue: widget.defaultFilter.categories
                              ?.map((uuid) => categoriesSnapshot.requireData
                                  .firstWhere(
                                      (category) => category.uuid == uuid))
                              .toSet(),
                          value: _filter.categories?.isNotEmpty == true
                              ? _filter.categories
                                  ?.map(
                                    (uuid) => categoriesSnapshot.requireData
                                        .firstWhereOrNull(
                                      (category) => category.uuid == uuid,
                                    ),
                                  )
                                  .nonNulls
                                  .toSet()
                              : null,
                        ),
                        if (showCurrencyFilterChip)
                          TransactionFilterChip<List<String>>(
                            translationKey:
                                "transactions.query.filter.currency",
                            avatar: const Icon(
                                Symbols.universal_currency_alt_rounded),
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
                  });
            });
      },
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
        selectedUuids: filter.accounts,
      ),
      isScrollControlled: true,
    );

    if (accounts != null) {
      setState(() {
        filter = filter.copyWithOptional(
            accounts:
                Optional(accounts.map((account) => account.uuid).toList()));
      });
    }
  }

  void onSelectCategories() async {
    final List<Category>? categories =
        await showModalBottomSheet<List<Category>>(
      context: context,
      builder: (context) => SelectMultiCategorySheet(
        categories: ObjectBox().getCategories(),
        selectedUuids: filter.categories,
      ),
      isScrollControlled: true,
    );

    if (categories != null) {
      setState(() {
        filter = filter.copyWithOptional(
          categories: Optional(
            categories.map((category) => category.uuid).toList(),
          ),
        );
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

  void _updateShowCurrencyFilterChip() {
    setState(() {
      showCurrencyFilterChip =
          !TransitiveLocalPreferences().transitiveUsesSingleCurrency.get();
    });
  }

  void _saveNewFilterPreset() async {
    await showModalBottomSheet<int>(
      context: context,
      builder: (context) => CreateFilterPresetSheet(
        filter: _filter,
        initialName: _filter.range?.preset?.localizedNameContext(context),
      ),
      isScrollControlled: true,
    );
  }

  void _showFilterPresetSelectionSheet(
    List<TransactionFilterPreset> presets,
  ) async {
    final Optional<TransactionFilter>? selected =
        await showModalBottomSheet<Optional<TransactionFilter>>(
      context: context,
      builder: (context) => SelectFilterPresetSheet(
        defaultFilter: widget.defaultFilter,
        selected: _filter,
        onSaveAsNew: _saveNewFilterPreset,
      ),
      isScrollControlled: true,
    );

    if (selected == null || selected.value == null) return;
    if (!mounted) return;

    setState(() {
      filter = selected.value!;
    });
  }
}
