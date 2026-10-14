import "dart:math" as math;

import "package:auto_size_text/auto_size_text.dart";
import "package:flow/data/money.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/routes/transaction_page/input_amount_sheet/input_value.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/context_menu.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

class AmountText extends StatefulWidget {
  final FocusNode focusNode;

  final bool inputtingDecimal;

  final InputValue value;

  final String? currency;

  final int numberOfDecimals;

  /// If user have multiple accounts with different currencies, we can't be
  /// sure which currency transaction the user is making.
  final bool hideCurrencySymbol;

  final void Function(String text)? onPaste;

  /// Makes the currency symbol tappable
  final VoidCallback? onCurrencyTap;

  /// Tints the currency symbol
  final bool currencyHint;

  const AmountText({
    super.key,
    required this.focusNode,
    required this.inputtingDecimal,
    required this.value,
    required this.numberOfDecimals,
    required this.hideCurrencySymbol,
    this.currency,
    this.onPaste,
    this.onCurrencyTap,
    this.currencyHint = false,
  });

  @override
  State<AmountText> createState() => _AmountTextState();
}

class _AmountTextState extends State<AmountText>
    with SingleTickerProviderStateMixin {
  late AnimationController _amountTextAnimationController;

  late Animation<double> _amountTextScaleAnimation;

  final TapGestureRecognizer _currencyTapRecognizer = TapGestureRecognizer();

  InputValue get currentValue => widget.value;

  bool get _inputtingDecimal => widget.inputtingDecimal;

  @override
  void initState() {
    super.initState();

    _amountTextAnimationController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 60),
        )..addListener(() {
          setState(() {});
        });

    _amountTextScaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _amountTextAnimationController,
        curve: Curves.easeOutExpo,
      ),
    );
  }

  @override
  void didUpdateWidget(AmountText oldWidget) {
    if (oldWidget.value != widget.value) {
      _animateAmountText();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _amountTextAnimationController.dispose();
    _currencyTapRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle style = context.textTheme.displayMedium!;

    final double amountFieldMaxHeight = MediaQuery.of(
      context,
    ).textScaler.scale(style.fontSize! * style.height!);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ContextMenu(
        actions: [
          PopupMenuItem(value: "copy", child: Text("general.copy".t(context))),
        ],
        addPasteAction: true,
        onPaste: widget.onPaste,
        onSelected: handleContextMenuAction,
        child: Transform.scale(
          scale: _amountTextScaleAnimation.value,
          child: SizedBox(
            height: amountFieldMaxHeight,
            child: AutoSizeText.rich(
              amountTextSpan(context),
              style: style,
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
      ),
    );
  }

  TextSpan amountTextSpan(BuildContext context) {
    final String text = amountText();

    if (widget.hideCurrencySymbol || widget.onCurrencyTap == null) {
      return TextSpan(text: text);
    }

    final String number = amountText(includeCurrency: false);
    final int index = text.indexOf(number);

    if (index == -1) return TextSpan(text: text);

    _currencyTapRecognizer.onTap = widget.onCurrencyTap;

    final TextStyle? currencyStyle = widget.currencyHint
        ? TextStyle(color: context.colorScheme.primary)
        : null;

    TextSpan currencySpan(String value) => TextSpan(
      text: value,
      style: currencyStyle,
      recognizer: _currencyTapRecognizer,
      mouseCursor: SystemMouseCursors.click,
    );

    final String prefix = text.substring(0, index);
    final String suffix = text.substring(index + number.length);

    return TextSpan(
      children: [
        if (prefix.isNotEmpty) currencySpan(prefix),
        TextSpan(text: number),
        if (suffix.isNotEmpty) currencySpan(suffix),
      ],
    );
  }

  String amountText({bool? includeCurrency}) {
    final String currency =
        widget.currency ?? UserPreferencesService().primaryCurrency;

    final String formatted = Money(currentValue.currentAmount, currency)
        .formatMoney(
          decimalDigits: math.max(
            currentValue.decimalLength,
            _inputtingDecimal ? 1 : 0,
          ),
          includeCurrency: includeCurrency ?? !widget.hideCurrencySymbol,
        );

    if (currentValue.decimalLength == 0) {
      final String decimalSeparator = getDecimalSeparatorForCurrency(
        widget.currency,
      );

      return formatted.replaceAll("${decimalSeparator}0", decimalSeparator);
    }

    return formatted;
  }

  void _animateAmountText() async {
    if (_amountTextAnimationController.isAnimating) return;

    await _amountTextAnimationController.forward().orCancel;
    await _amountTextAnimationController.reverse().orCancel;
  }

  void handleContextMenuAction(String? action) {
    switch (action) {
      case "copy":
        Clipboard.setData(ClipboardData(text: amountText()));
        break;
    }
  }
}
