import "dart:convert";

import "package:flow/data/transactions_filter/group_range.dart";
import "package:flow/data/transactions_filter/search_data.dart";
import "package:flow/data/transactions_filter/sort_field.dart";
import "package:flow/data/transactions_filter/time_range.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/utils/json/time_range_converter.dart";
import "package:flow/utils/utils.dart";
import "package:flutter/foundation.dart" hide Category;
import "package:json_annotation/json_annotation.dart";
import "package:moment_dart/moment_dart.dart";

export "./transactions_filter/group_range.dart";
export "./transactions_filter/search_data.dart";
export "./transactions_filter/sort_field.dart";

part "transaction_filter.g.dart";

typedef TransactionPredicate = bool Function(Transaction);

/// For all fields, disabled if it's null.
///
/// All values must be wrapped by [Optional]
@JsonSerializable(explicitToJson: true, converters: [TimeRangeConverter()])
class TransactionFilter implements Jasonable {
  final TransactionFilterTimeRange? range;

  final List<String>? uuids;

  final TransactionSearchData searchData;

  final List<TransactionType>? types;

  final List<String>? categories;
  final List<String>? accounts;

  final bool sortDescending;
  final TransactionSortField sortBy;

  final TransactionGroupRange groupBy;

  final bool? isPending;

  final double? minAmount;
  final double? maxAmount;

  final List<String>? currencies;

  /// Lookup for [Transaction.extraKeys]
  final String? extensionKeyPartial;

  /// Defaults to false
  final bool? includeDeleted;

  const TransactionFilter({
    this.uuids,
    this.categories,
    this.accounts,
    this.range,
    this.types,
    this.isPending,
    this.minAmount,
    this.maxAmount,
    this.currencies,
    this.extensionKeyPartial,
    this.includeDeleted = false,
    this.sortDescending = true,
    this.searchData = const TransactionSearchData(),
    this.sortBy = TransactionSortField.transactionDate,
    this.groupBy = TransactionGroupRange.day,
  });

  static const empty = TransactionFilter();
  static const all = TransactionFilter(includeDeleted: true);

  /// Returns whether this [filter] contains any references that isn't
  /// resolvable to existing [Account] and/or [Category].
  bool validate({
    required Set<String> accounts,
    required Set<String> categories,
  }) {
    if (this.accounts?.isNotEmpty == true &&
        this.accounts!.any((accountUuid) => !accounts.contains(accountUuid))) {
      return false;
    }

    if (this.categories?.isNotEmpty == true &&
        this.categories!.any(
          (categoryUuid) => !categories.contains(categoryUuid),
        )) {
      return false;
    }

    return true;
  }

  List<TransactionPredicate> get postPredicates {
    final List<TransactionPredicate> predicates = [];

    if (types?.isNotEmpty == true) {
      predicates.add((Transaction t) => types!.contains(t.type));
    }

    predicates.add(searchData.predicate);

    return predicates;
  }

  List<TransactionPredicate> get predicates {
    final List<TransactionPredicate> predicates = [];

    if (uuids?.isNotEmpty == true) {
      predicates.add((Transaction t) => uuids!.any((uuid) => t.uuid == uuid));
    }

    if (range case TimeRange filterTimeRange) {
      predicates.add(
        (Transaction t) => filterTimeRange.contains(t.transactionDate),
      );
    }

    if (types?.isNotEmpty == true) {
      predicates.add((Transaction t) => types!.contains(t.type));
    }

    predicates.add(searchData.predicate);

    if (categories?.isNotEmpty == true) {
      predicates.add(
        (Transaction t) =>
            categories!.any((category) => t.categoryUuid == category),
      );
    }

    if (accounts?.isNotEmpty == true) {
      predicates.add(
        (Transaction t) => accounts!.any((account) => t.accountUuid == account),
      );
    }

    if (minAmount != null) {
      predicates.add((Transaction t) => t.amount >= minAmount!);
    }

    if (maxAmount != null) {
      predicates.add((Transaction t) => t.amount <= maxAmount!);
    }

    if (currencies?.isNotEmpty == true) {
      predicates.add((Transaction t) => currencies!.contains(t.currency));
    }

    if (isPending != null) {
      predicates.add((Transaction t) {
        if (isPending!) {
          return t.isPending == true;
        } else {
          return t.isPending == null || !t.isPending!;
        }
      });
    }

    if (extensionKeyPartial != null) {
      predicates.add(
        (Transaction t) =>
            t.extraKeys != null && t.extraKeys!.contains(extensionKeyPartial!),
      );
    }

    if (includeDeleted != true) {
      predicates.add(
        (Transaction t) => t.isDeleted == null || t.isDeleted == false,
      );
    }

    return predicates;
  }

