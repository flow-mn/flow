import "package:flow/data/money.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/utils/extensions/money.dart";
import "package:flow/widgets/general/money_text_builder.dart";
import "package:flow/widgets/general/money_text_raw.dart";
import "package:flutter/material.dart";

/// Shows [money] converted to the primary currency using the latest rates,
/// e.g., "≈ R$25". Renders nothing when conversion isn't possible or needed.
class ApproximateMoneyText extends StatelessWidget {
  final Money money;

  final bool displayAbsoluteAmount;

  /// Set this to [true] to make it always unobscured
  ///
  /// Set this to [false] to make it always obscured
  ///
  /// Set this to [null] to use the default behavior
  final bool? overrideObscure;

  final TextAlign? textAlign;
  final TextStyle? style;

  const ApproximateMoneyText(
    this.money, {
    super.key,
    this.displayAbsoluteAmount = false,
    this.overrideObscure,
    this.textAlign,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final String primaryCurrency = UserPreferencesService().primaryCurrency;

    if (money.currency == primaryCurrency) return const SizedBox.shrink();

    return ValueListenableBuilder(
      valueListenable: ExchangeRatesService().exchangeRatesCache,
      builder: (context, exchangeRatesCache, child) {
        final double? converted = money.tryConvertAmount(
          primaryCurrency,
          exchangeRatesCache?.get(primaryCurrency),
        );

        if (converted == null) return const SizedBox.shrink();

        return MoneyTextBuilder(
          money: Money(converted, primaryCurrency),
          displayAbsoluteAmount: displayAbsoluteAmount,
          overrideObscure: overrideObscure,
          builder: (context, text, money) => MoneyTextRaw(
            text: "≈ $text",
            style: style,
            textAlign: textAlign,
            maxLines: 1,
          ),
        );
      },
    );
  }
}
