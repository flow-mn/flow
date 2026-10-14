import "package:flow/entity/account.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";

/// States what the import is about to replace on this device
class EraseWarning extends StatelessWidget {
  const EraseWarning({super.key});

  @override
  Widget build(BuildContext context) {
    final int accountCount = ObjectBox().box<Account>().count();
    final int transactionCount = ObjectBox().box<Transaction>().count();

    return Text(
      "sync.import.eraseWarning.description".t(context, {
        "accounts": "sync.import.syncData.parsedEstimate.accountCount".t(
          context,
          accountCount,
        ),
        "transactions": "sync.import.syncData.parsedEstimate.transactionCount"
            .t(context, transactionCount),
      }),
      style: context.textTheme.bodyMedium?.copyWith(
        color: context.flowColors.expense,
      ),
      textAlign: TextAlign.center,
    );
  }
}
