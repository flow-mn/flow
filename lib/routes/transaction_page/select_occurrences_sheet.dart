import "package:flow/l10n/extensions.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flow/widgets/numpad.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class SelectOccurrencesSheet extends StatefulWidget {
  final int? initialValue;
  final int minValue;
  final int maxValue;

  const SelectOccurrencesSheet({
    super.key,
    this.initialValue,
    this.minValue = 1,
    this.maxValue = 999,
  });

  @override
  State<SelectOccurrencesSheet> createState() => _SelectOccurrencesSheetState();
}

class _SelectOccurrencesSheetState extends State<SelectOccurrencesSheet> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      title: Text("select.recurrence.occurrences".t(context)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Display current value
          Container(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              _value.toString(),
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
          ),
          // Numpad for input
          Numpad(
            crossAxisCount: 3,
            children: [
              // Numbers 1-9
              ..._getNumberButtons(),
              // Clear button
              NumpadButton(
                child: const Icon(Symbols.backspace_rounded),
                onTap: _backspace,
              ),
              // 0 button
              NumpadButton(
                child: const Text("0"),
                onTap: () => _appendDigit(0),
              ),
              // Done button
              NumpadButton(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(
                  Symbols.check,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                onTap: _done,
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  List<Widget> _getNumberButtons() {
    return List.generate(9, (index) {
      final number = index + 1;
      return NumpadButton(
        child: Text(number.toString()),
        onTap: () => _appendDigit(number),
      );
    });
  }

  void _appendDigit(int digit) {
    final String currentString = _value.toString();
    final String newString = _value == widget.minValue && _value < 10
        ? digit.toString()  // Replace single digit minimum value
        : currentString + digit.toString();
    final int? newValue = int.tryParse(newString);
    
    if (newValue != null && 
        newValue >= widget.minValue && 
        newValue <= widget.maxValue) {
      setState(() {
        _value = newValue;
      });
    }
  }

  void _backspace() {
    final String currentString = _value.toString();
    if (currentString.length > 1) {
      final String newString = currentString.substring(0, currentString.length - 1);
      final int? newValue = int.tryParse(newString);
      if (newValue != null && newValue >= widget.minValue) {
        setState(() {
          _value = newValue;
        });
        return;
      }
    }
    
    // If we can't backspace or result would be below minimum, reset to minimum
    setState(() {
      _value = widget.minValue;
    });
  }

  void _done() {
    context.pop(_value);
  }
}