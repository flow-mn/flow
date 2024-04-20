import 'dart:math' as math;

import 'package:flow/l10n/extensions.dart';
import 'package:flow/prefs.dart';
import 'package:flow/routes/new_transaction/amount_text.dart';
import 'package:flow/routes/new_transaction/input_amount_sheet/calculator_button.dart';
import 'package:flow/routes/new_transaction/input_amount_sheet/input_value.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/utils/shortcut.dart';
import 'package:flow/utils/toast.dart';
import 'package:flow/utils/utils.dart';
import 'package:flow/widgets/numpad.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

enum CalculatorOperation {
  add,
  subtract,
  multiply,
  divide,
}

class InputAmountSheet extends StatefulWidget {
  static const double maxValue = 10e13;

  /// [ISO 4217](https://en.wikipedia.org/wiki/ISO_4217) currency code
  final String? currency;
  final double? initialAmount;

  /// Whether user input should erase the former value
  final bool overrideInitialAmount;

  /// If user have multiple accounts with different currencies, we can't be
  /// sure which currency transaction the user is making.
  final bool hideCurrencySymbol;

  /// Will be ignored if [lockSign] is set to `true`
  final bool allowNegative;

  /// Disable changing between + and -
  final bool lockSign;

  /// Small title on top of the amount
  final String? title;

  /// Whether this numpad should have a calculator button
  final bool hasCalculator;

  const InputAmountSheet({
    super.key,
    this.title,
    this.initialAmount,
    this.currency,
    this.overrideInitialAmount = true,
    this.hasCalculator = true,
    this.hideCurrencySymbol = false,
    this.allowNegative = true,
    this.lockSign = false,
  });

  @override
  State<InputAmountSheet> createState() => _InputAmountSheetState();
}

