import 'package:flow/entity/account.dart';
import 'package:flow/entity/category.dart';
import 'package:flow/entity/transaction.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/objectbox.g.dart';
import 'package:flow/prefs.dart';
import 'package:flow/routes/new_transaction/input_amount_sheet.dart';
import 'package:flow/routes/new_transaction/select_account_sheet.dart';
import 'package:flow/routes/new_transaction/select_category_sheet.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/utils/toast.dart';
import 'package:flow/utils/value_or.dart';
import 'package:flow/widgets/general/flow_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:moment_dart/moment_dart.dart';

class TransactionPage extends StatefulWidget {
  /// Transaction Object ID
  final int transactionId;

  bool get isNewTransaction => transactionId == 0;

  const TransactionPage.create({super.key}) : transactionId = 0;
  const TransactionPage.edit({super.key, required this.transactionId});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  late final TextEditingController _titleTextController;
  late double _amount;

  late final Transaction? _currentlyEditing;

  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _selectAccountFocusNode = FocusNode();

  dynamic error;

  Account? _selectedAccount;
  Category? _selectedCategory;
  late DateTime _transactionDate;

  QueryBuilder<Account> _accountsQueryBuilder() => ObjectBox()
      .box<Account>()
      .query()
      .order(Account_.lastUsedDate, flags: Order.descending);

  QueryBuilder<Category> _categoriesQueryBuilder() =>
      ObjectBox().box<Category>().query().order(Category_.name);

