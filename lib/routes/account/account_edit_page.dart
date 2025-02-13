import "dart:async";
import "dart:developer";

import "package:flow/data/flow_icon.dart";
import "package:flow/data/money.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/backup_entry.dart";
import "package:flow/form_validators.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/routes/new_transaction/input_amount_sheet.dart";
import "package:flow/services/transactions.dart";
import "package:flow/sync/export.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/account/update_balance_options_sheet.dart";
import "package:flow/widgets/delete_button.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/form_close_button.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/select_currency_sheet.dart";
import "package:flow/widgets/select_flow_icon_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class AccountEditPage extends StatefulWidget {
  /// Account Object ID
  final int accountId;

  bool get isNewAccount => accountId == 0;

  const AccountEditPage({super.key, required this.accountId});
  const AccountEditPage.create({
    super.key,
  }) : accountId = 0;

  @override
  State<AccountEditPage> createState() => _AccountEditPageState();
}

class _AccountEditPageState extends State<AccountEditPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  late final TextEditingController _nameTextController;

  final FocusNode _editNameFocusNode = FocusNode();

  late String _currency;
  late FlowIconData? _iconData;
  late bool _excludeFromTotalBalance;

  late double _balance;

  /// Transaction date of the diff transaction is to be inserted with [_balance]
  ///
  /// If null, the transaction will be inserted with the current date
  ///
  /// This allows users to update their balance at a specific date
  DateTime? _updateBalanceAt;

  late Account? _currentlyEditing;

  bool _editingName = false;
  bool _archived = false;

  String get iconCodeOrError =>
      _iconData?.toString() ??
      FlowIconData.icon(Symbols.wallet_rounded).toString();

  dynamic error;

  @override
  void initState() {
    super.initState();

    _currentlyEditing = widget.isNewAccount
        ? null
        : ObjectBox().box<Account>().get(widget.accountId);

    if (!widget.isNewAccount && _currentlyEditing == null) {
      error = "Account with id ${widget.accountId} was not found";
    } else {
      _nameTextController =
          TextEditingController(text: _currentlyEditing?.name);
      _balance = _currentlyEditing?.balance.amount ?? 0.0;
      _currency = _currentlyEditing?.currency ??
          LocalPreferences().getPrimaryCurrency();
      _iconData = _currentlyEditing?.icon;
      _excludeFromTotalBalance =
          _currentlyEditing?.excludeFromTotalBalance ?? false;
      _archived = _currentlyEditing?.archived ?? false;
    }

    _editNameFocusNode.addListener(() {
      if (!_editNameFocusNode.hasFocus) {
        toggleEditName(false);
      }
    });
  }

  @override
  void dispose() {
    _editNameFocusNode.dispose();
    _nameTextController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const contentPadding = EdgeInsets.symmetric(horizontal: 16.0);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40.0,
        leading: FormCloseButton(
          canPop: () => !hasChanged(),
        ),
        actions: [
          IconButton(
            onPressed: () => save(),
            icon: const Icon(Symbols.check_rounded),
            tooltip: "general.save".t(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 16.0),
                Padding(
                  padding: contentPadding,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FlowIcon(
                            _iconData ??
                                FlowIconData.icon(Symbols.wallet_rounded),
                            size: 64.0,
                            plated: true,
                            onTap: selectIcon,
                          ),
                          TextButton(
                            onPressed: selectIcon,
                            child: Text(
                              "flowIcon.change".t(context),
                              style: context.textTheme.labelSmall?.copyWith(
                                color: context.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _nameTextController,
                                    focusNode: _editNameFocusNode,
                                    maxLength: Account.maxNameLength,
                                    decoration: InputDecoration(
                                      hintText: "account.name".t(context),
                                      focusColor: context.colorScheme.secondary,
                                      isDense: true,
                                      border: _editingName
                                          ? null
                                          : InputBorder.none,
                                      counter: const SizedBox.shrink(),
                                    ),
                                    onTap: () => toggleEditName(true),
                                    onFieldSubmitted: (_) =>
                                        toggleEditName(false),
                                    readOnly: !_editingName,
                                    validator: validateNameField,
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                IconButton(
                                  icon: _editingName
                                      ? const Icon(Symbols.done_rounded)
                                      : const Icon(Symbols.edit_rounded),
                                  onPressed: toggleEditName,
                                )
                              ],
                            ),
                            if (!widget.isNewAccount)
                              Text(
                                _currency,
                                style:
                                    context.textTheme.labelLarge?.semi(context),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),
                InkWell(
                  borderRadius: BorderRadius.circular(16.0),
                  onTap: updateBalance,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: contentPadding,
                          child: Text(
                            Money(_balance, _currency).formatMoney(),
                            style: context.textTheme.displayMedium,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          "account.updateBalance".t(context),
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                CheckboxListTile /*.adaptive*/ (
                  value: _excludeFromTotalBalance,
                  onChanged: updateBalanceExclusion,
                  title: Text("account.excludeFromTotalBalance".t(context)),
                ),
                if (!widget.isNewAccount)
                  CheckboxListTile /*.adaptive*/ (
                    value: _archived,
                    onChanged: updateArchived,
                    title: Text("account.archive".t(context)),
                  ),
                const SizedBox(height: 8.0),
                Frame(
                  child: InfoText(
                    child: Text(
                      "account.archive.description".t(context),
                    ),
                  ),
                ),
                if (widget.isNewAccount)
                  ListTile(
                    title: Text("currency".t(context)),
                    trailing: Text(
                      _currency,
                      style: context.textTheme.labelLarge,
                    ),
                    onTap: selectCurrency,
                  ),
                if (_currentlyEditing != null && _archived) ...[
                  const SizedBox(height: 80.0),
                  DeleteButton(
                    onTap: _deleteAccount,
                    label: Text("account.delete".t(context)),
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

  void updateBalance() async {
    final Optional<DateTime>? updateAtResult =
        await showModalBottomSheet<Optional<DateTime>>(
      context: context,
      builder: (context) => UpdateBalanceOptionsSheet(),
    );

    if (updateAtResult == null || !mounted) {
      _updateBalanceAt = null;
      return;
    }

    _updateBalanceAt = updateAtResult.value;

    final result = await showModalBottomSheet<double>(
      context: context,
      builder: (context) => InputAmountSheet(
        initialAmount: _balance,
        currency: _currency,
      ),
      isScrollControlled: true,
    );

    if (result == null) return;
    if (!mounted) return;

    _balance = result;

    if (_currentlyEditing == null) {
      setState(() {});
      return;
    }

    _currentlyEditing!.updateBalanceAndSave(
      _balance,
      title: "account.updateBalance.transactionTitle".t(context),
      transactionDate: _updateBalanceAt,
    );

    _refetch();
  }

  void updateBalanceExclusion(bool? value) {
    if (value != null) {
      setState(() {
        _excludeFromTotalBalance = value;
      });
    }
  }

  void updateArchived(bool? value) {
    if (value != null) {
      setState(() {
        _archived = value;
      });
    }
  }

  void selectCurrency() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => const SelectCurrencySheet(),
      isScrollControlled: true,
    );

    setState(() {
      _currency = result ?? _currency;
    });
  }

  void update({required String formattedName}) async {
    if (_currentlyEditing == null) return;

    _currentlyEditing!.name = formattedName;
    _currentlyEditing!.currency = _currency;

    _currentlyEditing!.iconCode = iconCodeOrError;
    _currentlyEditing!.excludeFromTotalBalance = _excludeFromTotalBalance;
    _currentlyEditing!.archived = _archived;

    ObjectBox().box<Account>().put(
          _currentlyEditing!,
          mode: PutMode.update,
        );

    if (mounted) {
      context.pop();
    }
  }

  void save() async {
    if (_formKey.currentState?.validate() != true) return;

    final String trimmed = _nameTextController.text.trim();

    if (_currentlyEditing != null) {
      return update(formattedName: trimmed);
    }

    final int sortOrder = ObjectBox().box<Account>().count();

    final account = Account(
      name: trimmed,
      currency: _currency,
      archived: _archived,
      excludeFromTotalBalance: _excludeFromTotalBalance,
      iconCode: iconCodeOrError,
      sortOrder: sortOrder,
    );

    if (_balance.abs() != 0) {
      unawaited(
        ObjectBox()
            .box<Account>()
            .putAndGetAsync(
              account,
              mode: PutMode.insert,
            )
            .then(
          (value) {
            value.updateBalanceAndSave(
              _balance,
              title: "account.updateBalance.transactionTitle".tr(),
              transactionDate: _updateBalanceAt,
            );
            ObjectBox().box<Account>().putAsync(value);
          },
        ),
      );
    } else {
      unawaited(
        ObjectBox().box<Account>().putAsync(
              account,
              mode: PutMode.insert,
            ),
      );
    }

    context.pop();
  }

  bool hasChanged() {
    if (_currentlyEditing != null) {
      return _currentlyEditing!.name != _nameTextController.text.trim() ||
          _currentlyEditing!.iconCode != iconCodeOrError ||
          _currentlyEditing!.archived != _archived ||
          _currentlyEditing!.currency != _currency ||
          _currentlyEditing!.excludeFromTotalBalance !=
              _excludeFromTotalBalance ||
          _balance != _currentlyEditing!.balance.amount ||
          _updateBalanceAt != null;
    }

    return _nameTextController.text.trim().isNotEmpty ||
        _iconData != null ||
        _currency != LocalPreferences().getPrimaryCurrency() ||
        _balance != 0.0 ||
        _updateBalanceAt != null;
  }

  void _refetch() {
    if (_currentlyEditing == null) return;

    _currentlyEditing = ObjectBox().box<Account>().get(_currentlyEditing!.id);

    if (mounted) setState(() {});
  }

  void toggleEditName([bool? force]) {
    setState(() {
      _editingName = force ?? !_editingName;
    });

    if (_editingName) {
      _editNameFocusNode.requestFocus();
    }
  }

  String? validateNameField(String? value) {
    final requiredValidationError = validateRequiredField(value);
    if (requiredValidationError != null) {
      return requiredValidationError.t(context);
    }

    final String trimmed = value!.trim();

    final Query<Account> sameNameQuery = ObjectBox()
        .box<Account>()
        .query(
          Account_.name
              .equals(trimmed)
              .and(Account_.id.notEquals(_currentlyEditing?.id ?? 0)),
        )
        .build();

    final bool isNameUnique = sameNameQuery.count() == 0;

    sameNameQuery.close();

    if (!isNameUnique) {
      return "error.input.duplicate.accountName".t(context, trimmed);
    }

    return null;
  }

  void _updateIcon(FlowIconData? data) {
    _iconData = data;
  }

  Future<void> selectIcon() async {
    final result = await showModalBottomSheet<FlowIconData>(
      context: context,
      builder: (context) => SelectFlowIconSheet(
        current: _iconData,
      ),
      isScrollControlled: true,
    );

    if (result != null) {
      _updateIcon(result);
    }

    if (mounted) setState(() {});
  }

  void _deleteAccount() async {
    if (_currentlyEditing == null) return;

    final TransactionFilter filter =
        TransactionFilter(accounts: [_currentlyEditing!.uuid]);

    final int txnCount = TransactionsService().countMany(filter);

    final bool? confirmation = await context.showConfirmDialog(
      isDeletionConfirmation: true,
      title: "general.delete.confirmName".t(context, _currentlyEditing!.name),
      child: Text("account.delete.description".t(context, txnCount)),
    );

    if (!mounted) return;

    if (confirmation == true) {
      await export(
        showShareDialog: false,
        subfolder: "anti-blunder",
        type: BackupEntryType.preAccountDeletion,
      );

      try {
        await TransactionsService().deleteMany(filter);
      } catch (e) {
        log("[Account Page] Failed to remove associated transactions for account ${_currentlyEditing!.name} (${_currentlyEditing!.uuid}) due to:\n$e");
      }

      try {
        await ObjectBox().box<Account>().removeAsync(_currentlyEditing!.id);
      } catch (e) {
        log("[Account Page] Failed to delete account ${_currentlyEditing!.name} (${_currentlyEditing!.uuid}) due to:\n$e");
      }
    }

    if (!mounted) return;
    context.pop();
    GoRouter.of(context).popUntil(
      (route) {
        return route.path != "/account/:id";
      },
    );
  }
}