  /// Here, we don't have any fancy fuzzy finding, so
  /// [ignoreKeywordFilter] is enabled by default.
  ///
  /// For now, let's do fuzzywuzzy after we fetch the objects
  /// into memory
  QueryBuilder<Transaction> queryBuilder({bool ignoreKeywordFilter = true}) {
    final List<Condition<Transaction>> conditions = [];

    if (uuids?.isNotEmpty == true) {
      conditions.add(Transaction_.uuid.oneOf(uuids!));
    }

    if (range case TimeRange filterTimeRange) {
      conditions.add(
        Transaction_.transactionDate.betweenDate(
          filterTimeRange.from,
          filterTimeRange.to,
        ),
      );
    }

    if (range case TransactionFilterTimeRange transactionFilterTimeRange) {
      final TimeRange? range = transactionFilterTimeRange.range;

      if (range != null) {
        conditions.add(
          Transaction_.transactionDate.betweenDate(range.from, range.to),
        );
      }
    }

    final searchFilter = searchData.filter;
    if (searchFilter != null) {
      conditions.add(searchFilter);
    }

    if (categories?.isNotEmpty == true) {
      conditions.add(Transaction_.categoryUuid.oneOf(categories!));
    }

    if (accounts?.isNotEmpty == true) {
      conditions.add(Transaction_.accountUuid.oneOf(accounts!));
    }

    if (minAmount != null) {
      conditions.add(Transaction_.amount.greaterOrEqual(minAmount!));
    }

    if (maxAmount != null) {
      conditions.add(Transaction_.amount.lessOrEqual(maxAmount!));
    }

    if (currencies?.isNotEmpty == true) {
      conditions.add(Transaction_.currency.oneOf(currencies!));
    }

    if (isPending != null) {
      if (isPending!) {
        conditions.add(Transaction_.isPending.equals(true));
      } else {
        conditions.add(
          Transaction_.isPending
              .notEquals(true)
              .or(Transaction_.isPending.isNull()),
        );
      }
    }

    if (extensionKeyPartial != null) {
      conditions.add(
        Transaction_.extraKeys.notNull().and(
          Transaction_.extraKeys.contains(extensionKeyPartial!),
        ),
      );
    }

    if (includeDeleted != true) {
      conditions.add(
        Transaction_.isDeleted.isNull().or(
          Transaction_.isDeleted.notEquals(true),
        ),
      );
    }

    final filtered = ObjectBox().box<Transaction>().query(
      conditions.isNotEmpty ? conditions.reduce((a, b) => a & b) : null,
    );

    return switch (sortBy) {
      TransactionSortField.amount => filtered.order(
        Transaction_.amount,
        flags: sortDescending ? Order.descending : 0,
      ),
      TransactionSortField.createdDate => filtered.order(
        Transaction_.createdDate,
        flags: sortDescending ? Order.descending : 0,
      ),
      TransactionSortField.transactionDate => filtered.order(
        Transaction_.transactionDate,
        flags: sortDescending ? Order.descending : 0,
      ),
    };
  }

