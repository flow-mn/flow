import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flow/l10n.dart';
import 'package:flow/prefs.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/bottom_sheet_frame.dart';
import 'package:flow/widgets/numpad.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

class InputAmountSheet extends StatefulWidget {
  static const double maxValue = 10e13;

  /// [ISO 4217](https://en.wikipedia.org/wiki/ISO_4217) currency code
  final String? currency;
  final double? initialAmount;

  /// Whether user input should erase the former value
  final bool overrideInitialAmount;

  const InputAmountSheet({
    super.key,
    this.initialAmount,
    this.currency,
    this.overrideInitialAmount = true,
  });

  @override
  State<InputAmountSheet> createState() => _InputAmountSheetState();
}

class _InputAmountSheetState extends State<InputAmountSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _amountTextAnimationController;

  late Animation<double> _amountTextScaleAnimation;

  late int _wholePart;
  late int _decimalPart;
  late bool _negative;

  int get _decimalLength =>
      _decimalPart == 0 ? 0 : _decimalPart.abs().toString().length;

  /// Number of decimals used for a currency
  late int _numberOfDecimals;

  double get currentAmount =>
      (_wholePart +
          (_decimalPart * math.pow(10.0, -_decimalLength).toDouble())) *
      (_negative ? -1 : 1);

  bool _inputtingDecimal = false;
  bool _resetOnNextInput = false;

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

    _numberOfDecimals = NumberFormat.simpleCurrency(
          name: widget.currency ?? LocalPreferences().getPrimaryCurrency(),
        ).decimalDigits ??
        2;
    if (_numberOfDecimals <= 0) {
      // Apparently, even in Japan, there are
      // stuff priced with decimal prices. i.e.,
      // electricity bill
      _numberOfDecimals = 2;
    }

    final initialAmount = (widget.initialAmount ?? 0).abs();
    _resetOnNextInput = initialAmount != 0;

    _wholePart = initialAmount.truncate();
    _decimalPart = ((initialAmount - initialAmount.truncate()) *
            math.pow(10, _numberOfDecimals))
        .round();
    _inputtingDecimal = _decimalPart.abs() != 0;
    _negate(widget.initialAmount?.isNegative);
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.digit1): () => insertDigit(1),
        const SingleActivator(LogicalKeyboardKey.numpad1): () => insertDigit(1),
        const SingleActivator(LogicalKeyboardKey.digit2): () => insertDigit(2),
        const SingleActivator(LogicalKeyboardKey.numpad2): () => insertDigit(2),
        const SingleActivator(LogicalKeyboardKey.digit3): () => insertDigit(3),
        const SingleActivator(LogicalKeyboardKey.numpad3): () => insertDigit(3),
        const SingleActivator(LogicalKeyboardKey.digit4): () => insertDigit(4),
        const SingleActivator(LogicalKeyboardKey.numpad4): () => insertDigit(4),
        const SingleActivator(LogicalKeyboardKey.digit5): () => insertDigit(5),
        const SingleActivator(LogicalKeyboardKey.numpad5): () => insertDigit(5),
        const SingleActivator(LogicalKeyboardKey.digit6): () => insertDigit(6),
        const SingleActivator(LogicalKeyboardKey.numpad6): () => insertDigit(6),
        const SingleActivator(LogicalKeyboardKey.digit7): () => insertDigit(7),
        const SingleActivator(LogicalKeyboardKey.numpad7): () => insertDigit(7),
        const SingleActivator(LogicalKeyboardKey.digit8): () => insertDigit(8),
        const SingleActivator(LogicalKeyboardKey.numpad8): () => insertDigit(8),
        const SingleActivator(LogicalKeyboardKey.digit9): () => insertDigit(9),
        const SingleActivator(LogicalKeyboardKey.numpad9): () => insertDigit(9),
        const SingleActivator(LogicalKeyboardKey.digit0): () => insertDigit(0),
        const SingleActivator(LogicalKeyboardKey.numpad0): () => insertDigit(0),
        const SingleActivator(LogicalKeyboardKey.minus): () => _negate(),
        const SingleActivator(LogicalKeyboardKey.numpadSubtract): () =>
            _negate(),
        const SingleActivator(LogicalKeyboardKey.equal): () => _negate(false),
        const SingleActivator(LogicalKeyboardKey.numpadAdd): () =>
            _negate(false),
        const SingleActivator(LogicalKeyboardKey.period): () => decimalMode(),
        const SingleActivator(LogicalKeyboardKey.numpadDecimal): () =>
            decimalMode(),
        const SingleActivator(LogicalKeyboardKey.enter): () => _pop(),
        const SingleActivator(LogicalKeyboardKey.numpadEnter): () => _pop(),
        const SingleActivator(LogicalKeyboardKey.backspace): () =>
            removeDigit(),
        const SingleActivator(LogicalKeyboardKey.backspace, control: true):
            () => _reset(),
        const SingleActivator(LogicalKeyboardKey.keyC, control: true): () =>
            _copy(),
      },
      child: Focus(
        autofocus: true,
        child: Actions(
          actions: const {},
          child: BottomSheetFrame(
            scrollable: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16.0),
                SelectionArea(
                  child: Transform.scale(
                    scale: _amountTextScaleAnimation.value,
                    child: AutoSizeText(
                      currentAmount.formatMoney(
                            decimalDigits: _decimalPart == 0
                                ? 0
                                : _decimalPart.abs().toString().length,
                          ) +
                          (_inputtingDecimal && _decimalPart == 0 ? "." : ""),
                      style: context.textTheme.displayMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                // Numpad
                Numpad(
                  children: [
                    ...getNumberRows(0),
                    NumpadButton(
                      child: const Icon(Symbols.backspace_rounded),
                      onTap: () => removeDigit(),
                    ),
                    ...getNumberRows(1),
                    NumpadButton(
                      child: const Icon(Symbols.remove_rounded),
                      onTap: () => _negate(),
                    ),
                    ...getNumberRows(2),
                    NumpadButton(
                      child: const Icon(Symbols.settings_rounded),
                      onTap: () => {},
                    ),
                    NumpadButton(
                      onTap: () => {},
                      crossAxisCellCount: 2,
                      child: const Text("0"),
                    ),
                    NumpadButton(
                      child: const Text("."),
                      onTap: () => decimalMode(),
                    ),

                    // NumpadButton(
                    //   child: const Text("0"),
                    //   onTap: () => {},
                    // ),
                    NumpadButton(
                      backgroundColor: context.flowColors.income,
                      child: Icon(
                        Symbols.check,
                        color: context.colorScheme.background,
                      ),
                      onTap: () => _pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Returns iterable of three widgets
  ///
  /// [row] - 0, 1, 2
  Iterable<Widget> getNumberRows(int row) {
    final usePhoneLayout =
        LocalPreferences().usePhoneNumpadLayout.value == true;

    late final List<int> digits;

    if (row <= 0) {
      digits = usePhoneLayout ? [1, 2, 3] : [7, 8, 9];
    } else if (row == 1) {
      digits = [4, 5, 6];
    } else {
      digits = usePhoneLayout ? [7, 8, 9] : [1, 2, 3];
    }

    return digits.map(
      (digit) => NumpadButton(
        child: Text(digit.toString()),
        onTap: () => insertDigit(digit),
      ),
    );
  }

  void decimalMode() {
    setState(() {
      _inputtingDecimal = true;
    });
  }

  void insertDigit(int n) {
    if (_resetOnNextInput) {
      _reset();
    }

    if (_inputtingDecimal) {
      if (_decimalLength < _numberOfDecimals) {
        _decimalPart = _decimalPart * 10 + n;
      }
    } else if (_wholePart * 10 < InputAmountSheet.maxValue) {
      _wholePart = _wholePart.abs() * 10 + n;
    }

    _animateAmountText();

    setState(() {});
  }

  void removeDigit() {
    // If user is removing digit, they are likely
    // to be changing the last few numbers around

    if (_resetOnNextInput) {
      _resetOnNextInput = false;
    }

    if (_inputtingDecimal) {
      if (_decimalPart == 0) {
        _inputtingDecimal = false;
      }
      _decimalPart = _decimalPart ~/ 10;
    } else {
      if (_wholePart.abs() == 0) {
        HapticFeedback.heavyImpact();
      }
      _wholePart = _wholePart ~/ 10;
    }

    _animateAmountText();

    setState(() {});
  }

  void _negate([bool? forceNegative]) {
    _negative = forceNegative ?? !_negative;

    setState(() {});
  }

  void _animateAmountText() async {
    if (_amountTextAnimationController.isAnimating) return;

    await _amountTextAnimationController.forward().orCancel;
    await _amountTextAnimationController.reverse().orCancel;
  }

  void _pop() {
    context.pop(currentAmount);
  }

  void _reset() {
    _wholePart = 0;
    _decimalPart = 0;
    _inputtingDecimal = false;
    _resetOnNextInput = false;
    setState(() {});
  }

  void _copy() {
    Clipboard.setData(ClipboardData(text: currentAmount.toString()));

    /// TODO (sadespresso) show a toast here
  }
}
