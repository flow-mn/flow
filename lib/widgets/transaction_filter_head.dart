import 'package:flow/data/transactions_filter.dart';
import 'package:flow/entity/account.dart';
import 'package:flow/entity/category.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/actions.dart';
import 'package:flow/routes/new_transaction/select_multi_account_sheet.dart';
import 'package:flow/routes/new_transaction/select_multi_category_sheet.dart';
import 'package:flow/utils/optional.dart';
import 'package:flow/widgets/utils/time_and_range.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:moment_dart/moment_dart.dart';

class TransactionFilterHead extends StatefulWidget {
  final TransactionFilter current;

  final void Function(TransactionFilter) onChanged;

  const TransactionFilterHead({
    super.key,
    required this.onChanged,
    this.current = TransactionFilter.empty,
  });

  @override
  State<TransactionFilterHead> createState() => _TransactionFilterHeadState();
}

class _TransactionFilterHeadState extends State<TransactionFilterHead> {
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
  void didUpdateWidget(TransactionFilterHead oldWidget) {
    if (oldWidget.current != widget.current) {
      _filter = widget.current;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.0,
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              avatar: const Icon(Symbols.search_rounded),
              label: const Text("Search"),
              onSelected: onSelectRange,
              selected: _filter.keyword?.isNotEmpty == true,
            ),
            const SizedBox(width: 8.0),
            FilterChip(
              label: const Text("Time Range"),
              onSelected: onSelectRange,
              selected: _filter.range != null,
            ),
            const SizedBox(width: 8.0),
            FilterChip(
              label: const Text("Accounts"),
              onSelected: onSelectAccounts,
              selected: _filter.accounts?.isNotEmpty == true,
            ),
            const SizedBox(width: 8.0),
            FilterChip(
              label: const Text("Categories"),
              onSelected: onSelectCategories,
              selected: _filter.accounts?.isNotEmpty == true,
            ),
          ],
        ),
      ),
    );
  }

  void onSelectAccounts(bool _) async {
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
        _filter = _filter.copyWithOptional(accounts: Optional(accounts));
      });
    }
  }

  void onSelectCategories(bool _) async {
    final List<Category>? categories =
        await showModalBottomSheet<List<Category>>(
      context: context,
      builder: (context) => SelectMultiCategorySheet(
        categories: ObjectBox().getCategories(),
        selectedUuids:
            filter.cateogries?.map((category) => category.uuid).toList(),
      ),
      isScrollControlled: true,
    );

    if (categories != null) {
      setState(() {
        _filter = _filter.copyWithOptional(cateogries: Optional(categories));
      });
    }
  }

  void onSelectRange(bool _) async {
    final TimeRange? newRange =
        await showTimeRangePickerSheet(context, initialValue: _filter.range);

    if (!mounted || newRange == null) return;

    setState(() {
      _filter = _filter.copyWithOptional(range: Optional(newRange));
    });
  }
}
