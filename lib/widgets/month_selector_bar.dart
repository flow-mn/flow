import 'package:flow/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class MonthSelectorBar extends StatelessWidget {
  /// If specified, used instead of `DateTime.now`
  final DateTime? anchor;

  final int year;
  final int month;

  final Function(int year, int month)? onUpdate;

  const MonthSelectorBar({
    super.key,
    required this.year,
    required this.month,
    this.onUpdate,
    this.anchor,
  });
  MonthSelectorBar.fromDate({
    super.key,
    required DateTime value,
    this.onUpdate,
    this.anchor,
  })  : year = value.year,
        month = value.month;

  @override
  Widget build(BuildContext context) {
    final bool showYear = (anchor ?? DateTime.now()).year != year;
    final String monthName = DateTime(year, month, 1)
        .format(payload: showYear ? 'MMMM YYYY' : "MMMM");

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        IconButton(
            onPressed: prev, icon: const Icon(Symbols.chevron_left_rounded)),
        const SizedBox(width: 8.0),
        Expanded(
          child: Button(
            child: Text(
              monthName,
              textAlign: TextAlign.center,
            ),
            onTap: () => select(context),
          ),
        ),
        // InkWell(
        //   onTap: () => select(context),
        //   child: Text(monthName),
        // ),
        const SizedBox(width: 8.0),
        IconButton(
            onPressed: next, icon: const Icon(Symbols.chevron_right_rounded)),
      ],
    );
  }

  void next() {
    if (month == 12) {
      onUpdate?.call(year + 1, 1);
    } else {
      onUpdate?.call(year, month + 1);
    }
  }

  void prev() {
    if (month == 1) {
      onUpdate?.call(year - 1, 12);
    } else {
      onUpdate?.call(year, month - 1);
    }
  }

  void select(BuildContext context) async {
    final DateTime? value = await showMonthPicker(
      context: context,
      initialDate: DateTime(year, month),
    );

    if (value == null || onUpdate == null || !context.mounted) return;

    onUpdate!(value.year, value.month);
  }
}
