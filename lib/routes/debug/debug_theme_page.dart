import "dart:io";

import "package:flow/data/flow_icon.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/widgets/account_card.dart";
import "package:flow/widgets/action_card.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/general/wavy_divider.dart";
import "package:flow/widgets/transaction_list_tile.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class DebugThemePage extends StatelessWidget {
  const DebugThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Debug Theme Page"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListHeader("Update theme"),
            const SizedBox(height: 12.0),
            ListTile(
              title: const Text("Update theme"),
              leading: const Icon(Symbols.settings_rounded),
              onTap: () => context.push("/preferences/theme"),
              trailing: const Icon(Symbols.chevron_right_rounded),
            ),
            const SizedBox(height: 24.0),
            ListHeader("Cards"),
            const SizedBox(height: 12.0),
            Card(
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: ListTile(
                title: const Text("Plain MUI card"),
                leading: const Icon(Symbols.wallet_rounded),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 16.0),
            Frame(
              child: IgnorePointer(
                ignoring: true,
                child: AccountCard(
                  account: demoAccount,
                  useCupertinoContextMenu: Platform.isIOS,
                  excludeTransfersInTotal: true,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Frame(
              child: ActionCard(
                title: "ActionCard with trailing",
                subtitle: "bish bash bosh yara yara",
                icon: FlowIconData.icon(Symbols.rate_review_rounded),
                trailing: Button(
                  backgroundColor: context.colorScheme.surface,
                  trailing: const Icon(Symbols.chevron_right_rounded),
                  child: Expanded(
                    child: Text(
                      "PB&J est tres delicieux",
                    ),
                  ),
                  onTap: () => {},
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            ListHeader("Home Components"),
            const SizedBox(height: 12.0),
            TransactionListTile(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              transaction: demoPendingTransaction,
              deleteFn: () => {},
              combineTransfers: false,
            ),
            WavyDivider(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: _demoTransactions
                  .map(
                    (transaction) => TransactionListTile(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      transaction: transaction,
                      deleteFn: () => {},
                      combineTransfers: false,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24.0),
            ListHeader("ListTiles"),
            const SizedBox(height: 16.0),
            ListTile(
              title: const Text("ListTile 1"),
              leading: const Icon(Symbols.yard_rounded),
              onTap: () {},
            ),
            ListTile(
              title: const Text("With Arrow"),
              leading: const Icon(Symbols.settings_rounded),
              onTap: () {},
              trailing: const Icon(Symbols.chevron_right_rounded),
            ),
            ListTile(
              title: const Text("With subtitle"),
              leading: const Icon(Symbols.zoom_out_map_rounded),
              subtitle: Text("bla bla bla disclaimer yara yara"),
              onTap: () {},
            ),
            CheckboxListTile.adaptive(
              title: const Text("With Checkbox Selected"),
              value: true,
              onChanged: (_) => {},
            ),
            CheckboxListTile.adaptive(
              title: const Text("With Checkbox Unselected"),
              value: false,
              onChanged: (_) => {},
            ),
            RadioListTile.adaptive(
              title: const Text("With Radio Selected"),
              value: "a",
              groupValue: "a",
              onChanged: (_) {},
            ),
            RadioListTile.adaptive(
              title: const Text("With Radio Unselected"),
              value: "b",
              groupValue: "a",
              onChanged: (_) {},
            ),
            const SizedBox(height: 240.0),
          ],
        ),
      ),
    );
  }
}

final List<Transaction> _demoTransactions = [
  Transaction(
    uuid: "e680f9ca-401a-4769-aaaf-7f1cf5b3d8b9",
    title: "Coffee",
    transactionDate: DateTime.now(),
    amount: -6.7,
    currency: "EUR",
  ),
  Transaction(
    uuid: "04d57fc9-20ab-483b-8deb-7d2d8f32ade6",
    title: "Support Flow",
    transactionDate: DateTime.now(),
    amount: -5.0,
    currency: "EUR",
  ),
  Transaction(
    uuid: "ea6b844b-77b5-4ea8-9946-ff62cc1c474c",
    title: "Buymeacoffee: Flow supporters",
    transactionDate: DateTime.now(),
    amount: 215.51,
    currency: "EUR",
  ),
  Transaction(
    uuid: "b1d4ad95-3016-49af-be23-90a6522e5750",
    title: "Phone bill",
    transactionDate: DateTime.now(),
    amount: -62.5,
    currency: "EUR",
  ),
  Transaction(
    uuid: "2c7a806e-ab94-4e07-beaa-c6090434eac1",
    title: "Rent",
    transactionDate: DateTime.now(),
    amount: -2510.4,
    currency: "EUR",
  ),
];

final Transaction demoPendingTransaction = Transaction(
  uuid: "296b26d6-51f9-4901-9e98-3b5e24869e85",
  title: "Paycheck",
  transactionDate: DateTime.now().startOfNextLocalWeek(),
  amount: 3522,
  currency: "EUR",
  isPending: true,
);

final Account demoAccount = Account(
  name: "Main",
  iconCode: FlowIconData.icon(Symbols.wallet_rounded).toString(),
  archived: false,
  currency: "EUR",
);
