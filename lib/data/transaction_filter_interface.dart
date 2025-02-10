import "package:flow/data/transactions_filter/group_range.dart";
import "package:flow/data/transactions_filter/search_data.dart";
import "package:flow/data/transactions_filter/sort_field.dart";
import "package:flow/data/transactions_filter/time_range.dart";
import "package:flow/entity/transaction.dart";
import "package:objectbox/objectbox.dart";

typedef TransactionPredicate = bool Function(Transaction);

abstract class TransactionFilterInterface {
  TransactionFilterTimeRange? get range;

  List<String>? get uuids;

  TransactionSearchData get searchData;

  List<TransactionType>? get types;

  List<String>? get categories;
  List<String>? get accounts;

  bool get sortDescending;
  TransactionSortField get sortBy;

  TransactionGroupRange get groupBy;

  bool? get isPending;

  double? get minAmount;
  double? get maxAmount;

  List<String>? get currencies;

  /// Defaults to false
  bool? get includeDeleted;

  List<TransactionPredicate> get postPredicates;
  List<TransactionPredicate> get predicates;

  QueryBuilder<Transaction> queryBuilder({bool ignoreKeywordFilter = true});
}
