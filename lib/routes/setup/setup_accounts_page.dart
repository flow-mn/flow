import 'package:flow/data/setup/default_accounts.dart';
import 'package:flow/entity/account.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/objectbox.g.dart';
import 'package:flow/prefs.dart';
import 'package:flow/widgets/button.dart';
import 'package:flow/widgets/info_text.dart';
import 'package:flow/widgets/setup/accounts/account_preset_card.dart';
import 'package:flow/widgets/setup/accounts/add_account_card.dart';
import 'package:flow/widgets/setup/setup_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class SetupAccountsPage extends StatefulWidget {
  const SetupAccountsPage({super.key});

  @override
  State<SetupAccountsPage> createState() => _SetupAccountsPageState();
}

class _SetupAccountsPageState extends State<SetupAccountsPage> {
  QueryBuilder<Account> qb() =>
      ObjectBox().box<Account>().query().order(Account_.createdDate);

  late final List<Account> presetAccounts;

  bool busy = false;

  @override
  void initState() {
    super.initState();

    final String primaryCurrency = LocalPreferences().getPrimaryCurrency();

    final Query<Account> existingAccountsQuery = qb().build();

    final List<Account> existingAccounts = existingAccountsQuery.find();

    existingAccountsQuery.close();

    presetAccounts = getAccountPresets(primaryCurrency)
        .where((account) => !existingAccounts
            .any((existingAccount) => existingAccount.name == account.name))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: StreamBuilder(
            stream: qb().watch(triggerImmediately: true),
            builder: (context, snapshot) {
              final List<Account> currentAccounts = snapshot.data?.find() ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SetupHeader("setup.accounts.setup".t(context)),
                    const SizedBox(height: 16.0),
                    const AddAccountCard(),
                    const SizedBox(height: 16.0),
                    ...currentAccounts.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: AccountPresetCard(
                          account: e,
                          onSelect: null,
                          selected: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    if (presetAccounts.isNotEmpty) ...[
                      InfoText(
                        child: Text(
                          "setup.accounts.preset.description".t(context),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                    ],
                    ...presetAccounts.indexed.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: AccountPresetCard(
                          account: e.$2,
                          onSelect: (selected) => select(e.$1, selected),
                          selected: e.$2.id == 0,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Spacer(),
            Button(
              onTap: busy ? null : save,
              trailing: const Icon(Symbols.chevron_right_rounded),
              child: Text("setup.next".t(context)),
            )
          ],
        ),
      ),
    );
  }

  void select(int index, bool selected) {
    presetAccounts[index].id = selected ? 0 : -1;
    setState(() {});
  }

  void save() async {
    if (busy) return;

    try {
      final List<Account> selectedAccounts =
          presetAccounts.where((element) => element.id == 0).toList();

      await ObjectBox().box<Account>().putManyAsync(selectedAccounts);

      if (mounted) {
        context.push("/setup/categories");
      }
    } finally {
      busy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }
}
