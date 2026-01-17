import "dart:async";
import "dart:developer";

import "package:flow/data/flow_icon.dart";
import "package:flow/data/money.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/backup_entry.dart";
import "package:flow/form_validators.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/routes/transaction_page/input_amount_sheet.dart";
import "package:flow/services/transactions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/sync/export.dart";
import "package:flow/theme/color_themes/registry.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/account/update_balance_options_sheet.dart";
import "package:flow/widgets/delete_button.dart";
import "package:flow/widgets/general/directional_chevron.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/form_close_button.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/select_color_scheme_list_tile.dart";
import "package:flow/widgets/sheets/select_account_type_sheet.dart";
import "package:flow/widgets/sheets/select_currency_sheet.dart";
import "package:flow/widgets/sheets/select_flow_icon_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class AccountEditPage extends StatefulWidget {
  /// Account Object ID
  final int accountId;

  bool get isNewAccount => accountId == 0;

  const AccountEditPage({super.key, required this.accountId});
  const AccountEditPage.create({super.key}) : accountId = 0;

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

  AccountType _accountType = AccountType.debit;

  double _creditLimit = 0.0;

  late double _balance;

  /// Transaction date of the diff transaction is to be inserted with [_balance]
  ///
  /// If null, the transaction will be inserted with the current date
  ///
  /// This allows users to update their balance at a specific date
  DateTime? _updateBalanceAt;

  String? _colorSchemeName;

  late Account? _currentlyEditing;

  bool _editingName = false;
  bool _archived = false;

  String get iconCodeOrError =>
      _iconData?.toString() ??
      FlowIconData.icon(Symbols.wallet_rounded).toString();

  int? balanceUpdateTransactionId;

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
      _nameTextController = TextEditingController(
        text: _currentlyEditing?.name,
      );
      _balance = _currentlyEditing?.balance.amount ?? 0.0;
      _creditLimit = _currentlyEditing?.creditLimit ?? 0.0;
      _currency =
          _currentlyEditing?.currency ??
          UserPreferencesService().primaryCurrency;
      _iconData = _currentlyEditing?.icon;
      _excludeFromTotalBalance =
          _currentlyEditing?.excludeFromTotalBalance ?? false;
      _archived = _currentlyEditing?.archived ?? false;
      _accountType = _currentlyEditing?.accountType ?? _accountType;
      _colorSchemeName = _currentlyEditing?.colorSchemeName;
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
              children: [
                const SizedBox(height: 16.0),
                FlowIcon(
                  _iconData ?? FlowIconData.icon(Symbols.wallet_rounded),
                  size: 96.0,
                  plated: true,
                  onTap: selectIcon,
                  colorScheme: getThemeStrict(_colorSchemeName),
                ),
                const SizedBox(height: 24.0),
                ConstrainedBox(
                  constraints: BoxConstraints.loose(
                    Size(320.0, double.infinity),
                  ),
                  child: TextFormField(
                    controller: _nameTextController,
                    focusNode: _editNameFocusNode,
                    maxLength: Account.maxNameLength,
                    decoration: InputDecoration(
                      focusColor: context.colorScheme.secondary,
                      counter: const SizedBox.shrink(),
                      hintText: "account.name".t(context),
                      hintStyle: context.textTheme.headlineMedium?.copyWith(
                        color: context.textTheme.headlineMedium?.color
                            ?.withAlpha(0x80),
                      ),
                      border: UnderlineInputBorder(),
                    ),
                    style: context.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                    onTap: () => toggleEditName(true),
                    onFieldSubmitted: (_) => toggleEditName(false),
                    readOnly: !_editingName,
                    validator: validateNameField,
                  ),
                ),
                const SizedBox(height: 48.0),
                InkWell(
                  borderRadius: .circular(16.0),
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
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48.0),
                ListTile(
                  leading: Icon(Symbols.attach_money_rounded),
                  title: Text("currency".t(context)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_currency, style: context.textTheme.labelLarge),
                      if (widget.isNewAccount) ...[
                        const SizedBox(width: 8.0),
                        const DirectionalChevron(),
                      ],
                    ],
                  ),
                  onTap: widget.isNewAccount ? selectCurrency : null,
                ),
                ListTile(
                  leading: Icon(Symbols.category_rounded),
                  title: Text("account.type".t(context)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _accountType.localizedNameContext(context),
                        style: context.textTheme.labelLarge,
                      ),
                      const SizedBox(width: 8.0),
                      const DirectionalChevron(),
                    ],
                  ),
                  onTap: selectAccountType,
                ),
                if (_accountType.showCreditLimit)
                  ListTile(
                    leading: Icon(Symbols.credit_card_rounded),
                    title: Text("account.creditLimit".t(context)),
                    trailing: MoneyText(
                      Money(_creditLimit, _currency),
                      style: context.textTheme.labelLarge,
                    ),
                    onTap: inputCreditLimit,
                  ),
                SelectColorSchemeListTile(
                  colorScheme: _colorSchemeName,
                  onChanged: (scheme) {
                    setState(() {
                      _colorSchemeName = scheme?.name;
                    });
                  },
                ),
                if (!_archived && _currentlyEditing?.uuid != null)
                  ValueListenableBuilder(
                    valueListenable: UserPreferencesService().valueNotifier,
                    builder: (context, value, _) {
                      final bool isPrimary =
                          value.primaryAccountUuid == _currentlyEditing?.uuid;

                      if (isPrimary) {
                        return Column(
                          children: [
                            ListTile(
                              leading: Icon(Symbols.star_rounded),
                              title: Text("account.primaryAccount".t(context)),
                            ),
                            Frame(
                              child: InfoText(
                                child: Text(
                                  "account.primaryAccount.changeDescription".t(
                                    context,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      return SwitchListTile(
                        secondary: Icon(Symbols.star_rounded),
                        title: Text(
                          "account.primaryAccount.notPrimary".t(context),
                        ),
                        selected: false,
                        value: false,
                        onChanged: (_) => setAsPrimaryAccount(),
                      );
                    },
                  ),
                const SizedBox(height: 24.0),
                const Divider(),
                const SizedBox(height: 24.0),
                SwitchListTile(
                  secondary: Icon(Symbols.playlist_remove_rounded),
                  value: _excludeFromTotalBalance,
                  onChanged: updateBalanceExclusion,
                  title: Text("account.excludeFromTotalBalance".t(context)),
                ),
                if (!widget.isNewAccount)
                  SwitchListTile(
                    secondary: Icon(Symbols.block_rounded),
                    value: _archived,
                    onChanged: updateArchived,
                    title: Text("account.archive".t(context)),
                  ),
                if (!widget.isNewAccount) ...[
                  const SizedBox(height: 8.0),
                  Frame(
                    child: InfoText(
                      child: Text("account.archive.description".t(context)),
                    ),
                  ),
                ],
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

  void inputCreditLimit() async {
    final double? result = await showModalBottomSheet<double>(
      context: context,
      builder: (context) => InputAmountSheet(
        initialAmount: _creditLimit.abs(),
        currency: _currency,
        title: "account.creditLimit".t(context),
        allowNegative: false,
        lockSign: true,
      ),
      isScrollControlled: true,
    );

    if (result == null) return;

    _creditLimit = result.abs();

    if (mounted) {
      setState(() {});
    }
  }

  void updateType(AccountType newType) async {
    if (newType.preferExcludeFromBalance) {
      updateBalanceExclusion(true);
    }

    _accountType = newType;

    setState(() {});
  }

  void updateBalance() async {
    final Optional<DateTime>? updateAtResult =
        await showModalBottomSheet<Optional<DateTime>>(
          context: context,
          builder: (context) => UpdateBalanceOptionsSheet(),
          isScrollControlled: true,
        );

    if (updateAtResult == null || !mounted) {
      _updateBalanceAt = null;
      return;
    }

    _updateBalanceAt = updateAtResult.value;

    final result = await showModalBottomSheet<double>(
      context: context,
      builder: (context) =>
          InputAmountSheet(initialAmount: _balance, currency: _currency),
      isScrollControlled: true,
    );

    if (result == null || result == _balance) return;
    if (!mounted) return;

    _balance = result;

    if (_currentlyEditing == null) {
      setState(() {});
      return;
    }

    balanceUpdateTransactionId = _currentlyEditing!.updateBalanceAndSave(
      _balance,
      title: "account.updateBalance.transactionTitle".t(context),
      transactionDate: _updateBalanceAt,
      existingTransactionId: balanceUpdateTransactionId,
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

  void selectAccountType() async {
    final result = await showModalBottomSheet<AccountType>(
      context: context,
      builder: (context) => const SelectAccountTypeSheet(),
      isScrollControlled: true,
    );

    if (result != null) {
      updateType(result);
    }
  }

  void update({required String formattedName}) async {
    if (_currentlyEditing == null) return;

    _currentlyEditing!.name = formattedName;
    _currentlyEditing!.currency = _currency;

    _currentlyEditing!.creditLimit = _creditLimit;
    _currentlyEditing!.accountType = _accountType;

    _currentlyEditing!.colorSchemeName = _colorSchemeName;
    _currentlyEditing!.iconCode = iconCodeOrError;
    _currentlyEditing!.excludeFromTotalBalance = _excludeFromTotalBalance;
    _currentlyEditing!.archived = _archived;

    ObjectBox().box<Account>().put(_currentlyEditing!, mode: PutMode.update);

    if (_archived) {
      try {
        UserPreferencesService().ensurePrimaryAccountAvailability();
      } catch (e) {
        //
      }
    }

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
      colorSchemeName: _colorSchemeName,
      iconCode: iconCodeOrError,
      sortOrder: sortOrder,
      type: _accountType.value,
      creditLimit: _creditLimit,
    );

    if (_balance.abs() != 0) {
      unawaited(
        ObjectBox()
            .box<Account>()
            .putAndGetAsync(account, mode: PutMode.insert)
            .then((value) {
              value.updateBalanceAndSave(
                _balance,
                title: "account.updateBalance.transactionTitle".tr(),
                transactionDate: _updateBalanceAt,
              );
              ObjectBox().box<Account>().putAsync(value);
            }),
      );
    } else {
      unawaited(
        ObjectBox().box<Account>().putAsync(account, mode: PutMode.insert),
      );
    }

    context.pop();
  }

  bool hasChanged() {
    if (_currentlyEditing != null) {
      return _currentlyEditing!.name != _nameTextController.text.trim() ||
          _currentlyEditing!.iconCode != iconCodeOrError ||
          _currentlyEditing!.colorSchemeName != _colorSchemeName ||
          _currentlyEditing!.archived != _archived ||
          _currentlyEditing!.currency != _currency ||
          (_currentlyEditing!.creditLimit ?? 0) != _creditLimit ||
          _currentlyEditing!.accountType != _accountType ||
          _currentlyEditing!.excludeFromTotalBalance !=
              _excludeFromTotalBalance ||
          _balance != _currentlyEditing!.balance.amount ||
          _updateBalanceAt != null;
    }

    return _nameTextController.text.trim().isNotEmpty ||
        _iconData != null ||
        _colorSchemeName != null ||
        _currency != UserPreferencesService().primaryCurrency ||
        _balance != 0.0 ||
        _creditLimit != 0.0 ||
        _accountType != AccountType.debit ||
        _excludeFromTotalBalance ||
        _archived ||
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

  Future<void> setAsPrimaryAccount() async {
    if (_currentlyEditing?.uuid == null) return;

    final bool? confirmation = await context.showConfirmationSheet(
      title: "account.primaryAccount.set".t(context),
      child: Text("account.primaryAccount.description".t(context)),
    );

    if (confirmation != true) return;

    UserPreferencesService().primaryAccountUuid = _currentlyEditing!.uuid;
  }

  Future<void> selectIcon() async {
    final result = await showModalBottomSheet<FlowIconData>(
      context: context,
      builder: (context) => SelectFlowIconSheet(current: _iconData),
      isScrollControlled: true,
    );

    if (result != null) {
      _updateIcon(result);
    }

    if (mounted) setState(() {});
  }

  void _deleteAccount() async {
    if (_currentlyEditing == null) return;

    final TransactionFilter filter = TransactionFilter(
      accounts: [_currentlyEditing!.uuid],
    );

    final int txnCount = TransactionsService().countMany(filter);

    final bool? confirmation = await context.showConfirmationSheet(
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
        log(
          "[Account Page] Failed to remove associated transactions for account ${_currentlyEditing!.name} (${_currentlyEditing!.uuid}) due to:\n$e",
        );
      }

      try {
        await ObjectBox().box<Account>().removeAsync(_currentlyEditing!.id);
      } catch (e) {
        log(
          "[Account Page] Failed to delete account ${_currentlyEditing!.name} (${_currentlyEditing!.uuid}) due to:\n$e",
        );
      }
    }

    try {
      UserPreferencesService().ensurePrimaryAccountAvailability();
    } catch (e) {
      //
    }

    if (!mounted) return;
    context.pop();
    GoRouter.of(context).popUntil((route) {
      return route.path != "/account/:id";
    });
  }
}
