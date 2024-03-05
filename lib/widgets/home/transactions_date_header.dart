import 'package:flow/entity/transaction.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/objectbox/actions.dart';
import 'package:flow/prefs.dart';
import 'package:flow/theme/theme.dart';
import 'package:flutter/widgets.dart';
import 'package:moment_dart/moment_dart.dart';

class TransactionListDateHeader extends StatelessWidget {
  final DateTime date;
  final List<Transaction> transactions;

  const TransactionListDateHeader({
    super.key,
    required this.transactions,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final double flow = transactions.sum;
    final int count = transactions.length -
        (LocalPreferences().combineTransferTransactions.get()
            ? transactions.transfers.length ~/ 2
            : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          date.toMoment().calendar(omitHours: true),
          style: context.textTheme.headlineSmall,
        ),
        Text(
          "${flow.moneyCompact} • $count transactions",
          style: context.textTheme.labelMedium,
        ),
      ],
    );
  }
}
