import "package:auto_size_text/auto_size_text.dart";
import "package:flow/data/money.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/prefs.dart";
import "package:flow/utils/utils.dart";
import "package:flutter/material.dart";

class MoneyText extends StatefulWidget {
  final Money? money;

  final String Function(Money money, ({bool abbreviate, bool obscure}) options)?
      formatter;

  /// Defaults to [false]
  final bool initiallyAbbreviated;

  /// Defaults to [false]
  final bool tapToToggleAbbreviation;

  final bool displayAbsoluteAmount;
  final bool omitCurrency;

  /// When true, renders [AutoSizeText]
  ///
  /// When false, renders [Text]
  final bool autoSize;

  /// Pass an [AutoSizeGroup] to synchronize
  /// fontSize among multiple [AutoSizeText]s
  final AutoSizeGroup? autoSizeGroup;

  /// Set this to [true] to make it always unobscured
  ///
  /// Set this to [false] to make it always obscured
  ///
  /// Set this to [null] to use the default behavior
  final bool? overrideObscure;

  final int maxLines;

  final TextAlign? textAlign;
  final TextStyle? style;

  const MoneyText(
    this.money, {
    super.key,
    this.tapToToggleAbbreviation = false,
    this.autoSize = false,
    this.initiallyAbbreviated = false,
    this.displayAbsoluteAmount = false,
    this.omitCurrency = false,
    this.maxLines = 1,
    this.overrideObscure,
    this.autoSizeGroup,
    this.style,
    this.textAlign,
    this.formatter,
  });

  @override
  State<MoneyText> createState() => _MoneyTextState();
}

class _MoneyTextState extends State<MoneyText> {
  late bool globalPrivacyMode;
  late bool abbreviate;
  AutoSizeGroup? autoSizeGroup;

  @override
  void initState() {
    super.initState();

    LocalPreferences().privacyMode.addListener(_privacyModeUpdate);

    globalPrivacyMode = LocalPreferences().privacyMode.get();
    abbreviate = widget.initiallyAbbreviated;
    autoSizeGroup = widget.autoSizeGroup;
  }

  @override
  void didUpdateWidget(MoneyText oldWidget) {
    if (widget.autoSizeGroup != autoSizeGroup) {
      autoSizeGroup = widget.autoSizeGroup;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    LocalPreferences().privacyMode.removeListener(_privacyModeUpdate);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String text = getString();

    final Widget child = widget.autoSize
        ? AutoSizeText(
            text,
            group: autoSizeGroup,
            style: widget.style,
            maxLines: widget.maxLines,
            textAlign: widget.textAlign,
          )
        : Text(
            text,
            style: widget.style,
            maxLines: widget.maxLines,
            textAlign: widget.textAlign,
          );

    if (!widget.tapToToggleAbbreviation) {
      return child;
    }

    return GestureDetector(
      onTap: handleTap,
      child: child,
    );
  }

  void handleTap() {
    setState(() {
      abbreviate = !abbreviate;
    });
  }

  _privacyModeUpdate() {
    globalPrivacyMode = LocalPreferences().privacyMode.get();
    if (!mounted) return;
    setState(() {});
  }

  String getString() {
    final Money? money = widget.money;

    if (money == null) return "-";

    final bool obscure = widget.overrideObscure ?? globalPrivacyMode;

    if (widget.formatter != null) {
      return widget.formatter!(
          money, (abbreviate: abbreviate, obscure: obscure));
    }

    final String text = money.formatMoney(
      compact: abbreviate,
      takeAbsoluteValue: widget.displayAbsoluteAmount,
      includeCurrency: !widget.omitCurrency,
    );

    if (obscure) {
      return text.digitsObscured;
    }

    return text;
  }
}
