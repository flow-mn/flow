import "package:flow/data/money.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/widgets.dart";
import "package:moment_dart/moment_dart.dart";

class TransactionListDateHeader extends StatefulWidget {
  final DateTime date;
  final List<Transaction> transactions;

  final Widget? action;

  /// Hides count and flow
  final bool pendingGroup;

  const TransactionListDateHeader({
    super.key,
    required this.transactions,
    required this.date,
    this.action,
    this.pendingGroup = false,
  });
  const TransactionListDateHeader.pendingGroup({
    super.key,
    required this.date,
    this.action,
  })  : pendingGroup = true,
        transactions = const [];

  @override
  State<TransactionListDateHeader> createState() =>
      _TransactionListDateHeaderState();
}

class _TransactionListDateHeaderState extends State<TransactionListDateHeader> {
  bool obscure = false;

  @override
  void initState() {
    super.initState();

    LocalPreferences().sessionPrivacyMode.addListener(_updatePrivacyMode);
    obscure = LocalPreferences().sessionPrivacyMode.get();
  }

  @override
  void dispose() {
    LocalPreferences().sessionPrivacyMode.removeListener(_updatePrivacyMode);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget title = Text(
      widget.date.toMoment().calendar(omitHours: true),
      style: context.textTheme.headlineSmall,
    );

    if (widget.pendingGroup) {
      return title;
    }

    final String primaryCurrency = LocalPreferences().getPrimaryCurrency();

    final double flow = widget.transactions
        .where((transaction) => transaction.currency == primaryCurrency)
        .sumWithoutCurrency;
    final bool containsNonPrimaryCurrency = widget.transactions
        .any((transaction) => transaction.currency != primaryCurrency);

    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              title,
              Text(
                "${Money(flow, primaryCurrency).formattedCompact}${containsNonPrimaryCurrency ? '+' : ''} • ${'tabs.home.transactionsCount'.t(context, widget.transactions.renderableCount)}",
                style: context.textTheme.labelMedium,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16.0),
        if (widget.action != null)
          Flexible(
            fit: FlexFit.tight,
            child: widget.action!,
          ),
      ],
    );
  }

  _updatePrivacyMode() {
    obscure = LocalPreferences().sessionPrivacyMode.get();

    if (!mounted) return;
    setState(() {});
  }
}
