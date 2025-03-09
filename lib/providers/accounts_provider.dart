import "package:flow/entity/account.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/utils/extensions/iterables.dart";
import "package:flow/widgets/transaction_watcher.dart";
import "package:flutter/material.dart";

class AccountsProviderScope extends StatefulWidget {
  final Widget child;

  const AccountsProviderScope({super.key, required this.child});

  @override
  State<AccountsProviderScope> createState() => _AccountsProviderScopeState();
}

class _AccountsProviderScopeState extends State<AccountsProviderScope> {
  QueryBuilder<Account> _queryBuilder() =>
      ObjectBox().box<Account>().query().order(Account_.sortOrder);

  @override
  Widget build(BuildContext context) => TransactionWatcher(
    builder: (context, _, __) {
      return StreamBuilder<Query<Account>>(
        stream: _queryBuilder().watch(triggerImmediately: true),
        builder: (context, snapshot) {
          final List<Account>? accounts = snapshot.data?.find();

          return AccountsProvider(accounts, child: widget.child);
        },
      );
    },
  );
}

class AccountsProvider extends InheritedWidget {
  final List<Account>? _accounts;

  bool get ready => _accounts != null;

  List<Account> get allAccounts => _accounts ?? [];
  List<Account> get activeAccounts => allAccounts.actives.toList();

  List<String> get activeUuids =>
      activeAccounts.map((account) => account.uuid).toList();

  String? getName(dynamic id) => get(id)?.name;

  Account? get(dynamic id) => switch (id) {
    String uuid => _accounts?.firstWhereOrNull(
      (account) => account.uuid == uuid,
    ),
    int id => _accounts?.firstWhereOrNull((account) => account.id == id),
    Account account => _accounts?.firstWhereOrNull(
      (element) => element.id == account.id,
    ),
    _ => null,
  };

  const AccountsProvider(this._accounts, {super.key, required super.child});

  static AccountsProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AccountsProvider>()!;

  @override
  bool updateShouldNotify(AccountsProvider oldWidget) =>
      !identical(_accounts, oldWidget._accounts);
}