class _InputAmountSheetState extends State<InputAmountSheet>
    with SingleTickerProviderStateMixin {
  final FocusNode _amountSelectionAreaFocusNode = FocusNode();

  late InputValue value;

  /// Number of decimals used for a currency
  late int _numberOfDecimals;

  bool _inputtingDecimal = false;
  bool _resetOnNextInput = false;

  bool _calculatorMode = false;

  CalculatorOperation? _currentOperation;
  InputValue? _operationCache;

  @override
  void initState() {
    super.initState();

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

    _updateAmountFromNumber(widget.initialAmount ?? 0.0);
  }

  @override
  void dispose() {
    _amountSelectionAreaFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: bindings,
      child: Focus(
        autofocus: true,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16.0),
              if (widget.title != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    widget.title!,
                    style: context.textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 12.0),
              ],
              AmountText(
                value: value,
                currency: widget.currency,
                focusNode: _amountSelectionAreaFocusNode,
                inputtingDecimal: _inputtingDecimal,
                numberOfDecimals: _numberOfDecimals,
                hideCurrencySymbol: widget.hideCurrencySymbol,
              ),
              const SizedBox(height: 16.0),
              // Numpad
              Numpad(
                children: [
                  if (_calculatorMode) ...getCalculatorRow(),
                  ..._getNumberRow(0),
                  _calculatorMode
                      ? CalculatorButton(
                          operation: CalculatorOperation.multiply,
                          onTap: setCalculatorOperation,
                          currentOperation: _currentOperation,
                        )
                      : NumpadButton(
                          onTap: () => removeDigit(),
                          onLongPress: () => _reset(),
                          mainAxisCellCount: widget.lockSign ? 2 : 1,
                          child: const Icon(Symbols.backspace_rounded),
                        ),
                  ..._getNumberRow(1),
                  if (!widget.lockSign && !_calculatorMode)
                    NumpadButton(
                      child: widget.allowNegative
                          ? const Icon(Symbols.remove_rounded)
                          : const Icon(Symbols.add_rounded),
                      onTap: () => _negate(),
                    ),
                  if (_calculatorMode)
                    CalculatorButton(
                      operation: CalculatorOperation.add,
                      onTap: setCalculatorOperation,
                      currentOperation: _currentOperation,
                    ),
                  ..._getNumberRow(2),
                  widget.hasCalculator
                      ? (_calculatorMode
                          ? CalculatorButton(
                              operation: CalculatorOperation.subtract,
                              onTap: setCalculatorOperation,
                              currentOperation: _currentOperation,
                            )
                          : NumpadButton(
                              onTap: () => calculatorMode(),
                              child: const Icon(Symbols.calculate_rounded),
                            ))
                      : _doneButton(context),
                  NumpadButton(
                    onTap: () => insertDigit(0),
                    crossAxisCellCount: 2,
                    child: const Text("0"),
                  ),
                  NumpadButton(
                    child:
                        Text(getDecimalSeparatorForCurrency(widget.currency)),
                    onTap: () => decimalMode(),
                  ),
                  if (widget.hasCalculator) _doneButton(context),
                ],
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns iterable of three widgets
  ///
  /// [row] - 0, 1, 2
  Iterable<Widget> getCalculatorRow() {
    return [
      NumpadButton(
        child: _currentOperation == null ? const Text("AC") : const Text("C"),
        onTap: () => _reset(),
      ),
      NumpadButton(
        child: const Icon(Symbols.backspace_rounded),
        onTap: () => removeDigit(),
        onLongPress: () => _reset(),
      ),
      NumpadButton(
        child: const Icon(Symbols.percent_rounded),
        onTap: () {
          setCalculatorOperation(CalculatorOperation.divide);
          value = InputValue.fromDouble(100.0);
          evaluateCalculation();
        },
      ),
      CalculatorButton(
        operation: CalculatorOperation.divide,
        onTap: setCalculatorOperation,
        currentOperation: _currentOperation,
      ),
    ];
  }

  /// Returns iterable of three widgets
  ///
  /// [row] - 0, 1, 2
  Iterable<Widget> _getNumberRow(int row) {
    final useModernLayout =
        LocalPreferences().usePhoneNumpadLayout.value == true;

    late final List<int> digits;

    if (row <= 0) {
      digits = useModernLayout ? [1, 2, 3] : [7, 8, 9];
    } else if (row == 1) {
      digits = [4, 5, 6];
    } else {
      digits = useModernLayout ? [7, 8, 9] : [1, 2, 3];
    }

    return digits.map(
      (digit) => NumpadButton(
        child: Text(digit.toString()),
        onTap: () => insertDigit(digit),
      ),
    );
  }

  Widget _doneButton(BuildContext context) {
    final bool popOnClick = !_calculatorMode || _currentOperation == null;

    return NumpadButton(
      backgroundColor: popOnClick ? context.flowColors.income : null,
      crossAxisCellCount: widget.hasCalculator ? 1 : 2,
      onTap: () {
        if (popOnClick) {
          _saveOrPop();
        } else {
          evaluateCalculation();
        }
      },
      child: Icon(
        popOnClick ? Symbols.check : Symbols.equal_rounded,
        color: popOnClick ? context.colorScheme.background : null,
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
      if (value.decimalLength < _numberOfDecimals) {
        value = value.appendDecimal(n);
      }
    } else {
      final InputValue newValue = value.appendWhole(n);

      if (newValue.currentAmount <= InputAmountSheet.maxValue) {
        value = newValue;
      }
    }

    setState(() {});
  }

  void removeDigit() {
    // If user is removing digit, they are likely
    // to be changing the last few numbers around

    if (_resetOnNextInput) {
      _resetOnNextInput = false;
    }

    if (_inputtingDecimal) {
      if (value.decimalLength == 0) {
        _inputtingDecimal = false;
      }
      value = value.removeDecimal();
    } else {
      if (value.wholePart.abs() == 0) {
        HapticFeedback.heavyImpact();
      }
      value = value.removeWhole();
    }

    setState(() {});
  }

  void _negate([bool? forceNegative]) {
    if (widget.lockSign) return;

    if (widget.allowNegative) {
      value = value.negated(forceNegative);
    } else {
      value = value.abs();
    }

    setState(() {});
  }

  void _saveOrPop() {
    if (_calculatorMode && _currentOperation != null) {
      evaluateCalculation();
      return;
    }

    context.pop(value.currentAmount);
  }

  void _reset() {
    value = InputValue.zero.negated(value.isNegative);
    _inputtingDecimal = false;
    _resetOnNextInput = false;
    setState(() {});
  }

  void _paste() async {
    final ClipboardData? clipboardData = await Clipboard.getData("text/plain");

    if (clipboardData == null ||
        clipboardData.text == null ||
        clipboardData.text!.trim().isEmpty) return;

    final parsed =
        num.tryParse(clipboardData.text!.replaceAll(RegExp(r"[^\d.]"), ""));

    if (parsed == null) return;

    _updateAmountFromNumber(parsed);
    _resetOnNextInput = true;
    setState(() {});
  }

  void _copy() {
    // Unselect text to avoid confusion
    _amountSelectionAreaFocusNode.unfocus();

    Clipboard.setData(
      ClipboardData(
        text: value.currentAmount.toStringAsFixed(value.decimalLength),
      ),
    );

    context.showToast(text: "general.copy.success".t(context));
  }

  void _updateAmountFromNumber(num initialAmount) {
    initialAmount = initialAmount.toDouble();
    final int wholePart = initialAmount.abs().truncate();
    final int decimalPart = ((initialAmount - initialAmount.truncate()).abs() *
            math.pow(10, _numberOfDecimals))
        .round();
    _inputtingDecimal = decimalPart.abs() != 0;
    final bool isNegative =
        widget.allowNegative ? (widget.initialAmount ?? 1.0).isNegative : false;

    value = InputValue(
        wholePart: wholePart, decimalPart: decimalPart, isNegative: isNegative);
  }

  void calculatorMode() {
    setState(() {
      _calculatorMode = true;
    });
  }

  void setCalculatorOperation(CalculatorOperation op) {
    if (!_calculatorMode) return;

    if (_currentOperation == null) {
      _operationCache = value;
      value = InputValue.zero;
      _inputtingDecimal = false;
    }

    _currentOperation = op;

    setState(() {});
  }

  void evaluateCalculation() {
    if (!_calculatorMode) return;

    if (_operationCache == null) return;
    if (_currentOperation == null) return;

    switch (_currentOperation!) {
      case CalculatorOperation.add:
        value = _operationCache!.add(value);
        break;
      case CalculatorOperation.subtract:
        value = _operationCache!.subtract(value);
        break;
      case CalculatorOperation.multiply:
        value = _operationCache!.multiply(value);
        break;
      case CalculatorOperation.divide:
        value = _operationCache!.divide(value);
        break;
    }

    _inputtingDecimal = value.decimalLength > 0;

    _operationCache = null;
    _currentOperation = null;

    setState(() {});
  }

  void _shortcutMinusKey() {
    if (_calculatorMode) {
      setCalculatorOperation(CalculatorOperation.subtract);
    } else {
      _negate();
    }
  }

  void _shortcutPlusKey() {
    if (_calculatorMode) {
      setCalculatorOperation(CalculatorOperation.add);
    } else {
      _negate(false);
    }
  }

  void _shortcutMultiplyKey() {
    if (_calculatorMode) {
      setCalculatorOperation(CalculatorOperation.multiply);
    }
  }

  void _shortcutDivideKey() {
    if (_calculatorMode) {
      setCalculatorOperation(CalculatorOperation.divide);
    }
  }

  Map<ShortcutActivator, VoidCallback> get bindings => {
        const CharacterActivator('/'): () => _shortcutDivideKey(),
        const CharacterActivator('*'): () => _shortcutMultiplyKey(),
        const CharacterActivator('+'): () => _shortcutPlusKey(),
        const CharacterActivator('-'): () => _shortcutMinusKey(),
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
        const SingleActivator(LogicalKeyboardKey.period): () => decimalMode(),
        const SingleActivator(LogicalKeyboardKey.numpadDecimal): () =>
            decimalMode(),
        const SingleActivator(LogicalKeyboardKey.enter): () => _saveOrPop(),
        const SingleActivator(LogicalKeyboardKey.numpadEnter): () =>
            _saveOrPop(),
        const SingleActivator(LogicalKeyboardKey.backspace): () =>
            removeDigit(),
        osSingleActivator(LogicalKeyboardKey.backspace): () => _reset(),
        osSingleActivator(LogicalKeyboardKey.keyC): () => _copy(),
        osSingleActivator(LogicalKeyboardKey.keyV): () => _paste(),
      };
}
