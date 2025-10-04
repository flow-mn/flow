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
  final List<String>? tags;

  /// When true, matches transactions that have all of the specified [tags].
  ///
  /// When false, matches transactions that have at least one of the specified [tags].
  final bool requireAllTags;

  final bool? hasAttachments;

  final bool sortDescending;
  final TransactionSortField sortBy;

  final TransactionGroupRange groupBy;

  final bool? isPending;

  final double? minAmount;
  final double? maxAmount;

  final List<String>? currencies;

  /// Matches if it's included in [Transaction.extraTags]
  final String? extraTag;

  /// Defaults to false
  final bool? includeDeleted;

  const TransactionFilter({
    this.uuids,
    this.categories,
    this.accounts,
    this.tags,
    this.range,
    this.types,
    this.isPending,
    this.minAmount,
    this.maxAmount,
    this.currencies,
    this.extraTag,
    this.hasAttachments,
    this.requireAllTags = false,
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
    required Set<String> tags,
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

    if (this.tags?.isNotEmpty == true &&
        this.tags!.any((tag) => !tags.contains(tag))) {
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

    if (tags?.isNotEmpty == true) {
      if (requireAllTags) {
        predicates.add(
          (Transaction t) =>
              tags!.every((tag) => t.tags.any((e) => e.uuid == tag)),
        );
      } else {
        predicates.add(
          (Transaction t) =>
              tags!.any((tag) => t.tags.any((e) => e.uuid == tag)),
        );
      }
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

    if (hasAttachments != null) {
      if (hasAttachments!) {
        predicates.add((Transaction t) => t.attachments.isNotEmpty);
      } else {
        predicates.add((Transaction t) => t.attachments.isEmpty);
      }
    }

    if (extraTag != null) {
      predicates.add((Transaction t) => t.extraTags.contains(extraTag));
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

    if (extraTag != null) {
      conditions.add(
        Transaction_.extraTags.notNull().and(
          Transaction_.extraTags.containsElement(extraTag!),
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

    if (tags != null && tags!.isNotEmpty) {
      if (requireAllTags) {
        for (final tag in tags!) {
          filtered.linkMany(
            Transaction_.tags,
            TransactionTag_.uuid.equals(tag),
          );
        }
      } else {
        filtered.linkMany(Transaction_.tags, TransactionTag_.uuid.oneOf(tags!));
      }
    }

    if (hasAttachments != null) {
      if (hasAttachments!) {
        filtered.linkMany(
          Transaction_.attachments,
          FileAttachment_.id.notEquals(0),
        );
      } else {
        filtered.linkMany(
          Transaction_.attachments,
          FileAttachment_.id.equals(0),
        );
      }
    }

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

    if (!setEquals(tags?.toSet(), other.tags?.toSet())) {
      count++;
    }

    if (requireAllTags != other.requireAllTags) {
      count++;
    }

    if (hasAttachments != other.hasAttachments) {
      count++;
    }

    if (isPending != other.isPending) {
      count++;
    }

    if (extraTag != other.extraTag) {
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
    Optional<List<String>>? tags,
    Optional<bool>? sortDescending,
    TransactionSortField? sortBy,
    Optional<TransactionGroupRange>? groupBy,
    Optional<bool>? isPending,
    Optional<double>? minAmount,
    Optional<double>? maxAmount,
    Optional<List<String>>? currencies,
    Optional<String>? extraTag,
    Optional<bool>? hasAttachments,
    Optional<bool>? requireAllTags,
  }) {
    return TransactionFilter(
      types: types != null ? types.value : this.types,
      range: range != null ? range.value : this.range,
      searchData: searchData ?? this.searchData,
      categories: categories != null ? categories.value : this.categories,
      accounts: accounts != null ? accounts.value : this.accounts,
      tags: tags != null ? tags.value : this.tags,
      sortBy: sortBy ?? this.sortBy,
      groupBy: groupBy?.value ?? this.groupBy,
      sortDescending: sortDescending?.value ?? this.sortDescending,
      isPending: isPending != null ? isPending.value : this.isPending,
      minAmount: minAmount != null ? minAmount.value : this.minAmount,
      maxAmount: maxAmount != null ? maxAmount.value : this.maxAmount,
      currencies: currencies != null ? currencies.value : this.currencies,
      extraTag: extraTag != null ? extraTag.value : this.extraTag,
      hasAttachments: hasAttachments != null
          ? hasAttachments.value
          : this.hasAttachments,
      requireAllTags: requireAllTags?.value ?? this.requireAllTags,
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
    extraTag,
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
        other.extraTag == extraTag &&
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
