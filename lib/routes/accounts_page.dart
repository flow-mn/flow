import "dart:io";

import "package:flow/entity/account.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/widgets/account_card.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/home/home/account/no_accounts.dart";
import "package:flow/widgets/setup/accounts/add_account_card.dart";
import "package:flutter/material.dart";

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  bool excludeTransfersInTotal = false;

  QueryBuilder<Account> qb() =>
      ObjectBox().box<Account>().query().order(Account_.sortOrder);

  @override
  void initState() {
    super.initState();

    UserPreferencesService().valueNotiifer.addListener(
      _updateExcludeTransfersInTotal,
    );
  }

  @override
  void dispose() {
    UserPreferencesService().valueNotiifer.removeListener(
      _updateExcludeTransfersInTotal,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("accounts".t(context))),
      body: SafeArea(
        child: StreamBuilder<List<Account>>(
          stream: qb()
              .watch(triggerImmediately: true)
              .map((event) => event.find()),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Spinner.center();
            }

            final accounts = snapshot.requireData;

            return switch (accounts.length) {
              0 => const NoAccounts(),
              _ => SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: AddAccountCard(),
                    ),
                    ...accounts.actives.map(
                      (account) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: AccountCard(
                          account: account,
                          useCupertinoContextMenu: Platform.isIOS,
                          excludeTransfersInTotal: excludeTransfersInTotal,
                        ),
                      ),
                    ),
                    ...accounts.inactives.map(
                      (account) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: AccountCard(
                          account: account,
                          useCupertinoContextMenu: Platform.isIOS,
                          excludeTransfersInTotal: excludeTransfersInTotal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            };
          },
        ),
      ),
    );
  }

  void _updateExcludeTransfersInTotal() {
    setState(() {
      excludeTransfersInTotal =
          UserPreferencesService().excludeTransfersFromFlow;
    });
  }
}
