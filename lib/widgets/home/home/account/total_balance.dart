import "package:flow/data/exchange_rates.dart";
import "package:flow/data/money.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";

class TotalBalance extends StatefulWidget {
  const TotalBalance({super.key});

  @override
  State<TotalBalance> createState() => _TotalBalanceState();
}

class _TotalBalanceState extends State<TotalBalance> {
  @override
  void initState() {
    super.initState();
    LocalPreferences().primaryCurrency.addListener(_refresh);
    ExchangeRatesService().exchangeRatesCache.addListener(_refresh);
  }

  @override
  void dispose() {
    LocalPreferences().primaryCurrency.removeListener(_refresh);
    ExchangeRatesService().exchangeRatesCache.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Money totalBalance = ObjectBox().getPrimaryCurrencyGrandTotal();
    final ExchangeRates? rates =
        ExchangeRatesService().getPrimaryCurrencyRates();

    return FutureBuilder<Money?>(
      future: rates == null ? null : ObjectBox().getGrandTotal(),
      builder: (context, snapshot) {
        final String value = snapshot.hasData
            ? snapshot.data!.moneyCompact
            : totalBalance.moneyCompact;

        return Padding(
          padding: EdgeInsets.only(left: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "tabs.home.totalBalance".t(context),
                style: context.textTheme.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Flexible(
                child: Text(
                  value,
                  style: context.textTheme.displayMedium,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _refresh() {
    setState(() {});
  }
}
