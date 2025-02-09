import "package:flow/data/setup/default_accounts.dart";
import "package:flow/entity/account.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/setup/accounts/account_preset_card.dart";
import "package:flow/widgets/setup/accounts/add_account_card.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:local_hero/local_hero.dart";
import "package:material_symbols_icons/symbols.dart";

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
            .any((existingAccount) => existingAccount.uuid == account.uuid))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("setup.accounts.setup".t(context)),
      ),
      body: SafeArea(
        child: StreamBuilder<List<Account>>(
            stream: qb()
                .watch(triggerImmediately: true)
                .map((event) => event.find()),
            builder: (context, snapshot) {
              final List<Account> currentAccounts = snapshot.data ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InfoText(
                      child: Text(
                        "setup.accounts.description".t(context),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const AddAccountCard(),
                    const SizedBox(height: 16.0),
                    ...currentAccounts.map(
                      (account) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: AccountPresetCard(
                          key: ValueKey(account.uuid),
                          account: account,
                          onSelect: null,
                          selected: true,
                          preexisting: true,
                        ),
                      ),
                    ),
                    LocalHeroScope(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: presetAccounts
                            .map((preset) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: LocalHero(
                                    key: ValueKey(preset.uuid),
                                    tag: preset.uuid,
                                    child: AccountPresetCard(
                                      key: ValueKey(preset.uuid),
                                      account: preset,
                                      onSelect: (selected) =>
                                          select(preset.uuid, selected),
                                      selected: preset.id == 0,
                                      preexisting: false,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    )
                  ],
                ),
              );
            }),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
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
      ),
    );
  }

  void loadPresets() {}

  void select(String uuid, bool selected) {
    final Account? preset =
        presetAccounts.firstWhereOrNull((element) => element.uuid == uuid);

    if (preset != null) {
      preset.id = selected ? 0 : -1;
    }

    presetAccounts.sort((a, b) => b.id.compareTo(a.id));
    setState(() {});
  }

  void save() async {
    if (busy) return;

    setState(() {
      busy = true;
    });

    try {
      final List<Account> selectedAccounts =
          presetAccounts.where((element) => element.id == 0).toList();

      for (final e in selectedAccounts.indexed) {
        e.$2.sortOrder = e.$1;
      }

      await ObjectBox().box<Account>().putManyAsync(selectedAccounts);

      presetAccounts.removeWhere((element) =>
          selectedAccounts.indexWhere(
            (selected) => element.uuid == selected.uuid,
          ) !=
          -1);

      if (mounted) {
        await context.push("/setup/categories");
      }
    } finally {
      busy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }
}
