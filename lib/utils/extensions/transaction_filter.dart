import "package:flow/data/transaction_filter.dart";
import "package:flow/data/transactions_filter/time_range.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/widgets/utils/time_and_range.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

extension TransactionFilterHelpers on TransactionFilter {
  String summary(BuildContext context) {
    final List<String> parts = [];
    if (searchData.keyword != null && searchData.keyword!.isNotEmpty) {
      parts.add('"${searchData.keyword}"');
    }

    parts.add(
      getValueLabel(
        context,
        translationKey: "transactions.query.filter.timeRange",
        value: range,
      ),
    );

    if (accounts?.isNotEmpty == true) {
      parts.add(
        "transactions.query.filter.accounts.n".t(context, accounts!.length),
      );
    }

    if (categories?.isNotEmpty == true) {
      parts.add(
        "transactions.query.filter.categories.n".t(context, categories!.length),
      );
    }

    if (currencies?.isNotEmpty == true) {
      parts.add(
        getValueLabel(
          context,
          translationKey: "transactions.query.filter.currency",
          value: currencies,
        ),
      );
    }

    parts.add(
      getValueLabel(
        context,
        translationKey: "transactions.query.filter.groupBy",
        value: groupBy,
      ),
    );

    return parts.join(", ");
  }

  static String getValueLabel<T>(
    BuildContext context, {
    dynamic value,
    required String translationKey,

    /// Override [getValueLabel]. If `null` was returned, continues with the default
    /// implementation. For example, you can typecheck the value to override specific values
    final String? Function(T?)? valueLabelOverride,
  }) {
    if (valueLabelOverride != null) {
      final String? overriden = valueLabelOverride(value);
      if (overriden != null) {
        return overriden;
      }
    }

    if (value == null) {
      return "$translationKey.all".t(context);
    }

    if (value case TransactionFilterTimeRange filterTimeRange) {
      return filterTimeRange.preset?.localizedNameContext(context) ??
          filterTimeRange.range?.format() ??
          "-";
    }

    if (value case TimeRange timeRange) {
      if (timeRange == last30DaysRange()) {
        return "tabs.stats.timeRange.last30days".t(context);
      }

      return timeRange.format();
    }

    if (value case Account account) {
      return account.name;
    }

    if (value case Category category) {
      return category.name;
    }

    if (value case TransactionSearchData searchData) {
      if (searchData.normalizedKeyword != null) {
        return searchData.keyword ?? "";
      } else {
        return "transactions.query.filter.keyword".t(context);
      }
    }

    if (value case LocalizedEnum localizedEnum) {
      return localizedEnum.localizedNameContext(context);
    }

    if (value case Iterable<dynamic> list) {
      if (list.length > 2) {
        if (list.first is Account) {
          return "transactions.query.filter.accounts.n".t(context, list.length);
        } else if (list.first is Category) {
          return "transactions.query.filter.categories.n".t(
            context,
            list.length,
          );
        }
      }

      final String items = list
          .map(
            (item) => getValueLabel(
              context,
              value: item,
              translationKey: translationKey,
              valueLabelOverride: valueLabelOverride,
            ),
          )
          .join(", ");

      if (list.length == 1) {
        return items;
      }

      return "(${list.length}) $items";
    }

    return value.toString();
  }
}
