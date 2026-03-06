import "dart:convert";

import "package:flow/data/string_multi_filter.dart";
import "package:flow/data/transactions_filter/group_range.dart";
import "package:flow/data/transactions_filter/search_data.dart";
import "package:flow/data/transactions_filter/sort_field.dart";
import "package:flow/data/transactions_filter/time_range.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/services/accounts.dart";
import "package:flow/services/categories.dart";
import "package:flow/services/transaction_tag.dart";
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

  @JsonKey(fromJson: StringMultiFilter.fromJsonOrList)
  final StringMultiFilter? categories;
  @JsonKey(fromJson: StringMultiFilter.fromJsonOrList)
  final StringMultiFilter? accounts;
  @JsonKey(fromJson: StringMultiFilter.fromJsonOrList)
  final StringMultiFilter? tags;

  /// When true, matches transactions that have all of the specified [tags].
  ///
  /// When false, matches transactions that have at least one of the specified [tags].
  final bool tagsAndRule;

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
    this.tagsAndRule = false,
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
    if (this.accounts?.items.isNotEmpty == true &&
        this.accounts!.items.any(
          (accountUuid) => !accounts.contains(accountUuid),
        )) {
      return false;
    }

    if (this.categories?.items.isNotEmpty == true &&
        this.categories!.items.any(
          (categoryUuid) => !categories.contains(categoryUuid),
        )) {
      return false;
    }

    if (this.tags?.items.isNotEmpty == true &&
        this.tags!.items.any((tag) => !tags.contains(tag))) {
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

  /// Here, we don't have any fancy fuzzy finding, so
  /// [ignoreKeywordFilter] is enabled by default.
  ///
  /// For now, let's do fuzzywuzzy after we fetch the objects
  /// into memory
  QueryBuilder<Transaction> queryBuilder({bool ignoreKeywordFilter = true}) {
    final List<Condition<Transaction>> conditions = [];

    final List<String>? accountUuids = accounts?.filter(
      AccountsService().getAllUuidsSync(),
    );
    final List<String>? categoryUuids = categories?.filter(
      CategoriesService().getAllUuidsSync(),
    );
    final List<String>? tagUuids = tags?.filter(
      TransactionTagService().getAllUuidsSync(),
    );

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

    if (categoryUuids != null) {
      if (categoryUuids.isEmpty) {
        conditions.add(Transaction_.categoryUuid.isNull());
      } else {
        conditions.add(Transaction_.categoryUuid.oneOf(categoryUuids));
      }
    }

    if (accountUuids != null) {
      conditions.add(Transaction_.accountUuid.oneOf(accountUuids));
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

    if (tagUuids != null) {
      if (tagsAndRule) {
        for (final tag in tagUuids) {
          filtered.linkMany(
            Transaction_.tags,
            TransactionTag_.uuid.equals(tag),
          );
        }
      } else {
        filtered.linkMany(
          Transaction_.tags,
          TransactionTag_.uuid.oneOf(tagUuids),
        );
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

    if (categories != other.categories) {
      count++;
    }

    if (accounts != other.accounts) {
      count++;
    }

    if (tags != other.tags) {
      count++;
    }

    if (tagsAndRule != other.tagsAndRule) {
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
    Optional<StringMultiFilter>? categories,
    Optional<StringMultiFilter>? accounts,
    Optional<StringMultiFilter>? tags,
    Optional<bool>? sortDescending,
    TransactionSortField? sortBy,
    Optional<TransactionGroupRange>? groupBy,
    Optional<bool>? isPending,
    Optional<double>? minAmount,
    Optional<double>? maxAmount,
    Optional<List<String>>? currencies,
    Optional<String>? extraTag,
    Optional<bool>? hasAttachments,
    Optional<bool>? tagsAndRule,
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
      tagsAndRule: tagsAndRule?.value ?? this.tagsAndRule,
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
        other.types == types &&
        other.categories == categories &&
        other.accounts == accounts &&
        setEquals(other.uuids?.toSet(), uuids?.toSet()) &&
        setEquals(other.currencies?.toSet(), currencies?.toSet());
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
