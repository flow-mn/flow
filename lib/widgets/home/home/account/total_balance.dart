import "dart:async";

import "package:flow/data/money.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/transactions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flutter/material.dart";

class TotalBalance extends StatefulWidget {
  const TotalBalance({super.key});

  @override
  State<TotalBalance> createState() => _TotalBalanceState();
}

class _TotalBalanceState extends State<TotalBalance> {
  bool initiallyAbbreviated = true;

  late Future<Money?> _getGrandTotalFuture;
  late Money _primaryCurrencyTotalBalance;

  Timer? _transactionDebounce;

  @override
  void initState() {
    super.initState();
    LocalPreferences().primaryCurrency.addListener(_refresh);
    UserPreferencesService().valueNotifier.addListener(_refresh);
    ExchangeRatesService().exchangeRatesCache.addListener(_refresh);

    TransactionsService().addListener(_onTransactionsChanged);

    _getGrandTotalFuture = ObjectBox().getGrandTotal();
    _primaryCurrencyTotalBalance = ObjectBox().getPrimaryCurrencyGrandTotal();

    initiallyAbbreviated = !LocalPreferences().preferFullAmounts.get();
  }

  @override
  void dispose() {
    LocalPreferences().primaryCurrency.removeListener(_refresh);
    UserPreferencesService().valueNotifier.removeListener(_refresh);
    ExchangeRatesService().exchangeRatesCache.removeListener(_refresh);

    TransactionsService().removeListener(_onTransactionsChanged);
    _transactionDebounce?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Money?>(
      future: _getGrandTotalFuture,
      builder: (context, snapshot) {
        final Money value = snapshot.hasData
            ? snapshot.data!
            : _primaryCurrencyTotalBalance;

        return Padding(
          padding: EdgeInsets.only(left: 12.0),
          child: Column(
            crossAxisAlignment: .start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "tabs.home.totalBalance".t(context),
                style: context.textTheme.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Flexible(
                child: MoneyText(
                  value,
                  style: context.textTheme.displayMedium,
                  initiallyAbbreviated: initiallyAbbreviated,
                  tapToToggleAbbreviation: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onTransactionsChanged() {
    _transactionDebounce?.cancel();
    _transactionDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _refresh();
    });
  }

  void _refresh() {
    setState(() {
      _getGrandTotalFuture = ObjectBox().getGrandTotal();
      _primaryCurrencyTotalBalance = ObjectBox().getPrimaryCurrencyGrandTotal();
    });
  }
}
