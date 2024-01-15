import 'dart:math';

import 'package:flow/entity/account.dart';
import 'package:flow/entity/transaction.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/routes/home/accounts_tab.dart';
import 'package:flow/routes/home/home_tab.dart';
import 'package:flow/routes/home/profile_tab.dart';
import 'package:flow/routes/home/stats_tab.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/home/navbar.dart';
import 'package:flow/widgets/home/navbar/new_transaction_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:pie_menu/pie_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  late int _currentIndex;

  @override
  void initState() {
    super.initState();

    _currentIndex = 0;
    _tabController = TabController(
      vsync: this,
      length: 4,
      initialIndex: _currentIndex,
    );

    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () =>
            _newTransactionPage(null),
      },
      child: Focus(
        autofocus: true,
        child: PieCanvas(
          theme: pieTheme,
          child: BottomBar(
            width: double.infinity,
            offset: 16.0,
            barColor: const Color.fromARGB(0, 86, 75, 75),
            borderRadius: BorderRadius.circular(32.0),
            body: (context, scrollControler) => Scaffold(
              body: SafeArea(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    HomeTab(),
                    StatsTab(),
                    AccountsTab(),
                    ProfileTab(),
                  ],
                ),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Navbar(
                  onTap: (i) => _navigateTo(i),
                  activeIndex: _currentIndex,
                ),
                NewTransactionButton(
                    onActionTap: (type) => _newTransactionPage(type))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void createAcc() {
    final int cnt = ObjectBox().box<Account>().count();

    final account = Account(
      name: "Test account #$cnt",
      currency: "MNT",
      iconCode: "Material Symbols:0xe0aa",
    );

    final double initialBalance =
        cnt == 0 ? 420.69 : Random().nextDouble() * 10000 - 5000;

    account.transactions.add(
      Transaction(
        amount: initialBalance,
        currency: account.currency,
      ),
    );

    ObjectBox().box<Account>().put(account);
  }

  void _navigateTo(int index) {
    _tabController.animateTo(index);
  }

  void _newTransactionPage(TransactionType? type) {
    if (ObjectBox().box<Account>().count(limit: 1) == 0) {
      context.push("/account/new");
      return;
    }

    type ??= TransactionType.expense;

    context.push("/transaction/new?type=${type.name}");
  }
}
