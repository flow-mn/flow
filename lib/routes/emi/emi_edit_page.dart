import "package:flow/entity/emi.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction/type.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/providers/accounts_provider.dart";
import "package:flow/services/emi.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/optional.dart";
import "package:flow/utils/extensions/toast.dart";
import "package:flow/widgets/general/directional_chevron.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/form_close_button.dart";
import "package:flow/widgets/sheets/select_account_sheet.dart";
import "package:flow/widgets/sheets/select_category_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:intl/intl.dart";

class EmiEditPage extends StatefulWidget {
  final int emiId;

  bool get isNew => emiId == 0;

  const EmiEditPage({super.key, required this.emiId});
  const EmiEditPage.create({super.key}) : emiId = 0;
  const EmiEditPage.edit({super.key, required this.emiId});

  @override
  State<EmiEditPage> createState() => _EmiEditPageState();
}

class _EmiEditPageState extends State<EmiEditPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _totalAmountController;
  late final TextEditingController _installmentAmountController;
  late final TextEditingController _totalInstallmentsController;

  DateTime _startDate = DateTime.now();
  Account? _selectedAccount;
  Category? _selectedCategory;

  late Emi? _currentlyEditing;
  String? error;

  @override
  void initState() {
    super.initState();

    _currentlyEditing = widget.isNew
        ? null
        : ObjectBox().box<Emi>().get(widget.emiId);

    if (!widget.isNew && _currentlyEditing == null) {
      error = "EMI tracker with id ${widget.emiId} was not found";
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _totalAmountController = TextEditingController();
      _installmentAmountController = TextEditingController();
      _totalInstallmentsController = TextEditingController();
    } else {
      _titleController = TextEditingController(text: _currentlyEditing?.title);
      _descriptionController = TextEditingController(text: _currentlyEditing?.description);
      _totalAmountController = TextEditingController(
        text: _currentlyEditing != null ? _currentlyEditing!.totalAmount.toString() : "",
      );
      _installmentAmountController = TextEditingController(
        text: _currentlyEditing != null ? _currentlyEditing!.installmentAmount.toString() : "",
      );
      _totalInstallmentsController = TextEditingController(
        text: _currentlyEditing != null ? _currentlyEditing!.totalInstallments.toString() : "",
      );

      if (_currentlyEditing != null) {
        _startDate = _currentlyEditing!.startDate;
        _selectedAccount = _currentlyEditing!.account.target;
        _selectedCategory = _currentlyEditing!.category.target;
      } else {
        // Find primary account or first active account as default
        final accounts = ObjectBox().box<Account>().getAll();
        if (accounts.isNotEmpty) {
          _selectedAccount = accounts.firstWhere(
            (element) => !element.archived,
            orElse: () => accounts.first,
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _totalAmountController.dispose();
    _installmentAmountController.dispose();
    _totalInstallmentsController.dispose();
    super.dispose();
  }

  bool hasChanged() {
    if (widget.isNew) {
      return _titleController.text.isNotEmpty ||
          _descriptionController.text.isNotEmpty ||
          _totalAmountController.text.isNotEmpty ||
          _installmentAmountController.text.isNotEmpty ||
          _totalInstallmentsController.text.isNotEmpty;
    }

    final emi = _currentlyEditing!;
    return _titleController.text != emi.title ||
        _descriptionController.text != (emi.description ?? "") ||
        _selectedAccount?.id != emi.account.target?.id ||
        _selectedCategory?.id != emi.category.target?.id;
  }

  Future<void> selectAccount() async {
    final accounts = AccountsProvider.of(context).activeAccounts;
    if (accounts.isEmpty) return;

    final Account? result = await showModalBottomSheet<Account>(
      context: context,
      builder: (context) => SelectAccountSheet(
        accounts: accounts,
        currentlySelectedAccountId: _selectedAccount?.id,
        showBalance: true,
      ),
      isScrollControlled: true,
    );

    if (result != null) {
      setState(() {
        _selectedAccount = result;
      });
    }
  }

  Future<void> selectCategory() async {
    final Optional<Category>? result = await showModalBottomSheet<Optional<Category>>(
      context: context,
      builder: (context) => SelectCategorySheet(
        currentlySelectedCategoryId: _selectedCategory?.id,
        transactionType: TransactionType.expense,
      ),
      isScrollControlled: true,
    );

    if (result != null) {
      setState(() {
        _selectedCategory = result.value;
      });
    }
  }

  Future<void> pickStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccount == null) {
      context.showToast(text: "transaction.edit.selectAccount".t(context));
      return;
    }

    final double? totalAmount = double.tryParse(_totalAmountController.text);
    final double? installmentAmount = double.tryParse(_installmentAmountController.text);
    final int? totalInstallments = int.tryParse(_totalInstallmentsController.text);

    if (widget.isNew) {
      if (totalAmount == null || totalAmount <= 0) {
        context.showToast(text: "emi.invalidAmount".t(context));
        return;
      }
      if (installmentAmount == null || installmentAmount <= 0) {
        context.showToast(text: "emi.invalidInstallment".t(context));
        return;
      }
      if (totalInstallments == null || totalInstallments <= 0) {
        context.showToast(text: "emi.invalidInstallmentsCount".t(context));
        return;
      }
    }

    try {
      if (widget.isNew) {
        final emi = Emi(
          title: _titleController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          totalAmount: totalAmount!,
          installmentAmount: installmentAmount!,
          totalInstallments: totalInstallments!,
          remainingInstallments: totalInstallments,
          remainingAmount: totalAmount,
          startDate: _startDate,
          nextDueDate: _startDate,
        );
        emi.account.target = _selectedAccount;
        emi.category.target = _selectedCategory;

        await EmiService().upsertOne(emi);
        if (mounted) {
          context.showToast(text: "emi.create.success".t(context));
          context.pop();
        }
      } else {
        final emi = _currentlyEditing!;
        emi.title = _titleController.text;
        emi.description = _descriptionController.text.isEmpty ? null : _descriptionController.text;
        emi.account.target = _selectedAccount;
        emi.category.target = _selectedCategory;

        await EmiService().upsertOne(emi);
        if (mounted) {
          context.showToast(text: "emi.update.success".t(context));
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        context.showToast(text: "Something went wrong");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40.0,
        leading: FormCloseButton(canPop: () => !hasChanged()),
        title: Text(widget.isNew ? "emi.new".t(context) : "emi.edit".t(context)),
        actions: [
          IconButton(
            onPressed: save,
            icon: const Icon(Symbols.check_rounded),
            tooltip: "general.save".t(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextFormField(
                      controller: _titleController,
                      maxLength: 64,
                      decoration: InputDecoration(
                        labelText: "emi.title".t(context),
                        hintText: "Enter EMI title (e.g. iPhone 15 Finance)",
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Field cannot be empty";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextFormField(
                      controller: _descriptionController,
                      maxLength: 256,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: "emi.description".t(context),
                        hintText: "Enter description (optional)",
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  if (widget.isNew) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextFormField(
                        controller: _totalAmountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: "emi.totalAmount".t(context),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Field cannot be empty";
                          }
                          final val = double.tryParse(value);
                          if (val == null || val <= 0) {
                            return "emi.invalidAmount".t(context);
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextFormField(
                        controller: _installmentAmountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: "emi.installmentAmount".t(context),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Field cannot be empty";
                          }
                          final val = double.tryParse(value);
                          if (val == null || val <= 0) {
                            return "emi.invalidInstallment".t(context);
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextFormField(
                        controller: _totalInstallmentsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "emi.totalInstallments".t(context),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Field cannot be empty";
                          }
                          final val = int.tryParse(value);
                          if (val == null || val <= 0) {
                            return "emi.invalidInstallmentsCount".t(context);
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ListTile(
                      leading: const Icon(Symbols.calendar_today_rounded),
                      title: Text("emi.startDate".t(context)),
                      subtitle: Text(DateFormat.yMMMMd().format(_startDate)),
                      trailing: const LeChevron(),
                      onTap: pickStartDate,
                    ),
                  ] else ...[
                    // Read only displays for editing mode
                    ListTile(
                      leading: const Icon(Symbols.payments_rounded),
                      title: Text("emi.totalAmount".t(context)),
                      trailing: Text(
                        _currentlyEditing != null
                            ? _currentlyEditing!.totalAmount.toString()
                            : "",
                        style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Symbols.price_change_rounded),
                      title: Text("emi.installmentAmount".t(context)),
                      trailing: Text(
                        _currentlyEditing != null
                            ? _currentlyEditing!.installmentAmount.toString()
                            : "",
                        style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Symbols.tag_rounded),
                      title: Text("emi.totalInstallments".t(context)),
                      trailing: Text(
                        _currentlyEditing != null
                            ? _currentlyEditing!.totalInstallments.toString()
                            : "",
                        style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8.0),
                  ListTile(
                    leading: const Icon(Symbols.wallet_rounded),
                    title: Text("account".t(context)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedAccount?.name ?? "Select account",
                          style: context.textTheme.labelLarge,
                        ),
                        const SizedBox(width: 8.0),
                        const LeChevron(),
                      ],
                    ),
                    onTap: selectAccount,
                  ),
                  ListTile(
                    leading: const Icon(Symbols.category_rounded),
                    title: Text("category".t(context)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_selectedCategory != null) ...[
                          FlowIcon(
                            _selectedCategory!.icon,
                            colorScheme: _selectedCategory!.colorScheme,
                          ),
                          const SizedBox(width: 8.0),
                        ],
                        Text(
                          _selectedCategory?.name ?? "Select category",
                          style: context.textTheme.labelLarge,
                        ),
                        const SizedBox(width: 8.0),
                        const LeChevron(),
                      ],
                    ),
                    onTap: selectCategory,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
