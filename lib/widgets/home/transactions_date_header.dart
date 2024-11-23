import "package:flow/data/money.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/widgets.dart";
import "package:moment_dart/moment_dart.dart";

class TransactionListDateHeader extends StatefulWidget {
  final TimeRange range;
  final List<Transaction> transactions;

  final Widget? action;

  /// Hides count and flow
  final bool pendingGroup;

  final bool resolveNonPrimaryCurrencies;

  const TransactionListDateHeader({
    super.key,
    required this.transactions,
    required this.range,
    this.action,
    this.pendingGroup = false,
    this.resolveNonPrimaryCurrencies = true,
  });
  const TransactionListDateHeader.pendingGroup({
    super.key,
    required this.range,
    this.action,
    this.resolveNonPrimaryCurrencies = true,
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
      widget.pendingGroup
          ? "transactions.pending".t(context)
          : _getRangeTitle(widget.range),
      style: context.textTheme.headlineSmall,
    );

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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            title,
            if (!widget.pendingGroup)
              Text(
                "${Money(flow, primaryCurrency).formattedCompact}${containsNonPrimaryCurrency ? '+' : ''} • ${'tabs.home.transactionsCount'.t(context, widget.transactions.renderableCount)}",
                style: context.textTheme.labelMedium,
              ),
          ],
        ),
        const SizedBox(width: 16.0),
        Spacer(),
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

  String _getRangeTitle(TimeRange range) {
    return switch (range) {
      DayTimeRange() => range.from.toMoment().calendar(omitHours: true),
      _ => range.format(),
    };
  }
}
