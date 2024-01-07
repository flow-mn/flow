import 'package:flow/entity/account.dart';
import 'package:flow/l10n.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/prefs.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/select_currency_sheet.dart';
import 'package:flutter/material.dart';

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
  late final TextEditingController _nameTextController;

  late String _currency;
  late IconData? _iconData;
  late bool _excludeFromTotalBalance;

  late final Account? _currentlyEditing;

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
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
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
                child: TextField(
                  controller: _nameTextController,
                  decoration: InputDecoration(
                    label: Text(
                      "account.name".t(context),
                    ),
                    focusColor: context.colorScheme.secondary,
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              ListTile(
                title: Text("currency".t(context)),
                trailing: Text(_currency),
                onTap: () => selectCurrency(),
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

  void save() async {
    //
  }
}
