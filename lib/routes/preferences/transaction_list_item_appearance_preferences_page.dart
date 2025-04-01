import "dart:math";

import "package:flow/data/flow_icon.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/transaction_list_tile.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";
import "package:simple_icons/simple_icons.dart";

class TransactionListItemAppearancePreferencesPage extends StatefulWidget {
  const TransactionListItemAppearancePreferencesPage({super.key});

  @override
  State<TransactionListItemAppearancePreferencesPage> createState() =>
      _TransactionListItemAppearancePreferencesPageState();
}

class _TransactionListItemAppearancePreferencesPageState
    extends State<TransactionListItemAppearancePreferencesPage> {
  @override
  Widget build(BuildContext context) {
    final bool useCategoryNameForUntitledTransactions =
        UserPreferencesService().useCategoryNameForUntitledTransactions;
    final bool transactionListTileShowCategoryName =
        UserPreferencesService().transactionListTileShowCategoryName;
    final bool transactionListTileShowAccountForLeading =
        UserPreferencesService().transactionListTileShowAccountForLeading;

    return Scaffold(
      appBar: AppBar(
        title: Text("preferences.transactions.listTile".t(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListHeader(
                "preferences.transactions.listTile.preview".t(context),
              ),
              const SizedBox(height: 8.0),
              ...getExampleTransactions().map(
                (transaction) => IgnorePointer(
                  child: TransactionListTile(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4.0,
                    ),
                    transaction: transaction,
                    recoverFromTrashFn: null,
                    moveToTrashFn: null,
                    combineTransfers: false,
                    useAccountIconForLeading:
                        transactionListTileShowAccountForLeading,
                    showCategory: transactionListTileShowCategoryName,
                    useCategoryNameForUntitledTransactions:
                        useCategoryNameForUntitledTransactions,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              SwitchListTile(
                title: Text(
                  "preferences.transactions.listTile.fallbackToCategoryName".t(
                    context,
                  ),
                ),
                value: useCategoryNameForUntitledTransactions,
                onChanged: (bool newValue) {
                  UserPreferencesService()
                      .useCategoryNameForUntitledTransactions = newValue;
                  setState(() {});
                },
              ),
              SwitchListTile(
                title: Text(
                  "preferences.transactions.listTile.showCategoryInList".t(
                    context,
                  ),
                ),
                value: transactionListTileShowCategoryName,
                onChanged: (bool newValue) {
                  UserPreferencesService().transactionListTileShowCategoryName =
                      newValue;
                  setState(() {});
                },
              ),
              const SizedBox(height: 8.0),
              ListHeader(
                "preferences.transactions.listTile.leading".t(context),
              ),
              const SizedBox(height: 8.0),
              Frame(
                child: Wrap(
                  spacing: 12.0,
                  runSpacing: 12.0,
                  children: [
                    ChoiceChip(
                      label: Text(
                        "preferences.transactions.listTile.leading.category".t(
                          context,
                        ),
                      ),
                      selected: !transactionListTileShowAccountForLeading,
                      onSelected: (selected) {
                        if (!selected) return;

                        UserPreferencesService()
                            .transactionListTileShowAccountForLeading = false;
                        setState(() {});
                      },
                    ),
                    ChoiceChip(
                      label: Text(
                        "preferences.transactions.listTile.leading.account".t(
                          context,
                        ),
                      ),
                      selected: transactionListTileShowAccountForLeading,
                      onSelected: (selected) {
                        if (!selected) return;

                        UserPreferencesService()
                            .transactionListTileShowAccountForLeading = true;
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Transaction> getExampleTransactions() {
    final Account payPalExample = Account.preset(
      iconCode: FlowIconData.icon(SimpleIcons.paypal).toString(),
      uuid: "f38c7ea5-1726-4557-800d-d445bd30745f",
      name: "PayPal",
      currency: "USD",
    );

    final Category coffeeExample = Category.preset(
      iconCode: FlowIconData.icon(Symbols.local_cafe_rounded).toString(),
      name: "setup.categories.preset.drinks".t(context),
      uuid: "21702c36-3597-4a0c-b09c-5f01ddf52805",
    );

    return <Transaction>[
      Transaction(
          uuid: "71011fa3-c2c5-4767-962a-b965873e6acc",
          transactionDate:
              DateTime.now() - Duration(days: Random().nextInt(1000)),
          amount: -6.99,
          currency: "USD",
        )
        ..setAccount(payPalExample)
        ..setCategory(coffeeExample),
      Transaction(
        uuid: "8fea726e-997f-4e19-8012-75d8f9920a33",
        title: "Adbasoi ",
        transactionDate:
            DateTime.now() - Duration(days: Random().nextInt(1000)),
        amount: -1.27,
        currency: "USD",
      )..setAccount(payPalExample),
    ];

    //   return Transaction(
    //   uuid: "3953dd66-d770-4426-9e96-d9c93707a200",
    //   title: "",
    //   transactionDate: DateTime.now(),
    //   amount: -6.7,
    //   currency: "EUR",
    // )..setAccount()..setCategory();
  }
}
