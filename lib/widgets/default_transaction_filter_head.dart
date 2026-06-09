import "package:flow/data/string_multi_filter.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/data/transactions_filter/time_range.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction_filter_preset.dart";
import "package:flow/entity/transaction_tag.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/providers/accounts_provider.dart";
import "package:flow/providers/categories_provider.dart";
import "package:flow/providers/transaction_tags_provider.dart";
import "package:flow/services/currency_registry.dart";
import "package:flow/utils/optional.dart";
import "package:flow/widgets/sheets/select_multi_currency_sheet.dart";
import "package:flow/widgets/sheets/select_multi_transaction_type_sheet.dart";
import "package:flow/widgets/sheets/select_transaction_tags_sheet.dart";
import "package:flow/widgets/transaction_filter_head.dart";
import "package:flow/widgets/transaction_filter_head/create_filter_preset_sheet.dart";
import "package:flow/widgets/transaction_filter_head/select_filter_preset_sheet.dart";
import "package:flow/widgets/transaction_filter_head/select_group_range_sheet.dart";
import "package:flow/widgets/transaction_filter_head/select_has_attachment_sheet.dart";
import "package:flow/widgets/transaction_filter_head/select_is_pending_sheet.dart";
import "package:flow/widgets/transaction_filter_head/select_multi_account_sheet.dart";
import "package:flow/widgets/transaction_filter_head/select_multi_category_sheet.dart";
import "package:flow/widgets/transaction_filter_head/select_transaction_filter_time_range_sheet.dart";
import "package:flow/widgets/transaction_filter_head/transaction_filter_chip.dart";
import "package:flow/widgets/transaction_filter_head/transaction_search_sheet.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:material_symbols_icons_flow/symbols.dart";

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

    TransitiveLocalPreferences().usesMultipleCurrencies.addListener(
      _updateShowCurrencyFilterChip,
    );
    showCurrencyFilterChip = TransitiveLocalPreferences().usesMultipleCurrencies
        .get();
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
    TransitiveLocalPreferences().usesNonPrimaryCurrency.removeListener(
      _updateShowCurrencyFilterChip,
    );
    super.dispose();
  }

  QueryBuilder<TransactionFilterPreset> transactionFilterPresetsQb() =>
      ObjectBox().box<TransactionFilterPreset>().query();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TransactionFilterPreset>>(
      stream: transactionFilterPresetsQb()
          .watch(triggerImmediately: true)
          .map((event) => event.find()),
      builder: (context, transactionPresetsSnapshot) {
        {
          final int differentFieldCount = widget.defaultFilter
              .calculateDifferentFieldCount(_filter);

          final List<Account>? activeAccounts =
              AccountsProvider.of(context).ready
              ? AccountsProvider.of(context).activeAccounts
              : null;
          final List<Category>? categories =
              CategoriesProvider.of(context).ready
              ? CategoriesProvider.of(context).categories
              : null;
          final List<TransactionTag>? tags =
              TransactionTagsProvider.of(context).ready
              ? TransactionTagsProvider.of(context).tags
              : null;

          if (activeAccounts != null &&
              categories != null &&
              !_filter.validate(
                accounts: activeAccounts.map((account) => account.uuid).toSet(),
                categories: categories.map((category) => category.uuid).toSet(),
                tags: (tags ?? <TransactionTag>[])
                    .map((tag) => tag.uuid)
                    .toSet(),
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
                highlightOverride: _filter.searchData.normalizedKeyword != null,
              ),
              TransactionFilterChip<TransactionFilterTimeRange>(
                translationKey: "transactions.query.filter.timeRange",
                avatar: const Icon(Symbols.history_rounded),
                onSelect: onSelectRange,
                defaultValue: widget.defaultFilter.range,
                value: _filter.range,
              ),
              if (activeAccounts != null)
                TransactionFilterChip<Set<Account>>(
                  translationKey: "transactions.query.filter.accounts",
                  avatar: const Icon(Symbols.wallet_rounded),
                  onSelect: onSelectAccounts,
                  defaultValue: widget.defaultFilter.accounts
                      ?.mappedFilter(activeAccounts, (account) => account.uuid)
                      .toSet(),
                  value: _filter.accounts
                      ?.mappedFilter(
                        AccountsProvider.of(context).activeAccounts,
                        (account) => account.uuid,
                      )
                      .nonNulls
                      .toSet(),
                ),
              if (categories != null)
                TransactionFilterChip<Set<Category>>(
                  translationKey: "transactions.query.filter.categories",
                  avatar: const Icon(Symbols.category_rounded),
                  onSelect: onSelectCategories,
                  defaultValue: widget.defaultFilter.categories
                      ?.mappedFilter(categories, (category) => category.uuid)
                      .toSet(),
                  value: _filter.categories
                      ?.mappedFilter(categories, (category) => category.uuid)
                      .toSet(),
                ),
              if (tags != null && tags.isNotEmpty == true)
                TransactionFilterChip<Set<TransactionTag>>(
                  translationKey: "transactions.query.filter.tags",
                  avatar: const Icon(Symbols.style_rounded),
                  onSelect: onSelectTags,
                  defaultValue: widget.defaultFilter.tags
                      ?.mappedFilter(tags, (tag) => tag.uuid)
                      .toSet(),
                  value: _filter.tags
                      ?.mappedFilter(tags, (tag) => tag.uuid)
                      .toSet(),
                ),
              TransactionFilterChip<bool?>(
                translationKey: "transactions.query.filter.hasAttachments",
                avatar: const Icon(Symbols.attach_file_rounded),
                onSelect: onSelectHasAttachments,
                defaultValue: null,
                value: _filter.hasAttachments,
              ),
              TransactionFilterChip<bool?>(
                translationKey: "transactions.query.filter.isPending",
                avatar: const Icon(Symbols.search_activity_rounded),
                onSelect: onSelectIsPending,
                defaultValue: null,
                value: _filter.isPending,
              ),
              TransactionFilterChip<List<TransactionType>>(
                translationKey: "transactions.query.filter.transactionType",
                avatar: const Icon(Symbols.swap_horiz_rounded),
                onSelect: onSelectType,
                defaultValue: null,
                value: _filter.types?.isNotEmpty == true
                    ? _filter.types!
                    : null,
              ),
              if (showCurrencyFilterChip)
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
      },
    );
  }

  void onSearch() async {
    final TransactionSearchData? searchData =
        await showModalBottomSheet<TransactionSearchData>(
          context: context,
          builder: (context) =>
              TransactionSearchSheet(searchData: filter.searchData),
          isScrollControlled: true,
        );

    if (searchData != null) {
      setState(() {
        filter = filter.copyWithOptional(searchData: searchData);
      });
    }
  }

  void onSelectAccounts() async {
    final List<Account>? allActiveAccounts = AccountsProvider.of(context).ready
        ? AccountsProvider.of(context).activeAccounts
        : null;

    final Optional<List<Account>>? accounts = await showModalBottomSheet(
      context: context,
      builder: (context) => SelectMultiAccountSheet(
        accounts: ObjectBox().getAccounts(),
        selectedUuids: filter.accounts?.filter(
          allActiveAccounts?.map((account) => account.uuid).toList() ?? [],
        ),
      ),
      isScrollControlled: true,
    );

    final StringMultiFilter? accountsFilterOverride = switch (accounts?.value) {
      List<Account> accountsList when accountsList.isNotEmpty =>
        StringMultiFilter.whitelist(
          accountsList.map((account) => account.uuid).toList(),
        ),
      List<Account>() => StringMultiFilter.keepEverything(),
      _ => null,
    };

    if (accountsFilterOverride != null) {
      setState(() {
        filter = filter.copyWithOptional(
          accounts: accountsFilterOverride == StringMultiFilter.keepEverything()
              ? Optional(null)
              : Optional(accountsFilterOverride),
        );
      });
    }
  }

  void onSelectCategories() async {
    final List<Category>? allCategories = CategoriesProvider.of(context).ready
        ? CategoriesProvider.of(context).categories
        : null;

    final Optional<List<Category>>? categories = await showModalBottomSheet(
      context: context,
      builder: (context) => SelectMultiCategorySheet(
        categories: ObjectBox().getCategories(),
        selectedUuids: filter.categories?.filter(
          allCategories?.map((category) => category.uuid).toList() ?? [],
        ),
      ),
      isScrollControlled: true,
    );

    final Optional<StringMultiFilter>? categoriesFilter = categories == null
        ? null
        : switch (categories.value) {
            List<Category> categoriesList => Optional<StringMultiFilter>(
              StringMultiFilter.whitelist(
                categoriesList.map((category) => category.uuid).toList(),
              ),
            ),
            null => Optional<StringMultiFilter>(null),
          };

    setState(() {
      filter = filter.copyWithOptional(categories: categoriesFilter);
    });
  }

  void onSelectTags() async {
    final List<TransactionTag> allTags = TransactionTagsProvider.of(
      context,
    ).tags;

    final List<TransactionTag>? tags =
        await showModalBottomSheet<List<TransactionTag>>(
          context: context,
          builder: (context) => SelectTransactionTagsSheet(
            tags: allTags,
            initialTagUuids: filter.tags?.filter(
              allTags.map((tag) => tag.uuid).toList(),
            ),
          ),
          isScrollControlled: true,
        );

    if (tags != null) {
      setState(() {
        filter = filter.copyWithOptional(
          tags: Optional(.whitelist(tags.map((tag) => tag.uuid).toList())),
        );
      });
    }
  }

  void onSelectType() async {
    final List<TransactionType>? types =
        await showModalBottomSheet<List<TransactionType>>(
          context: context,
          builder: (context) =>
              SelectMultiTransactionTypeSheet(currentlySelected: filter.types),
          isScrollControlled: true,
        );

    if (types != null) {
      setState(() {
        filter = filter.copyWithOptional(types: Optional(types));
      });
    }
  }

  void onSelectCurrency() async {
    final Set<String> possibleCurrencies = ObjectBox()
        .getAccounts()
        .map((account) => account.currency)
        .toSet();

    final List<String>? newCurrencies =
        await showModalBottomSheet<List<String>>(
          context: context,
          builder: (context) => SelectMultiCurrencySheet(
            currencies: possibleCurrencies
                .map(
                  (code) => CurrencyRegistryService().groupedCurrencies[code],
                )
                .nonNulls
                .toList(),
            currentlySelected: filter.currencies,
          ),
          isScrollControlled: true,
        );

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
          builder: (context) => SelectGroupRangeSheet(selected: filter.groupBy),
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
        range: Optional(newTransactionFilterTimeRange),
      );
    });
  }

  void onSelectHasAttachments() async {
    final Optional<bool>? hasAttachments = await showModalBottomSheet(
      context: context,
      builder: (context) => SelectHasAttachmentSheet(),
    );

    if (hasAttachments == null || !mounted) return;

    setState(() {
      filter = filter.copyWithOptional(hasAttachments: hasAttachments);
    });
  }

  void onSelectIsPending() async {
    final Optional<bool>? isPending = await showModalBottomSheet(
      context: context,
      builder: (context) => SelectIsPendingSheet(),
    );

    if (isPending == null || !mounted) return;

    setState(() {
      filter = filter.copyWithOptional(isPending: isPending);
    });
  }

  void _updateShowCurrencyFilterChip() {
    showCurrencyFilterChip = TransitiveLocalPreferences().usesMultipleCurrencies
        .get();
    if (!mounted) return;
    setState(() {});
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
