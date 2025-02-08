import "package:flow/data/transactions_filter/search_data.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/utils/optional.dart";
import "package:flutter/foundation.dart" hide Category;
import "package:moment_dart/moment_dart.dart";

export "package:flow/data/transactions_filter/search_data.dart";

typedef TransactionPredicate = bool Function(Transaction);

enum TransactionSortField {
  /// Default
  transactionDate,
  amount,
  createdDate;
}

enum TransactionGroupRange implements LocalizedEnum {
  hour,

  /// Default
  day,
  week,
  month,
  year;

  @override
  String get localizationEnumName => "TransactionGroupRange";

  @override
  String get localizationEnumValue => name;

  TimeRange fromTransaction(Transaction t) => switch (this) {
        TransactionGroupRange.hour =>
          HourTimeRange.fromDateTime(t.transactionDate),
        TransactionGroupRange.day =>
          DayTimeRange.fromDateTime(t.transactionDate),
        TransactionGroupRange.week => LocalWeekTimeRange(t.transactionDate),
        TransactionGroupRange.month =>
          MonthTimeRange.fromDateTime(t.transactionDate),
        TransactionGroupRange.year =>
          YearTimeRange.fromDateTime(t.transactionDate),
      };
}

/// For all fields, disabled if it's null.
///
/// All values must be wrapped by [Optional]
class TransactionFilter {
  /// If null, all-time
  final TimeRange? range;

  final List<String>? uuids;

  final TransactionSearchData searchData;

  final List<TransactionType>? types;

  final List<Category>? categories;
  final List<Account>? accounts;

  final bool sortDescending;
  final TransactionSortField sortBy;

  final TransactionGroupRange groupBy;

  final bool? isPending;

  final double? minAmount;
  final double? maxAmount;

  final List<String>? currencies;

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
    this.sortDescending = true,
    this.searchData = const TransactionSearchData(),
    this.sortBy = TransactionSortField.transactionDate,
    this.groupBy = TransactionGroupRange.day,
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

    if (uuids?.isNotEmpty == true) {
      predicates.add(
        (Transaction t) => uuids!.any((uuid) => t.uuid == uuid),
      );
    }

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
        conditions.add(Transaction_.isPending
            .notEquals(true)
            .or(Transaction_.isPending.isNull()));
      }
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
    Optional<TransactionGroupRange>? groupBy,
    Optional<bool>? isPending,
    Optional<double>? minAmount,
    Optional<double>? maxAmount,
    Optional<List<String>>? currencies,
  }) {
    return TransactionFilter(
      types: types == null ? this.types : types.value,
      range: range == null ? this.range : range.value,
      searchData: searchData ?? this.searchData,
      categories: categories == null ? this.categories : categories.value,
      accounts: accounts == null ? this.accounts : accounts.value,
      sortBy: sortBy ?? this.sortBy,
      groupBy: (groupBy == null || groupBy.value == null)
          ? this.groupBy
          : groupBy.value!,
      sortDescending: sortDescending ?? this.sortDescending,
      isPending: isPending == null ? this.isPending : isPending.value,
      minAmount: minAmount == null ? this.minAmount : minAmount.value,
      maxAmount: maxAmount == null ? this.maxAmount : maxAmount.value,
      currencies: currencies == null ? this.currencies : currencies.value,
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
        groupBy,
        isPending,
        minAmount,
        maxAmount,
        currencies,
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
        setEquals(other.currencies?.toSet(), currencies?.toSet()) &&
        setEquals(other.types?.toSet(), types?.toSet()) &&
        setEquals(other.categories?.toSet(), categories?.toSet()) &&
        setEquals(other.accounts?.toSet(), accounts?.toSet());
  }
}
