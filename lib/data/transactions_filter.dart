import 'package:flow/entity/account.dart';
import 'package:flow/entity/category.dart';
import 'package:flow/entity/transaction.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/actions.dart';
import 'package:flow/objectbox/objectbox.g.dart';
import 'package:flow/utils/optional.dart';
import 'package:moment_dart/moment_dart.dart';

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

  final String? keyword;

  /// Base score is 10.0
  final double keywordScoreThreshold;

  final List<Category>? categories;
  final List<Account>? accounts;

  final bool sortDescending;
  final TransactionSortField sortBy;

  const TransactionFilter({
    this.range,
    this.keyword,
    this.categories,
    this.accounts,
    this.keywordScoreThreshold = 80.0,
    this.sortDescending = true,
    this.sortBy = TransactionSortField.transactionDate,
  });

  static const empty = TransactionFilter();

  List<TransactionPredicate> get predicates {
    final List<TransactionPredicate> predicates = [];

    if (range case TimeRange filterTimeRange) {
      predicates
          .add((Transaction t) => filterTimeRange.contains(t.transactionDate));
    }

    if (keyword case String filterKeyword) {
      predicates.add(
        (Transaction t) {
          final double score = t.titleSuggestionScore(
            query: filterKeyword,
            fuzzyPartial: false,
          );
          return score >= keywordScoreThreshold;
        },
      );
    }

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

    if (keyword case String filterKeyword) {
      conditions.add(
          Transaction_.title.contains(filterKeyword, caseSensitive: false));
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
    Optional<TimeRange>? range,
    Optional<String>? keyword,
    Optional<List<Category>>? cateogries,
    Optional<List<Account>>? accounts,
    double? keywordScoreThreshold,
  }) {
    return TransactionFilter(
      range: range == null ? this.range : range.value,
      keyword: keyword == null ? this.keyword : keyword.value,
      categories: cateogries == null ? categories : cateogries.value,
      accounts: accounts == null ? this.accounts : accounts.value,
      keywordScoreThreshold:
          keywordScoreThreshold ?? this.keywordScoreThreshold,
    );
  }
}
