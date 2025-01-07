import "package:flow/data/exchange_rates.dart";
import "package:flow/data/money.dart";
import "package:flow/data/money_flow.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/money_text_builder.dart";
import "package:flutter/services.dart";
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
  bool rangeTitleAlternative = false;

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
    final Widget title = widget.titleOverride ??
        GestureDetector(
          onTap: _handleRangeTextTap,
          child: Text(_getRangeTitle()),
        );

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
          (true, false) => "+",
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
                    MoneyTextBuilder(
                      builder: (context, formattedSum, originalSum) => Text(
                        "$formattedSum$exclamation • ${'tabs.home.transactionsCount'.t(context, widget.transactions.renderableCount)}",
                        style: context.textTheme.labelMedium,
                      ),
                      money: sum,
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

  void _handleRangeTextTap() {
    rangeTitleAlternative = !rangeTitleAlternative;

    if (LocalPreferences().enableHapticFeedback.get()) {
      HapticFeedback.lightImpact();
    }

    setState(() {});
  }

  String _getRangeTitle() {
    return switch ((widget.range, rangeTitleAlternative)) {
      (DayTimeRange dayTimeRange, false) =>
        dayTimeRange.from.toMoment().calendar(omitHours: true),
      (DayTimeRange dayTimeRange, true) => dayTimeRange.from.toMoment().ll,
      (TimeRange other, _) => other.format(),
    };
  }
}
