import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

class YearButton extends StatelessWidget {
  final DateTime? currentDate;

  final DateTime year;

  final VoidCallback? onTap;

  final BorderRadius borderRadius;

  const YearButton({
    super.key,
    required this.year,
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
    this.currentDate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime now = Moment.startOfThisYear();
    final bool selected = currentDate?.isAtSameYearAs(year) == true;
    final bool highlighted = now.isAtSameYearAs(year);
    final bool future = year.startOfYear().isAfter(now);

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
              color: selected ? context.colorScheme.primary : kTransparent,
              style: BorderStyle.solid,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
        ),
        child: Text(
          year.format(payload: "yyyy"),
          textAlign: TextAlign.center,
          style: future
              ? context.textTheme.bodyMedium?.semi(context)
              : context.textTheme.bodyMedium?.copyWith(
                  color: highlighted ? context.colorScheme.primary : null,
                  fontWeight: highlighted ? FontWeight.w500 : null,
                ),
        ),
      ),
    );
  }
}
