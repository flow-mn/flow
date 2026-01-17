import "dart:io";

import "package:flow/entity/account.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/providers/accounts_provider.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/account_card.dart";
import "package:flow/widgets/account_card_skeleton.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/home/home/account/no_accounts.dart";
import "package:flow/widgets/home/home/account/total_balance.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class AccountsTab extends StatefulWidget {
  const AccountsTab({super.key});

  @override
  State<AccountsTab> createState() => _AccountsTabState();
}

class _AccountsTabState extends State<AccountsTab>
    with AutomaticKeepAliveClientMixin {
  bool _reordering = false;

  final TextEditingController _searchController = TextEditingController();

  String get _searchQuery => _searchController.text.trim();

  String? primaryAccountUuid;

  @override
  void initState() {
    super.initState();

    _updatePrimaryAccountUuid();
    UserPreferencesService().valueNotifier.addListener(
      _updatePrimaryAccountUuid,
    );
  }

  @override
  void dispose() {
    UserPreferencesService().valueNotifier.removeListener(
      _updatePrimaryAccountUuid,
    );
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final List<Account> accounts = AccountsProvider.of(context).activeAccounts;
    final bool ready = AccountsProvider.of(context).ready;

    if (!ready) {
      return const Spinner();
    }

    return switch (accounts.length) {
      0 => const NoAccounts(),
      _ => Column(
        spacing: 16.0,
        children: [
          SizedBox.shrink(),
          Frame(child: buildHeader(context, hasSearchBar: accounts.length > 4)),
          ValueListenableBuilder(
            valueListenable: UserPreferencesService().valueNotifier,
            builder: (context, userPreferences, child) {
              final bool excludeTransfersInTotal =
                  userPreferences.excludeTransfersFromFlow;

              final bool hasQuery = !_reordering && _searchQuery.isNotEmpty;

              final List<Account> searchResult = hasQuery
                  ? simpleSortByQuery(accounts, _searchQuery)
                  : accounts;

              return Expanded(
                child: _reordering
                    ? Frame(
                        child: ReorderableListView.builder(
                          padding: const EdgeInsets.only(bottom: 96.0),
                          itemBuilder: (context, index) => Padding(
                            key: ValueKey(accounts[index].uuid),
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: AccountCard(
                              account: accounts[index],
                              useCupertinoContextMenu: false,
                              primary:
                                  accounts[index].uuid == primaryAccountUuid,
                              excludeTransfersInTotal:
                                  excludeTransfersInTotal == true,
                            ),
                          ),
                          proxyDecorator: proxyDecorator,
                          itemCount: accounts.length,
                          onReorder: (oldIndex, newIndex) =>
                              onReorder(accounts, oldIndex, newIndex),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16.0).copyWith(top: 0.0),
                        children: [
                          ...searchResult.map(
                            (account) => Padding(
                              key: ValueKey("account-card-${account.uuid}"),
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: AccountCard(
                                account: account,
                                useCupertinoContextMenu: Platform.isIOS,
                                primary: account.uuid == primaryAccountUuid,
                                excludeTransfersInTotal:
                                    excludeTransfersInTotal == true,
                                onTapOverride: Optional(() async {
                                  await context.push("/account/${account.id}");
                                  setState(() {});
                                }),
                              ),
                            ),
                          ),
                          AccountCardSkeleton(
                            onTap: () => context.push("/account/new"),
                          ),
                          const SizedBox(height: 16.0),
                          const SizedBox(height: 64.0),
                        ],
                      ),
              );
            },
          ),
        ],
      ),
    };
  }

  Widget buildHeader(BuildContext context, {bool hasSearchBar = false}) {
    return Column(
      crossAxisAlignment: .start,
      spacing: 16.0,
      children: [
        Row(
          children: [
            Text(
              (_reordering && !isDesktop())
                  ? "tabs.accounts.reorder.guide".t(context)
                  : "tabs.accounts".t(context),
              style: context.textTheme.titleSmall,
            ),
            const Spacer(),
            IconButton(
              onPressed: toggleReorderMode,
              tooltip: _reordering
                  ? "general.done".t(context)
                  : "tabs.accounts.reorder".t(context),
              icon: _reordering
                  ? const Icon(Symbols.check_rounded)
                  : const Icon(Symbols.reorder_rounded),
            ),
          ],
        ),
        TotalBalance(),
        if (hasSearchBar)
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() {}),
            enabled: !_reordering,
            decoration: InputDecoration(
              hintText: "general.search".t(context),
              prefixIcon: const Icon(Symbols.search_rounded),
              suffixIcon: (_searchQuery.isNotEmpty)
                  ? IconButton(
                      onPressed: () =>
                          setState(() => _searchController.clear()),
                      icon: const Icon(Symbols.close_rounded),
                    )
                  : null,
            ),
          ),
      ],
    );
  }

  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Material(elevation: 0, color: Colors.transparent, child: child);
      },
      child: child,
    );
  }

  void toggleReorderMode() {
    setState(() {
      _reordering = !_reordering;
    });
  }

  void onReorder(List<Account> currentAccounts, int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final removed = currentAccounts.removeAt(oldIndex);
    currentAccounts.insert(newIndex, removed);

    ObjectBox().updateAccountOrderList(accounts: currentAccounts);
  }

  void _updatePrimaryAccountUuid() {
    try {
      primaryAccountUuid = UserPreferencesService().primaryAccountUuid;
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      //
    }
  }

  @override
  bool get wantKeepAlive => true;
}
