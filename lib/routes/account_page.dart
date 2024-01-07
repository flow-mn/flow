import 'package:flow/entity/account.dart';
import 'package:flow/entity/icon/parser.dart';
import 'package:flow/form_validators.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/objectbox.g.dart';
import 'package:flow/prefs.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/select_currency_sheet.dart';
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
  late IconData? _iconData;
  late bool _excludeFromTotalBalance;

  late final Account? _currentlyEditing;

  String get iconCodeOrError => IconCode.fromMaterialSymbols(
        _iconData ?? Symbols.error_circle_rounded_error_rounded,
      );

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
                CircleAvatar(
                  radius: 40.0,
                  child: Icon(
                    _iconData,
                    size: 56.0,
                    color: context.colorScheme.secondary,
                  ),
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
                )
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

  void updateAccount({required String formattedName}) async {
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
    // TODO add emoji/icon picker
    // if (_iconData == null) return; // TODO show error

    if (_formKey.currentState?.validate() != true) return;

    final String trimmed = _nameTextController.text.trim();

    if (_currentlyEditing != null) {
      return updateAccount(formattedName: trimmed);
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
}
