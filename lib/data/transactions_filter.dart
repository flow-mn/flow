import 'package:flow/entity/account.dart';
import 'package:flow/entity/category.dart';
import 'package:flow/entity/transaction.dart';
import 'package:flow/objectbox/actions.dart';
import 'package:flow/utils/optional.dart';
import 'package:moment_dart/moment_dart.dart';

typedef TransactionPredicate = bool Function(Transaction);

/// For all fields, disabled if it's null.
///
/// All values must be wrapped by [Optional]
class TransactionFilter {
  final TimeRange? range;
  final String? keyword;

  /// Base score is 10.0
  final double keywordScoreThreshold;
  final List<Category>? cateogries;
  final List<Account>? accounts;

  const TransactionFilter({
    this.range,
    this.keyword,
    this.cateogries,
    this.accounts,
    this.keywordScoreThreshold = 80.0,
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

    if (cateogries?.isNotEmpty == true) {
      predicates.add(
        (Transaction t) => cateogries!.any(
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
      cateogries: cateogries == null ? this.cateogries : cateogries.value,
      accounts: accounts == null ? this.accounts : accounts.value,
      keywordScoreThreshold:
          keywordScoreThreshold ?? this.keywordScoreThreshold,
    );
  }
}
