import "package:flow/entity/budget.dart";
import "package:flow/entity/category.dart";
import "package:flow/form_validators.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/routes/error_page.dart";
import "package:flow/routes/transaction_page/input_amount_sheet.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/delete_button.dart";
import "package:flow/widgets/general/directional_chevron.dart";
import "package:flow/widgets/general/form_close_button.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/data/money.dart";
import "package:flow/widgets/sheets/select_currency_sheet.dart";
import "package:flow/widgets/time_range_selector.dart";
import "package:flow/widgets/transaction_filter_head/select_multi_category_sheet.dart";
import "package:flutter/foundation.dart" hide Category;
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class BudgetPage extends StatefulWidget {
  final int budgetId;

  bool get isNewBudget => budgetId == 0;

  const BudgetPage({super.key, required this.budgetId});
  const BudgetPage.create({super.key}) : budgetId = 0;

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  late final TextEditingController _nameTextController;

  late double _amount;
  late String _currency;
  late TimeRange _timeRange;
  late bool _renewAutomatically;
  late List<Category> _categories;

  Budget? _currentlyEditing;

  dynamic error;

  @override
  void initState() {
    super.initState();

    _currentlyEditing = widget.isNewBudget
        ? null
        : ObjectBox().box<Budget>().get(widget.budgetId);

    if (!widget.isNewBudget && _currentlyEditing == null) {
      error = "Budget with id ${widget.budgetId} was not found";
    } else {
      _nameTextController = TextEditingController(
        text: _currentlyEditing?.name,
      );
      _amount = _currentlyEditing?.amount ?? 0.0;
      _currency =
          _currentlyEditing?.currency ??
          UserPreferencesService().primaryCurrency;
      _timeRange =
          _currentlyEditing?.timeRange ??
          MonthTimeRange.fromDateTime(DateTime.now());
      _renewAutomatically = _currentlyEditing?.renewAutomatically ?? true;
      _categories = _currentlyEditing?.categories.toList() ?? [];
    }
  }

  @override
  void dispose() {
    _nameTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) return const ErrorPage();

    const EdgeInsets contentPadding = EdgeInsets.symmetric(horizontal: 16.0);

    final bool pageable = _timeRange is PageableRange;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40.0,
        leading: FormCloseButton(canPop: () => !hasChanged()),
        actions: [
          IconButton(
            onPressed: () => save(),
            icon: const Icon(Symbols.check_rounded),
            tooltip: "general.save".t(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: .start,
              children: [
                const SizedBox(height: 16.0),
                Padding(
                  padding: contentPadding,
                  child: TextFormField(
                    controller: _nameTextController,
                    validator: validateNameField,
                    decoration: InputDecoration(
                      label: Text("budget.name".t(context)),
                      focusColor: context.colorScheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                ListTile(
                  title: Text("budget.amount".t(context)),
                  leading: const Icon(Symbols.money_bag_rounded),
                  trailing: MoneyText(Money(_amount, _currency)),
                  onTap: inputAmount,
                ),
                ListTile(
                  title: Text("currency".t(context)),
                  leading: const Icon(Symbols.universal_currency_alt_rounded),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4.0,
                    children: [Text(_currency), const LeChevron()],
                  ),
                  onTap: selectCurrency,
                ),
                ListTile(
                  title: Text("budget.categories".t(context)),
                  leading: const Icon(Symbols.category_rounded),
                  subtitle: Text(
                    _categories.isEmpty
                        ? "budget.categories.all".t(context)
                        : _categories
                              .map((category) => category.name)
                              .join(", "),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const LeChevron(),
                  onTap: selectCategories,
                ),
                const SizedBox(height: 8.0),
                Frame(
                  child: InfoText(
                    child: Text("budget.categories.description".t(context)),
                  ),
                ),
                const SizedBox(height: 16.0),
                ListHeader("budget.period".t(context)),
                const SizedBox(height: 8.0),
                Frame(
                  child: TimeRangeSelector(
                    initialValue: _timeRange,
                    onChanged: updateTimeRange,
                  ),
                ),
                CheckboxListTile(
                  value: pageable && _renewAutomatically,
                  onChanged: pageable ? updateRenewAutomatically : null,
                  title: Text("budget.renewAutomatically".t(context)),
                ),
                const SizedBox(height: 8.0),
                Frame(
                  child: InfoText(
                    child: Text(
                      "budget.renewAutomatically.description".t(context),
                    ),
                  ),
                ),
                if (_currentlyEditing != null) ...[
                  const SizedBox(height: 36.0),
                  DeleteButton(
                    onTap: _deleteBudget,
                    label: Text("budget.delete".t(context)),
                  ),
                  const SizedBox(height: 16.0),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> inputAmount() async {
    final double? result = await showModalBottomSheet<double>(
      context: context,
      builder: (context) => InputAmountSheet(
        initialAmount: _amount.abs(),
        currency: _currency,
        title: "budget.amount".t(context),
        allowNegative: false,
        lockSign: true,
      ),
      isScrollControlled: true,
    );

    if (result == null) return;

    _amount = result.abs();

    if (mounted) setState(() {});
  }

  Future<void> selectCurrency() async {
    final String? result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SelectCurrencySheet(currentlySelected: _currency),
      isScrollControlled: true,
    );

    if (result == null) return;

    _currency = result;

    if (mounted) setState(() {});
  }

  Future<void> selectCategories() async {
    final Optional<List<Category>>? result =
        await showModalBottomSheet<Optional<List<Category>>>(
          context: context,
          builder: (context) => SelectMultiCategorySheet(
            categories: ObjectBox().getCategories(),
            selectedUuids: _categories.map((category) => category.uuid).toList(),
          ),
          isScrollControlled: true,
        );

    if (result?.value case List<Category> newCategories) {
      _categories = newCategories;
    }

    if (mounted) setState(() {});
  }

  void updateTimeRange(TimeRange newRange) {
    setState(() {
      _timeRange = newRange;
    });
  }

  void updateRenewAutomatically(bool? value) {
    if (value == null) return;

    setState(() {
      _renewAutomatically = value;
    });
  }

  bool hasChanged() {
    if (_currentlyEditing case Budget budget) {
      return budget.name != _nameTextController.text.trim() ||
          budget.amount != _amount ||
          budget.currency != _currency ||
          budget.range != _timeRange.toString() ||
          budget.renewAutomatically != _renewAutomatically ||
          !setEquals(
            budget.categories.map((category) => category.uuid).toSet(),
            _categories.map((category) => category.uuid).toSet(),
          );
    }

    return _nameTextController.text.trim().isNotEmpty ||
        _amount != 0.0 ||
        _categories.isNotEmpty;
  }

  void save() {
    if (_formKey.currentState?.validate() != true) return;

    if (_amount <= 0.0) {
      context.showErrorToast(error: "budget.amount.required".t(context));
      return;
    }

    final String trimmed = _nameTextController.text.trim();

    if (_currentlyEditing case Budget budget) {
      budget
        ..name = trimmed
        ..amount = _amount
        ..currency = _currency
        ..timeRange = _timeRange
        ..renewAutomatically = _renewAutomatically
        ..setCategories(_categories);

      ObjectBox().box<Budget>().put(budget, mode: PutMode.update);

      context.pop();
      return;
    }

    final Budget budget = Budget(
      name: trimmed,
      amount: _amount,
      currency: _currency,
      range: _timeRange.toString(),
      renewAutomatically: _renewAutomatically,
    )..setCategories(_categories);

    ObjectBox().box<Budget>().put(budget, mode: PutMode.insert);

    context.pop();
  }

  String? validateNameField(String? value) {
    final requiredValidationError = validateRequiredField(value);
    if (requiredValidationError != null) {
      return requiredValidationError.t(context);
    }

    final String trimmed = value!.trim();

    final Query<Budget> sameNameQuery = ObjectBox()
        .box<Budget>()
        .query(
          Budget_.name
              .equals(trimmed)
              .and(Budget_.id.notEquals(_currentlyEditing?.id ?? 0)),
        )
        .build();

    final bool isNameUnique = sameNameQuery.count() == 0;

    sameNameQuery.close();

    if (!isNameUnique) {
      return "error.input.duplicate.accountName".t(context, trimmed);
    }

    return null;
  }

  Future<void> _deleteBudget() async {
    if (_currentlyEditing == null) return;

    final bool? confirmation = await context.showConfirmationSheet(
      isDeletionConfirmation: true,
      title: "general.delete.confirmName".t(context, _currentlyEditing!.name),
      child: Text("budget.delete.description".t(context)),
    );

    if (confirmation == true) {
      ObjectBox().box<Budget>().remove(_currentlyEditing!.id);

      if (mounted) {
        context.pop();
        GoRouter.of(context).popUntil((route) {
          return route.path != "/budgets/:id";
        });
      }
    }
  }
}