  @override
  void initState() {
    super.initState();

    /// Transaction we're editing.
    _currentlyEditing = widget.isNewTransaction
        ? null
        : ObjectBox().box<Transaction>().get(widget.transactionId);

    if (!widget.isNewTransaction && _currentlyEditing == null) {
      error = "Transaction with id ${widget.transactionId} was not found";
    } else {
      _titleTextController =
          TextEditingController(text: _currentlyEditing?.title);
      _amount = _currentlyEditing?.amount ?? 0;
      _selectedAccount = _currentlyEditing?.account.target;
      _selectedCategory = _currentlyEditing?.category.target;
      _transactionDate = _currentlyEditing?.transactionDate ?? DateTime.now();
    }

    if (widget.isNewTransaction) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        selectAccount();
      });
    }
  }

  @override
  void dispose() {
    _titleTextController.dispose();
    _titleFocusNode.dispose();
    _selectAccountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const contentPadding = EdgeInsets.symmetric(horizontal: 16.0);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () => pop(),
        const SingleActivator(LogicalKeyboardKey.enter, control: true): () =>
            save(),
        const SingleActivator(LogicalKeyboardKey.numpadEnter, control: true):
            () => save(),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Symbols.close_rounded),
            ),
            actions: [
              IconButton(
                onPressed: () => save(),
                icon: const Icon(Symbols.check_rounded),
              )
            ],
            leadingWidth: 40.0,
            title: Text((widget.isNewTransaction
                    ? "transaction.new"
                    : "transaction.edit")
                .t(context)),
            titleTextStyle: context.textTheme.bodyLarge,
            centerTitle: true,
            backgroundColor: context.colorScheme.background,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Form(
                canPop: !hasChanged(),
                child: Column(
                  children: [
                    const SizedBox(height: 24.0),
                    // Center(
                    //     child: Text("Untitled transaction",
                    //         style: context.textTheme.headlineMedium)),
                    Padding(
                      padding: contentPadding,
                      child: TextField(
                        style: context.textTheme.headlineMedium,
                        controller: _titleTextController,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: "transaction.fallbackTitle".t(context),
                        ),
                        textInputAction: TextInputAction.next,
                        focusNode: _titleFocusNode,
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    Center(
                      child: InkWell(
                        onTap: inputAmount,
                        child: Center(
                          child: Text(
                            _amount.formatMoney(
                              currency: _selectedAccount?.currency,
                            ),
                            style: context.textTheme.displayMedium,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: contentPadding,
                        child: Text(
                          "account".t(context),
                          style: context.textTheme.titleSmall,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: _selectedAccount == null
                          ? null
                          : FlowIcon(
                              _selectedAccount!.icon,
                              plated: true,
                            ),
                      title: Text(_selectedAccount?.name ??
                          "transaction.edit.selectAccount".t(context)),
                      subtitle: _selectedAccount == null
                          ? null
                          : Text(_selectedAccount!.balance.formatMoney(
                              currency: _selectedAccount!.currency,
                            )),
                      onTap: () => selectAccount(),
                      trailing: _selectedAccount == null
                          ? const Icon(Symbols.chevron_right)
                          : null,
                      focusNode: _selectAccountFocusNode,
                    ),
                    const SizedBox(height: 16.0),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: contentPadding,
                        child: Text(
                          "category".t(context),
                          style: context.textTheme.titleSmall,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: _selectedCategory == null
                          ? null
                          : FlowIcon(
                              _selectedCategory!.icon,
                              plated: true,
                            ),
                      title: Text(_selectedCategory?.name ??
                          "transaction.edit.selectCategory".t(context)),
                      // subtitle: _selectedAccount == null
                      //     ? null
                      //     : Text(_selectedAccount!.balance.money),
                      onTap: () => selectCategory(),
                      trailing: _selectedCategory == null
                          ? const Icon(Symbols.chevron_right)
                          : null,
                    ),
                    const SizedBox(height: 16.0),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: contentPadding,
                        child: Text(
                          "transaction.date".t(context),
                          style: context.textTheme.titleSmall,
                        ),
                      ),
                    ),
                    ListTile(
                      // leading: _transactionDate == null
                      //     ? null
                      //     : Icon(_selectedCategory!.icon),
                      title: Text(_transactionDate.toMoment().LLL),
                      // subtitle: _selectedAccount == null
                      //     ? null
                      //     : Text(_selectedAccount!.balance.money),
                      onTap: () => selectTransactionDate(),
                      trailing: _selectedCategory == null
                          ? const Icon(Symbols.chevron_right)
                          : null,
                    ),
                    if (_currentlyEditing != null) ...[
                      const SizedBox(height: 24.0),
                      Text(
                        "${"transaction.createdDate".t(context)} ${_currentlyEditing!.createdDate.format(payload: "LLL", forceLocal: true)}",
                        style: context.textTheme.bodySmall?.semi(context),
                      )
                    ],
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void inputAmount() async {
    await LocalPreferences().updateTransitiveProperties();
    final hideCurrencySymbol =
        !LocalPreferences().transitiveUsesSingleCurrency.get();

    if (!mounted) return;

    final result = await showModalBottomSheet<double>(
      context: context,
      builder: (context) => InputAmountSheet(
        initialAmount: _amount,
        currency: _selectedAccount?.currency,
        hideCurrencySymbol: _selectedAccount == null && hideCurrencySymbol,
      ),
      isScrollControlled: true,
    );

    setState(() {
      _amount = result ?? _amount;
    });

    if (mounted && widget.isNewTransaction && result != null) {
      FocusScope.of(context).requestFocus(_titleFocusNode);
    }
  }

  void selectAccount() async {
    final accounts = _accountsQueryBuilder().build().find();

    final result = await showModalBottomSheet<Account>(
      context: context,
      builder: (context) => SelectAccountSheet(
        accounts: accounts,
        currentlySelectedAccountId: _selectedAccount?.id,
      ),
      isScrollControlled: true,
    );

    setState(() {
      _selectedAccount = result ?? _selectedAccount;
    });

    if (widget.isNewTransaction && result != null) selectCategory();
  }

  void selectCategory() async {
    final categories = _categoriesQueryBuilder().build().find();

    if (categories.isEmpty) return;

    final result = await showModalBottomSheet<ValueOr<Category>>(
      context: context,
      builder: (context) => SelectCategorySheet(
        categories: categories,
        currentlySelectedCategoryId: _selectedCategory?.id,
      ),
      isScrollControlled: true,
    );

    if (result != null) {
      setState(() {
        _selectedCategory = result.value;
      });
    }

    if (widget.isNewTransaction && result != null) inputAmount();
  }

  void selectTransactionDate() async {
    final result = await showDatePicker(
      context: context,
      firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _transactionDate,
    );

    setState(() {
      _transactionDate = result ?? _transactionDate;
    });

    if (!mounted || result == null) return;

    final timeResult = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_transactionDate),
    );

    if (timeResult == null) return;

    setState(() {
      _transactionDate = _transactionDate.copyWith(
        hour: timeResult.hour,
        minute: timeResult.minute,
        second: 0,
        microsecond: 0,
        millisecond: 0,
      );
    });
  }

  void update({required String formattedTitle}) async {
    if (_currentlyEditing == null) return;

    _currentlyEditing!.setCategory(_selectedCategory);
    _currentlyEditing!.setAccount(_selectedAccount);
    _currentlyEditing!.title = formattedTitle;
    _currentlyEditing!.amount = _amount;

    ObjectBox().box<Transaction>().put(
          _currentlyEditing!,
          mode: PutMode.update,
        );

    context.pop();
  }

  void save() {
    if (_selectedAccount == null) {
      context.showErrorToast(
        error: "error.transaction.missingAccount".t(context),
      );
      _selectAccountFocusNode.requestFocus();
      return;
    }

    final String trimmed = _titleTextController.text.trim();
    final String formattedTitle =
        trimmed.isNotEmpty ? trimmed : "transaction.fallbackTitle".t(context);

    if (_currentlyEditing != null) {
      return update(formattedTitle: formattedTitle);
    }

    _selectedAccount!.createTransaction(
      amount: _amount,
      title: formattedTitle,
      category: _selectedCategory,
    );

    context.pop();
  }

  bool hasChanged() {
    if (_currentlyEditing != null) {
      return _currentlyEditing!.amount != _amount ||
          (_currentlyEditing!.title ?? "") != _titleTextController.text;
    }

    return _amount != 0 || _titleTextController.text.isNotEmpty;
  }

  void pop() {
    context.pop();
  }
}
