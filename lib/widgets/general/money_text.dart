import "package:auto_size_text/auto_size_text.dart";
import "package:flow/data/money.dart";
import "package:flow/widgets/general/money_text_builder.dart";
import "package:flow/widgets/general/money_text_raw.dart";
import "package:flutter/material.dart";

class MoneyText extends StatefulWidget {
  final Money? money;

  final String Function(
      Money money,
      ({
        bool abbreviate,
        bool obscure,
        bool useCurrencySymbol,
      }) options)? customFormatter;

  /// Defaults to [false]
  final bool initiallyAbbreviated;

  /// Defaults to [false]
  final bool tapToToggleAbbreviation;

  /// This will work even if [tapToToggleAbbreviation] enabled.
  final VoidCallback? onTap;

  final bool displayAbsoluteAmount;
  final bool omitCurrency;

  /// Uses 3-letter-code instead of the currency symbol.
  ///
  /// e.g., '€' instead of 'EUR'
  final bool? overrideUseCurrencySymbol;

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
    this.overrideUseCurrencySymbol,
    this.overrideObscure,
    this.autoSizeGroup,
    this.style,
    this.textAlign,
    this.customFormatter,
    this.onTap,
  });

  @override
  State<MoneyText> createState() => _MoneyTextState();
}

class _MoneyTextState extends State<MoneyText> {
  late bool abbreviate;

  @override
  initState() {
    super.initState();

    abbreviate = widget.initiallyAbbreviated;
  }

  @override
  Widget build(BuildContext context) {
    return MoneyTextBuilder(
      money: widget.money,
      customFormatter: widget.customFormatter,
      abbreviate: abbreviate,
      overrideObscure: widget.overrideObscure,
      overrideUseCurrencySymbol: widget.overrideUseCurrencySymbol,
      displayAbsoluteAmount: widget.displayAbsoluteAmount,
      omitCurrency: widget.omitCurrency,
      builder: (context, text, money) {
        final bool hasAction =
            widget.onTap != null || widget.tapToToggleAbbreviation;

        return MoneyTextRaw(
          text: text,
          style: widget.style,
          textAlign: widget.textAlign,
          maxLines: widget.maxLines,
          onTap: hasAction ? () => handleTap() : null,
          autoSizeGroup: widget.autoSizeGroup,
          autoSize: widget.autoSize,
        );
      },
    );
  }

  void handleTap() {
    if (widget.tapToToggleAbbreviation) {
      abbreviate = !abbreviate;

      if (mounted) setState(() => {});
    }

    if (widget.onTap != null) {
      widget.onTap!();
    }
  }
}
