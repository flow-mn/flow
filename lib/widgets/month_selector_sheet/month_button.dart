import 'package:flow/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:moment_dart/moment_dart.dart';

class MonthButton extends StatelessWidget {
  final DateTime? currentDate;

  final DateTime month;

  final VoidCallback? onTap;

  final BorderRadius borderRadius;

  const MonthButton({
    super.key,
    required this.month,
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
    this.currentDate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime now = Moment.startOfThisMonth();
    final bool selected = currentDate?.isAtSameMonthAs(month) == true;
    final bool highlighted = now.isAtSameMonthAs(month);
    final bool future = month.startOfMonth().isAfter(now);

    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: selected
              ? context.colorScheme.secondary
              : context.colorScheme.surface,
          borderRadius: borderRadius,
          border: Border.fromBorderSide(
            BorderSide(
              width: 2.0,
              color: highlighted ? context.colorScheme.primary : kTransparent,
              style: BorderStyle.solid,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
        ),
        child: Text(
          month.format(payload: "MMMM"),
          textAlign: TextAlign.center,
          style: future
              ? context.textTheme.bodyMedium?.medium.semi(context)
              : context.textTheme.bodyMedium?.medium,
        ),
      ),
    );
  }
}
