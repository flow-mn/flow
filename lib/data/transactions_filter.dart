import 'package:flow/data/transactions_filter/search_data.dart';
import 'package:flow/entity/account.dart';
import 'package:flow/entity/category.dart';
import 'package:flow/entity/transaction.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/objectbox.g.dart';
import 'package:flow/utils/optional.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:moment_dart/moment_dart.dart';

export 'package:flow/data/transactions_filter/search_data.dart';

typedef TransactionPredicate = bool Function(Transaction);

enum TransactionSortField {
  /// Default
  transactionDate,
  amount,
  createdDate;
}

/// For all fields, disabled if it's null.
///
/// All values must be wrapped by [Optional]
class TransactionFilter {
  /// If null, all-time
  final TimeRange? range;

  final TransactionSearchData searchData;

  final List<TransactionType>? types;

  final List<Category>? categories;
  final List<Account>? accounts;

  final bool sortDescending;
  final TransactionSortField sortBy;

  const TransactionFilter({
    this.categories,
    this.accounts,
    this.range,
    this.types,
    this.sortDescending = true,
    this.searchData = const TransactionSearchData(),
    this.sortBy = TransactionSortField.transactionDate,
  });

  static const empty = TransactionFilter();

  List<TransactionPredicate> get postPredicates {
    final List<TransactionPredicate> predicates = [];

    if (types?.isNotEmpty == true) {
      predicates.add(
        (Transaction t) => types!.contains(t.type),
      );
    }

    predicates.add(searchData.predicate);

    return predicates;
  }

  List<TransactionPredicate> get predicates {
    final List<TransactionPredicate> predicates = [];

    if (range case TimeRange filterTimeRange) {
      predicates
          .add((Transaction t) => filterTimeRange.contains(t.transactionDate));
    }

    if (types?.isNotEmpty == true) {
      predicates.add(
        (Transaction t) => types!.contains(t.type),
      );
    }

    predicates.add(searchData.predicate);

    if (categories?.isNotEmpty == true) {
      predicates.add(
        (Transaction t) => categories!.any(
          (category) => t.categoryUuid == category.uuid,
        ),
      );
    }

    if (accounts?.isNotEmpty == true) {
      predicates.add(
        (Transaction t) => accounts!.any(
          (account) => t.accountUuid == account.uuid,
        ),
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

    if (range case TimeRange filterTimeRange) {
      conditions.add(Transaction_.transactionDate
          .betweenDate(filterTimeRange.from, filterTimeRange.to));
    }

    final searchFilter = searchData.filter;
    if (searchFilter != null) {
      conditions.add(searchFilter);
    }

    if (categories?.isNotEmpty == true) {
      conditions.add(Transaction_.categoryUuid
          .oneOf(categories!.map((category) => category.uuid).toList()));
    }

    if (accounts?.isNotEmpty == true) {
      conditions.add(Transaction_.accountUuid
          .oneOf(accounts!.map((account) => account.uuid).toList()));
    }

    final filtered = ObjectBox()
        .box<Transaction>()
        .query(conditions.reduce((a, b) => a & b));

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

  TransactionFilter copyWithOptional({
    Optional<List<TransactionType>>? types,
    Optional<TimeRange>? range,
    TransactionSearchData? searchData,
    Optional<List<Category>>? categories,
    Optional<List<Account>>? accounts,
    bool? sortDescending,
    TransactionSortField? sortBy,
  }) {
    return TransactionFilter(
      types: types == null ? this.types : types.value,
      range: range == null ? this.range : range.value,
      searchData: searchData ?? this.searchData,
      categories: categories == null ? this.categories : categories.value,
      accounts: accounts == null ? this.accounts : accounts.value,
      sortBy: sortBy ?? this.sortBy,
      sortDescending: sortDescending ?? this.sortDescending,
    );
  }

  @override
  int get hashCode => Object.hashAll([
        types,
        range,
        searchData,
        categories,
        accounts,
        sortDescending,
        sortBy,
      ]);

  @override
  bool operator ==(Object other) {
    if (other is! TransactionFilter) return false;

    return other.range == range &&
        other.sortDescending == sortDescending &&
        other.sortBy == sortBy &&
        other.searchData == searchData &&
        setEquals(other.types?.toSet(), types?.toSet()) &&
        setEquals(other.categories?.toSet(), categories?.toSet()) &&
        setEquals(other.accounts?.toSet(), accounts?.toSet());
  }
}