  int calculateDifferentFieldCount(TransactionFilter other) {
    int count = 0;

    if (range != other.range) {
      count++;
    }

    if (sortDescending != other.sortDescending) {
      count++;
    }

    if (sortBy != other.sortBy) {
      count++;
    }

    if (groupBy != other.groupBy) {
      count++;
    }

    if (searchData != other.searchData) {
      count++;
    }

    if (isPending != other.isPending) {
      count++;
    }

    if (minAmount != other.minAmount) {
      count++;
    }

    if (maxAmount != other.maxAmount) {
      count++;
    }

    if (includeDeleted != other.includeDeleted) {
      count++;
    }

    if (!setEquals(uuids?.toSet(), other.uuids?.toSet())) {
      count++;
    }

    if (!setEquals(currencies?.toSet(), other.currencies?.toSet())) {
      count++;
    }

    if (!setEquals(types?.toSet(), other.types?.toSet())) {
      count++;
    }

    if (!setEquals(categories?.toSet(), other.categories?.toSet())) {
      count++;
    }

    if (!setEquals(accounts?.toSet(), other.accounts?.toSet())) {
      count++;
    }

    if (extensionKeyPartial != other.extensionKeyPartial) {
      count++;
    }

    return count;
  }

  TransactionFilter copyWithOptional({
    Optional<List<TransactionType>>? types,
    Optional<TransactionFilterTimeRange>? range,
    TransactionSearchData? searchData,
    Optional<List<String>>? categories,
    Optional<List<String>>? accounts,
    bool? sortDescending,
    TransactionSortField? sortBy,
    Optional<TransactionGroupRange>? groupBy,
    Optional<bool>? isPending,
    Optional<double>? minAmount,
    Optional<double>? maxAmount,
    Optional<List<String>>? currencies,
    Optional<String>? extensionKeyPartial,
  }) {
    return TransactionFilter(
      types: types == null ? this.types : types.value,
      range: range == null ? this.range : range.value,
      searchData: searchData ?? this.searchData,
      categories: categories == null ? this.categories : categories.value,
      accounts: accounts == null ? this.accounts : accounts.value,
      sortBy: sortBy ?? this.sortBy,
      groupBy:
          (groupBy == null || groupBy.value == null)
              ? this.groupBy
              : groupBy.value!,
      sortDescending: sortDescending ?? this.sortDescending,
      isPending: isPending == null ? this.isPending : isPending.value,
      minAmount: minAmount == null ? this.minAmount : minAmount.value,
      maxAmount: maxAmount == null ? this.maxAmount : maxAmount.value,
      currencies: currencies == null ? this.currencies : currencies.value,
      extensionKeyPartial:
          extensionKeyPartial == null
              ? this.extensionKeyPartial
              : extensionKeyPartial.value,
    );
  }

  @override
  int get hashCode => Object.hashAll([
    uuids,
    categories,
    accounts,
    range,
    types,
    isPending,
    minAmount,
    maxAmount,
    currencies,
    includeDeleted,
    sortDescending,
    searchData,
    sortBy,
    groupBy,
    extensionKeyPartial,
  ]);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! TransactionFilter) return false;

    return other.range == range &&
        other.sortDescending == sortDescending &&
        other.sortBy == sortBy &&
        other.groupBy == groupBy &&
        other.searchData == searchData &&
        other.isPending == isPending &&
        other.minAmount == minAmount &&
        other.maxAmount == maxAmount &&
        other.includeDeleted == includeDeleted &&
        other.isPending == isPending &&
        other.extensionKeyPartial == extensionKeyPartial &&
        setEquals(other.uuids?.toSet(), uuids?.toSet()) &&
        setEquals(other.currencies?.toSet(), currencies?.toSet()) &&
        setEquals(other.types?.toSet(), types?.toSet()) &&
        setEquals(other.categories?.toSet(), categories?.toSet()) &&
        setEquals(other.accounts?.toSet(), accounts?.toSet());
  }

  factory TransactionFilter.fromJson(Map<String, dynamic> json) =>
      _$TransactionFilterFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TransactionFilterToJson(this);

  String serialize() => jsonEncode(toJson());
  String deserialize(String json) => jsonDecode(json);
}

String? typesToJson(List<TransactionType>? items) {
  if (items == null || items.isEmpty) return null;

  return items.map((item) => item.value).join(";");
}

TransactionType? typesFromJson(String? json) {
  if (json == null || json.isEmpty) return null;

  return TransactionType.values.firstWhereOrNull((type) => type.value == json);
}
