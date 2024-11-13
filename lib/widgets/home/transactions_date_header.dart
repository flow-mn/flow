import "package:flow/data/money.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/widgets.dart";
import "package:moment_dart/moment_dart.dart";

class TransactionListDateHeader extends StatelessWidget {
  final DateTime date;
  final List<Transaction> transactions;

  /// Hides count and flow
  final bool future;

  const TransactionListDateHeader({
    super.key,
    required this.transactions,
    required this.date,
    this.future = false,
  });
  const TransactionListDateHeader.future({
    super.key,
    required this.date,
  })  : future = true,
        transactions = const [];

  @override
  Widget build(BuildContext context) {
    final Widget title = Text(
      date.toMoment().calendar(omitHours: true),
      style: context.textTheme.headlineSmall,
    );

    if (future) {
      return title;
    }

    final String primaryCurrency = LocalPreferences().getPrimaryCurrency();

    final double flow = transactions
        .where((transaction) => transaction.currency == primaryCurrency)
        .sum;
    final bool containsNonPrimaryCurrency = transactions
        .any((transaction) => transaction.currency != primaryCurrency);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        title,
        Text(
          "${Money(flow, primaryCurrency).moneyCompact}${containsNonPrimaryCurrency ? '+' : ''} • ${'tabs.home.transactionsCount'.t(context, transactions.renderableCount)}",
          style: context.textTheme.labelMedium,
        ),
      ],
    );
  }
}
