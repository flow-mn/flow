import "package:flow/data/exchange_rates.dart";
import "package:flow/data/money.dart";
import "package:flow/data/money_flow.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs.dart";
import "package:flow/services/exchange_rates.dart";
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

  final Widget? titleOverride;

  const TransactionListDateHeader({
    super.key,
    required this.transactions,
    required this.range,
    this.action,
    this.titleOverride,
    this.pendingGroup = false,
    this.resolveNonPrimaryCurrencies = true,
  });
  const TransactionListDateHeader.pendingGroup({
    super.key,
    required this.range,
    this.action,
    this.titleOverride,
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
    final Widget title =
        widget.titleOverride ?? Text(_getRangeTitle(widget.range));

    final String primaryCurrency = LocalPreferences().getPrimaryCurrency();

    final MoneyFlow flow = MoneyFlow()
      ..addAll(widget.transactions.map((transaction) => transaction.money));

    final bool containsNonPrimaryCurrency = widget.transactions
        .any((transaction) => transaction.currency != primaryCurrency);

    return ValueListenableBuilder(
      valueListenable: ExchangeRatesService().exchangeRatesCache,
      builder: (context, exchangeRatesCache, child) {
        final ExchangeRates? rates = exchangeRatesCache?.get(primaryCurrency);

        final bool resolve = widget.resolveNonPrimaryCurrencies &&
            containsNonPrimaryCurrency &&
            rates != null;

        final String exclamation =
            switch ((containsNonPrimaryCurrency, resolve)) {
          (true, true) => "~",
          (true, false) => "+ more",
          _ => "",
        };

        final Money sum = resolve
            ? flow.getTotalFlow(rates, primaryCurrency)
            : flow.getFlowByCurrency(primaryCurrency);

        return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultTextStyle(
                    style: context.textTheme.headlineSmall!,
                    child: title,
                  ),
                  if (!widget.pendingGroup)
                    Text(
                      "${sum.formattedCompact}$exclamation • ${'tabs.home.transactionsCount'.t(context, widget.transactions.renderableCount)}",
                      style: context.textTheme.labelMedium,
                    ),
                ],
              ),
            ),
            if (widget.action != null) widget.action!,
          ],
        );
      },
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
