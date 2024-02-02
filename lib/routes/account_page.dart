import 'dart:developer';

import 'package:flow/data/flow_icon.dart';
import 'package:flow/entity/account.dart';
import 'package:flow/entity/transaction.dart';
import 'package:flow/form_validators.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/objectbox.g.dart';
import 'package:flow/prefs.dart';
import 'package:flow/sync/export.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/utils/utils.dart';
import 'package:flow/widgets/delete_button.dart';
import 'package:flow/widgets/general/flow_icon.dart';
import 'package:flow/widgets/select_currency_sheet.dart';
import 'package:flow/widgets/select_icon_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class AccountPage extends StatefulWidget {
  /// Account Object ID
  final int accountId;

  bool get isNewAccount => accountId == 0;

  const AccountPage.create({
    super.key,
  }) : accountId = 0;
  const AccountPage.edit({super.key, required this.accountId});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  late final TextEditingController _nameTextController;

  late String _currency;
  late FlowIconData? _iconData;
  late bool _excludeFromTotalBalance;

  late final Account? _currentlyEditing;

  String get iconCodeOrError =>
      _iconData?.toString() ?? FlowIconData.emoji("❌").toString();

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
      _currency = _currentlyEditing?.currency ??
          LocalPreferences().getPrimaryCurrency();
      _iconData = _currentlyEditing?.icon;
      _excludeFromTotalBalance =
          _currentlyEditing?.excludeFromTotalBalance ?? false;
    }
  }

  @override
  void dispose() {
    _nameTextController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const contentPadding = EdgeInsets.symmetric(horizontal: 16.0);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => save(),
            icon: const Icon(
              Symbols.check_rounded,
            ),
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
                FlowIcon(
                  _iconData ?? CharacterFlowIcon("T"),
                  size: 80.0,
                  plated: true,
                  onTap: selectIcon,
                ),
                const SizedBox(height: 16.0),
                Padding(
                  padding: contentPadding,
                  child: TextFormField(
                    controller: _nameTextController,
                    decoration: InputDecoration(
                      label: Text(
                        "account.name".t(context),
                      ),
                      focusColor: context.colorScheme.secondary,
                    ),
                    validator: validateNameField,
                  ),
                ),
                const SizedBox(height: 24.0),
                ListTile(
                  title: Text("currency".t(context)),
                  trailing: Text(_currency),
                  onTap:
                      _currentlyEditing == null ? () => selectCurrency() : null,
                ),
                CheckboxListTile.adaptive(
                  value: _excludeFromTotalBalance,
                  onChanged: updateBalanceExclusion,
                  title: Text("account.excludeFromTotalBalance".t(context)),
                ),
                const SizedBox(height: 16.0),
                if (_currentlyEditing != null) ...[
                  const SizedBox(height: 96.0),
                  DeleteButton(
                    onTap: _deleteAccount,
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

  void updateBalanceExclusion(bool? value) {
    if (value != null) {
      setState(() {
        _excludeFromTotalBalance = value;
      });
    }
  }

  void selectCurrency() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => const SelectCurrencySheet(),
      // isScrollControlled: true,
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

    ObjectBox().box<Account>().put(
          _currentlyEditing!,
          mode: PutMode.update,
        );

    context.pop();
  }

  void save() async {
    if (_formKey.currentState?.validate() != true) return;

    final String trimmed = _nameTextController.text.trim();

    if (_currentlyEditing != null) {
      return update(formattedName: trimmed);
    }

    final account = Account(
      name: trimmed,
      iconCode: iconCodeOrError,
      currency: _currency,
      excludeFromTotalBalance: _excludeFromTotalBalance,
    );

    ObjectBox().box<Account>().putAsync(
          account,
          mode: PutMode.insert,
        );

    context.pop();
  }

  String? validateNameField(String? value) {
    final requiredValidationError = validateRequiredField(value);
    if (requiredValidationError != null) {
      return requiredValidationError.t(context);
    }

    final String trimmed = value!.trim();

    final isNameUnique = ObjectBox()
            .box<Account>()
            .query(
              Account_.name
                  .equals(trimmed)
                  .and(Account_.id.notEquals(_currentlyEditing?.id ?? 0)),
            )
            .build()
            .count() ==
        0;

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
      builder: (context) => SelectIconSheet(
        current: _iconData,
        onChange: (value) => _updateIcon(value),
      ),
    );

    if (result != null) {
      _updateIcon(result);
    }

    if (mounted) setState(() {});
  }

  void _deleteAccount() async {
    if (_currentlyEditing == null) return;

    final associatedTransactionsQuery = ObjectBox()
        .box<Transaction>()
        .query(Transaction_.account.equals(_currentlyEditing!.id));

    final txnCount = associatedTransactionsQuery.build().count();

    final confirmation = await context.showConfirmDialog(
      isDeletionConfirmation: true,
      title: "general.delete.confirmName".t(context, _currentlyEditing!.name),
      child: Text("account.delete.warning".t(context, txnCount)),
    );

    log("confirmation: $confirmation");

    if (confirmation == true) {
      await export(showShareDialog: false, subfolder: "anti-blunder");

      await associatedTransactionsQuery.build().removeAsync();
      await ObjectBox().box<Account>().removeAsync(_currentlyEditing!.id);

      if (mounted) {
        context.pop();
      }
    }
  }
}
