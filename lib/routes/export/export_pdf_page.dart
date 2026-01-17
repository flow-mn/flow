import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/services/accounts.dart";
import "package:flow/sync/export/export_pdf.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/directional_chevron.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/transaction_filter_head/select_multi_account_sheet.dart";
import "package:flow/utils/time_and_range.dart";
import "package:flow/widgets/transaction_filter_head/select_multi_category_sheet.dart";
import "package:flutter/foundation.dart" hide Category;
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class ExportPdfPage extends StatefulWidget {
  const ExportPdfPage({super.key});

  @override
  State<ExportPdfPage> createState() => _ExportPdfPageState();
}

class _ExportPdfPageState extends State<ExportPdfPage> {
  final List<Account> _accounts = [];
  final Set<String> _selectedAccounts = {};

  final List<Category> _categories = [];
  final Set<String> _selectedCategories = {};

  bool _useA4 = true;
  TimeRange _range = TimeRange.allTime();

  bool? get allSelected {
    if (_selectedAccounts.isEmpty) return false;

    return setEquals(
          _selectedAccounts,
          _accounts.map((account) => account.uuid).toSet(),
        )
        ? true
        : null;
  }

  bool ready = false;

  @override
  void initState() {
    super.initState();

    _categories.addAll(ObjectBox().getCategories());
    _selectedCategories.addAll(_categories.map((category) => category.uuid));

    AccountsService()
        .getAll()
        .then((accounts) {
          _accounts.addAll(accounts);
          _selectedAccounts.addAll(accounts.map((account) => account.uuid));
        })
        .catchError((_) {})
        .whenComplete(() {
          ready = true;
          if (!mounted) return;
          setState(() {});
        });
  }

  @override
  Widget build(BuildContext context) {
    final bool canGenerate =
        _selectedAccounts.isNotEmpty &&
        _range.duration.abs() >= Duration(seconds: 1);

    return Scaffold(
      appBar: AppBar(title: Text("sync.export.asPDF".t(context))),
      body: SafeArea(child: buildChild(context)),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Spacer(),
              Button(
                onTap: canGenerate ? _generatePDF : null,
                trailing: DirectionalChevron(),
                child: Text("general.confirm".t(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildChild(BuildContext context) {
    if (!ready) {
      return Spinner.center();
    }

    if (_accounts.isEmpty) {
      return Center(child: Text("error.sync.exportFailed".t(context)));
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Frame.standalone(
                  child: InfoText(
                    child: Text("sync.export.asPDF.description".t(context)),
                  ),
                ),
                ListTile(
                  leading: Icon(Symbols.wallet_rounded),
                  title: Text("sync.export.pdf.accounts".t(context)),
                  subtitle: Text(
                    "sync.export.pdf.accounts.selected".tr({
                      "n": _selectedAccounts.length.toString(),
                      "total": _accounts.length.toString(),
                    }),
                  ),
                  onTap: _selectAccounts,
                  trailing: DirectionalChevron(),
                ),
                ListTile(
                  leading: Icon(Symbols.category_rounded),
                  title: Text("sync.export.pdf.categories".t(context)),
                  subtitle: Text(
                    "sync.export.pdf.categories.selected".tr({
                      "n": _selectedCategories.length.toString(),
                      "total": _categories.length.toString(),
                    }),
                  ),
                  onTap: _selectCategories,
                  trailing: DirectionalChevron(),
                ),
                ListTile(
                  leading: Icon(Symbols.schedule_rounded),
                  title: Text("sync.export.pdf.timeRange".t(context)),
                  subtitle: Text(rangeText),
                  onTap: _selectRange,
                  trailing: DirectionalChevron(),
                ),
                ListTile(
                  leading: Icon(Symbols.expand_content_rounded),
                  title: Text("sync.export.pdf.size".t(context)),
                  subtitle: Text(_useA4 ? "A4" : "Letter"),
                  onTap: _selectPaperSize,
                  trailing: DirectionalChevron(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  void selectAll() {
    if (allSelected == true) {
      _selectedAccounts.clear();
    } else {
      _selectedAccounts.addAll(_accounts.map((account) => account.uuid));
    }

    setState(() {});
  }

  void _selectAccounts() async {
    final List<Account>? selected = await showModalBottomSheet(
      context: context,
      builder: (context) => SelectMultiAccountSheet(
        accounts: _accounts,
        selectedUuids: _selectedAccounts.toList(),
      ),
      isScrollControlled: true,
    );

    if (selected == null) return;

    setState(() {
      _selectedAccounts.clear();
      _selectedAccounts.addAll(selected.map((account) => account.uuid));
    });
  }

  void _selectCategories() async {
    final List<Category>? selected = await showModalBottomSheet(
      context: context,
      builder: (context) => SelectMultiCategorySheet(
        categories: _categories,
        selectedUuids: _selectedCategories.toList(),
      ),
      isScrollControlled: true,
    );

    if (selected == null) return;

    setState(() {
      _selectedCategories.clear();
      _selectedCategories.addAll(selected.map((category) => category.uuid));
    });
  }

  void _selectRange() async {
    final TimeRange? newRange = await showTimeRangePickerSheet(context);

    if (newRange == null) return;

    setState(() {
      _range = newRange;
    });
  }

  void _selectPaperSize() async {
    final bool? useA4 = await showModalBottomSheet(
      context: context,
      builder: (context) => ModalSheet.scrollable(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text("A4"), onTap: () => context.pop(true)),
            ListTile(title: Text("Letter"), onTap: () => context.pop(false)),
          ],
        ),
      ),
      isScrollControlled: true,
    );

    if (useA4 == null) return;
    _useA4 = useA4;

    if (mounted) {
      setState(() {});
    }
  }

  String get rangeText {
    if (_range.from <= Moment.minValue && _range.to >= Moment.maxValue) {
      return "select.timeRange.allTime".t(context);
    }

    return _range.format(useRelative: false);
  }

  void _generatePDF() async {
    context.pushReplacement(
      "/export/pdf",
      extra: ExportPdfOptions(
        timeRange: _range,
        whitelistedAccounts: _accounts
            .where((account) => _selectedAccounts.contains(account.uuid))
            .toList(),
        whitelistedCategories: _categories
            .where((category) => _selectedCategories.contains(category.uuid))
            .toList(),
        useA4: _useA4,
      ),
    );
  }
}
