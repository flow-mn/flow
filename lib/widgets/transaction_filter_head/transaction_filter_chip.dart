import "package:flow/l10n/extensions.dart";
import "package:flow/utils/extensions/transaction_filter.dart";
import "package:flutter/material.dart";

class TransactionFilterChip<T> extends StatelessWidget {
  final Widget? avatar;

  final bool? highlightOverride;

  /// Translation key for the label
  ///
  /// Requires following keys in the translation file:
  /// * `${translationKey}`
  /// * `${translationKey}.all`
  final String translationKey;
  final T? value;
  final T? defaultValue;

  bool get highlight => highlightOverride ?? value != defaultValue;

  /// * If [defaultValue] and [value] are null, displays translated [translationKey]
  /// * If [defaultValue] isn't null, but [value] is null, displays translated `$translationKey.all`
  /// * Otherwise, `valueLabelOverride(value)` if available, else `value.toString()`.
  ///
  /// First argument is the **current** value, second is the **default**.
  final String Function(T? value, T? defaultValue)? displayLabelOverride;

  /// Override [getValueLabel]. If `null` was returned, continues with the default
  /// implementation. For example, you can typecheck the value to override specific values
  final String? Function(T?)? valueLabelOverride;

  final VoidCallback onSelect;

  const TransactionFilterChip({
    super.key,
    this.avatar,
    this.value,
    this.defaultValue,
    this.displayLabelOverride,
    required this.translationKey,
    required this.onSelect,
    this.valueLabelOverride,
    this.highlightOverride,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      showCheckmark: false,
      avatar: avatar,
      label: Text(
        getLabel(context),
        overflow: TextOverflow.ellipsis,
      ),
      onSelected: (_) => onSelect(),
      selected: highlight,
    );
  }

  String getLabel(BuildContext context) {
    if (displayLabelOverride != null) {
      return displayLabelOverride!(value, defaultValue);
    }

    if (value != null) {
      return TransactionFilterHelpers.getValueLabel(
        context,
        value: value,
        translationKey: translationKey,
        valueLabelOverride: valueLabelOverride,
      );
    }

    if (defaultValue == null) {
      return translationKey.t(context);
    } else {
      return "$translationKey.all".t(context);
    }
  }
}
