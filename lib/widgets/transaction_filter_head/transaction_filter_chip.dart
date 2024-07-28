import 'package:flow/entity/account.dart';
import 'package:flow/entity/category.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flutter/material.dart';
import 'package:moment_dart/moment_dart.dart';

class TransactionFilterChip<T> extends StatelessWidget {
  final Widget? avatar;

  /// Translation key for the label
  ///
  /// Requires following keys in the translation file:
  /// * `${translationKey}`
  /// * `${translationKey}.all`
  final String translationKey;
  final T? value;
  final T? defaultValue;

  bool get highlight => value != defaultValue;

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

  String getValueLabel(BuildContext context, dynamic value) {
    if (valueLabelOverride != null) {
      final String? overriden = valueLabelOverride!(value);
      if (overriden != null) {
        return overriden;
      }
    }

    if (value == null) {
      return "$translationKey.all".t(context);
    }

    if (value case TimeRange timeRange) {
      return timeRange.format();
    }

    if (value case Account account) {
      return account.name;
    }
    if (value case Category category) {
      return category.name;
    }

    if (value case List<dynamic> list) {
      if (list.length > 2) {
        if (list.first is Account) {
          return "transactions.query.filter.accounts.n".tr(list.length);
        } else if (list.first is Category) {
          return "transactions.query.filter.categories.n".tr(list.length);
        }
      }

      final String items =
          list.map((item) => getValueLabel(context, item)).join(", ");

      return "(${list.length}) $items";
    }

    return value.toString();
  }

  String getLabel(BuildContext context) {
    if (displayLabelOverride != null) {
      return displayLabelOverride!(value, defaultValue);
    }

    if (value != null) {
      return getValueLabel(context, value);
    }

    if (defaultValue == null) {
      return translationKey.t(context);
    } else {
      return "$translationKey.all".t(context);
    }
  }
}
