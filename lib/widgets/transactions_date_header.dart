import "package:flow/data/exchange_rates.dart";
import "package:flow/data/multi_currency_flow.dart";
import "package:flow/data/single_currency_flow.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/navigation.dart";
import "package:flow/services/user_preferences.dart";
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
  }) : pendingGroup = true,
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

    TransitiveLocalPreferences().sessionPrivacyMode.addListener(
      _updatePrivacyMode,
    );

    obscure = TransitiveLocalPreferences().sessionPrivacyMode.get();
  }

  @override
  void dispose() {
    TransitiveLocalPreferences().sessionPrivacyMode.removeListener(
      _updatePrivacyMode,
    );

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget title =
        widget.titleOverride ??
        GestureDetector(
          onLongPress: _handleRangeTextLongPress,
          onTap: _handleRangeTextTap,
          child: Text(_getRangeTitle()),
        );

    final String primaryCurrency = UserPreferencesService().primaryCurrency;

    final MultiCurrencyFlow flow = MultiCurrencyFlow()
      ..addAll(
        widget.transactions
            .where((transaction) => !transaction.isTransfer)
            .map((transaction) => transaction.money),
      );

    final bool containsNonPrimaryCurrency = widget.transactions.any(
      (transaction) => transaction.currency != primaryCurrency,
    );

    return ValueListenableBuilder(
      valueListenable: ExchangeRatesService().exchangeRatesCache,
      builder: (context, exchangeRatesCache, child) {
        final ExchangeRates? rates = exchangeRatesCache?.get(primaryCurrency);
        final bool showMissingExchangeRatesWarning =
            TransitiveLocalPreferences().usesNonPrimaryCurrency.get() &&
            rates == null;

        final SingleCurrencyFlow mergedFlow = flow.merge(
          primaryCurrency,
          rates,
        );

        final String exclamation = switch ((
          containsNonPrimaryCurrency,
          mergedFlow.hasMissingData,
        )) {
          (true, true) => "~",
          (true, false) => "+",
          _ => "",
        };

        return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: .spaceBetween,
          crossAxisAlignment: .center,
          children: [
            Flexible(
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: .start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultTextStyle(
                    style: context.textTheme.headlineSmall!,
                    child: title,
                  ),
                  MoneyTextBuilder(
                    builder: (context, formattedSum, originalSum) => RichText(
                      text: TextSpan(
                        style: context.textTheme.labelMedium,
                        children: [
                          TextSpan(
                            text: "$formattedSum$exclamation",
                            style: showMissingExchangeRatesWarning
                                ? TextStyle(color: context.colorScheme.error)
                                : null,
                          ),
                          TextSpan(text: " • "),
                          TextSpan(
                            text: "tabs.home.transactionsCount".t(
                              context,
                              widget.transactions.renderableCount,
                            ),
                          ),
                        ],
                      ),
                    ),
                    money: mergedFlow.totalFlow,
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

  void _updatePrivacyMode() {
    obscure = TransitiveLocalPreferences().sessionPrivacyMode.get();

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

  void _handleRangeTextLongPress() {
    if (LocalPreferences().enableHapticFeedback.get()) {
      HapticFeedback.mediumImpact();
    }

    NavigationService().add(
      "/transaction/new?transactionDate=${widget.range.from.toIso8601String()}",
    );
  }

  String _getRangeTitle() {
    return switch ((widget.range, rangeTitleAlternative)) {
      (DayTimeRange dayTimeRange, false) =>
        dayTimeRange.from.toMoment().calendar(omitHours: true),
      (DayTimeRange dayTimeRange, true) => dayTimeRange.from.toMoment().format(
        "ll",
      ),
      (TimeRange other, _) => other.format(),
    };
  }
}
