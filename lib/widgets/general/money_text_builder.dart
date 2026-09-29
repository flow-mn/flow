import "package:flow/data/money.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/utils/utils.dart";
import "package:flutter/material.dart";

class MoneyTextBuilder extends StatefulWidget {
  final Function(BuildContext, String, Money?)? builder;

  final Money? money;

  /// Defaults to [false]
  final bool abbreviate;

  final bool displayAbsoluteAmount;
  final bool omitCurrency;

  /// Uses 3-letter-code instead of the currency symbol.
  ///
  /// e.g., '€' instead of 'EUR'
  final bool? overrideUseCurrencySymbol;

  /// Set this to [true] to make it always unobscured
  ///
  /// Set this to [false] to make it always obscured
  ///
  /// Set this to [null] to use the default behavior
  final bool? overrideObscure;

  const MoneyTextBuilder({
    super.key,
    required this.builder,
    required this.money,
    this.abbreviate = false,
    this.displayAbsoluteAmount = false,
    this.omitCurrency = false,
    this.overrideUseCurrencySymbol,
    this.overrideObscure,
  });

  @override
  State<MoneyTextBuilder> createState() => _MoneyTextBuilderState();
}

class _MoneyTextBuilderState extends State<MoneyTextBuilder> {
  late Money? money;

  late bool? overrideObscure;
  late bool? overrideUseCurrencySymbol;

  late bool globalPrivacyMode;
  late bool globalUseCurrencySymbol;
  late bool abbreviate;

  @override
  void initState() {
    super.initState();

    money = widget.money;
    overrideObscure = widget.overrideObscure;
    overrideUseCurrencySymbol = widget.overrideUseCurrencySymbol;
    abbreviate = widget.abbreviate;

    TransitiveLocalPreferences().sessionPrivacyMode.addListener(
      _privacyModeUpdate,
    );
    LocalPreferences().useCurrencySymbol.addListener(_useCurrencySymbolUpdate);
    UserPreferencesService().valueNotifier.addListener(_userPreferencesUpdate);

    globalPrivacyMode = TransitiveLocalPreferences().sessionPrivacyMode.get();
    globalUseCurrencySymbol = LocalPreferences().useCurrencySymbol.get();
  }

  @override
  void didUpdateWidget(MoneyTextBuilder oldWidget) {
    if (oldWidget.money != widget.money) {
      money = widget.money;
    }
    if (oldWidget.overrideObscure != widget.overrideObscure) {
      overrideObscure = widget.overrideObscure;
    }
    if (oldWidget.overrideUseCurrencySymbol != widget.overrideObscure) {
      overrideUseCurrencySymbol = widget.overrideUseCurrencySymbol;
    }
    if (oldWidget.abbreviate != widget.abbreviate) {
      abbreviate = widget.abbreviate;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    TransitiveLocalPreferences().sessionPrivacyMode.removeListener(
      _privacyModeUpdate,
    );
    LocalPreferences().useCurrencySymbol.removeListener(
      _useCurrencySymbolUpdate,
    );
    UserPreferencesService().valueNotifier.removeListener(
      _userPreferencesUpdate,
    );

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String text = getString();

    return widget.builder!(context, text, widget.money);
  }

  void _privacyModeUpdate() {
    globalPrivacyMode = TransitiveLocalPreferences().sessionPrivacyMode.get();
    if (!mounted) return;
    setState(() {});
  }

  void _useCurrencySymbolUpdate() {
    globalUseCurrencySymbol = LocalPreferences().useCurrencySymbol.get();
    if (!mounted) return;
    setState(() {});
  }

  void _userPreferencesUpdate() {
    if (!mounted) return;
    setState(() {});
  }

  String getString() {
    final Money? money = widget.money;

    if (money == null) return "-";

    final bool obscure = overrideObscure ?? globalPrivacyMode;

    final bool useCurrencySymbol =
        overrideUseCurrencySymbol ?? globalUseCurrencySymbol;

    final String text = money.formatMoney(
      compact: abbreviate,
      takeAbsoluteValue: widget.displayAbsoluteAmount,
      includeCurrency: !widget.omitCurrency,
      useCurrencySymbol: useCurrencySymbol,
    );

    if (obscure) {
      return text.digitsObscured;
    }

    return text;
  }
}
