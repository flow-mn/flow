import 'dart:io';

import 'package:flow/entity/account.dart';
import 'package:flow/l10n/flow_localizations.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/actions.dart';
import 'package:flow/objectbox/objectbox.g.dart';
import 'package:flow/prefs.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/utils/utils.dart';
import 'package:flow/widgets/account_card.dart';
import 'package:flow/widgets/account_card_skeleton.dart';
import 'package:flow/widgets/general/spinner.dart';
import 'package:flow/widgets/home/home/account/no_accounts.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class AccountsTab extends StatefulWidget {
  const AccountsTab({super.key});

  @override
  State<AccountsTab> createState() => _AccountsTabState();
}

class _AccountsTabState extends State<AccountsTab>
    with AutomaticKeepAliveClientMixin {
  bool _canReorder = false;
  bool _reordering = false;

  QueryBuilder<Account> qb() =>
      ObjectBox().box<Account>().query().order(Account_.sortOrder);

  @override
  void initState() {
    super.initState();

    ObjectBox()
        .updateAccountOrderList(ignoreIfNoUnsetValue: true)
        .then((value) {
      _canReorder = true;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder<Query<Account>>(
        stream: qb().watch(triggerImmediately: true),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Spinner.center();
          }

          final accounts = snapshot.data!.find();

          return switch (accounts.length) {
            0 => const NoAccounts(),
            _ => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0).copyWith(bottom: 0.0),
                    child: buildHeader(context),
                  ),
                  ValueListenableBuilder(
                      valueListenable: LocalPreferences()
                          .excludeTransferFromFlow
                          .valueNotifier,
                      builder: (context, excludeTransfersInTotal, child) {
                        return Expanded(
                          child: _reordering
                              ? ReorderableListView.builder(
                                  padding: const EdgeInsets.all(16.0)
                                      .copyWith(bottom: 96.0),
                                  itemBuilder: (context, index) => Padding(
                                    key: ValueKey(accounts[index].uuid),
                                    padding:
                                        const EdgeInsets.only(bottom: 16.0),
                                    child: AccountCard(
                                      account: accounts[index],
                                      useCupertinoContextMenu: false,
                                      excludeTransfersInTotal:
                                          excludeTransfersInTotal == true,
                                    ),
                                  ),
                                  proxyDecorator: proxyDecorator,
                                  itemCount: accounts.length,
                                  onReorder: (oldIndex, newIndex) =>
                                      onReorder(accounts, oldIndex, newIndex),
                                )
                              : ListView(
                                  padding: const EdgeInsets.all(16.0),
                                  children: [
                                    ...accounts.map(
                                      (account) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 16.0),
                                        child: AccountCard(
                                          account: account,
                                          useCupertinoContextMenu:
                                              Platform.isIOS,
                                          excludeTransfersInTotal:
                                              excludeTransfersInTotal == true,
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
                      }),
                ],
              ),
          };
        });
  }

  Widget buildHeader(BuildContext context) {
    return Row(
      children: [
        Text(
          (_reordering && !isDesktop())
              ? "tabs.accounts.reorder.guide".t(context)
              : "tabs.accounts".t(context),
          style: context.textTheme.titleSmall,
        ),
        const Spacer(),
        if (_canReorder)
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
    );
  }

  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Material(
          elevation: 0,
          color: Colors.transparent,
          child: child,
        );
      },
      child: child,
    );
  }

  void toggleReorderMode() {
    setState(() {
      _reordering = _canReorder ? (!_reordering) : false;
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

  @override
  bool get wantKeepAlive => true;
}
