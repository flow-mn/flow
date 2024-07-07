import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/routes/new_transaction/input_amount_sheet/input_value.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/utils/utils.dart';
import 'package:flutter/material.dart';

class AmountText extends StatefulWidget {
  final FocusNode focusNode;

  final bool inputtingDecimal;

  final InputValue value;

  final String? currency;

  final int numberOfDecimals;

  /// If user have multiple accounts with different currencies, we can't be
  /// sure which currency transaction the user is making.
  final bool hideCurrencySymbol;

  const AmountText({
    super.key,
    required this.focusNode,
    required this.inputtingDecimal,
    required this.value,
    required this.numberOfDecimals,
    required this.hideCurrencySymbol,
    this.currency,
  });

  @override
  State<AmountText> createState() => _AmountTextState();
}

class _AmountTextState extends State<AmountText>
    with SingleTickerProviderStateMixin {
  late AnimationController _amountTextAnimationController;

  late Animation<double> _amountTextScaleAnimation;

  InputValue get currentValue => widget.value;

  bool get _inputtingDecimal => widget.inputtingDecimal;

  @override
  void initState() {
    super.initState();

    _amountTextAnimationController = AnimationController(
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle style = context.textTheme.displayMedium!;

    final double amountFieldMaxHeight = MediaQuery.of(context)
        .textScaler
        .scale(style.fontSize! * style.height!);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SelectionArea(
        focusNode: widget.focusNode,
        child: Transform.scale(
          scale: _amountTextScaleAnimation.value,
          child: SizedBox(
            height: amountFieldMaxHeight,
            child: AutoSizeText(
              amountText(),
              style: style,
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
      ),
    );
  }

  String amountText() {
    final String formatted = currentValue.currentAmount.formatMoney(
      decimalDigits:
          math.max(currentValue.decimalLength, _inputtingDecimal ? 1 : 0),
      includeCurrency: !widget.hideCurrencySymbol,
      currency: widget.currency,
    );

    if (currentValue.decimalLength == 0) {
      final String decimalSeparator =
          getDecimalSeparatorForCurrency(widget.currency);

      return formatted.replaceAll("${decimalSeparator}0", decimalSeparator);
    }

    return formatted;
  }

  void _animateAmountText() async {
    if (_amountTextAnimationController.isAnimating) return;

    await _amountTextAnimationController.forward().orCancel;
    await _amountTextAnimationController.reverse().orCancel;
  }
}
