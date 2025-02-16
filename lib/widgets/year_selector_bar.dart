import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/utils/time_and_range.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class YearSelectorBar extends StatelessWidget {
  /// If specified, used instead of `DateTime.now`
  final DateTime? anchor;

  final int year;

  final Function(int year) onUpdate;

  const YearSelectorBar({
    super.key,
    required this.year,
    required this.onUpdate,
    this.anchor,
  });
  YearSelectorBar.fromDate({
    super.key,
    required DateTime value,
    required this.onUpdate,
    this.anchor,
  }) : year = value.year;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        IconButton(
          onPressed: prev,
          icon: const Icon(Symbols.chevron_left_rounded),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Button(
            child: Text(year.toString(), textAlign: TextAlign.center),
            onTap: () => select(context),
          ),
        ),
        const SizedBox(width: 8.0),
        IconButton(
          onPressed: next,
          icon: const Icon(Symbols.chevron_right_rounded),
        ),
      ],
    );
  }

  void next() {
    onUpdate.call(year + 1);
  }

  void prev() {
    onUpdate.call(year - 1);
  }

  void select(BuildContext context) async {
    final DateTime? value = await showYearPickerSheet(
      context,
      initialDate: DateTime(year),
    );

    if (value == null || !context.mounted) return;

    onUpdate(value.year);
  }
}
