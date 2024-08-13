import 'package:flow/entity/transaction.dart';
import 'package:flow/objectbox/actions.dart';
import 'package:flow/objectbox/objectbox.g.dart';
import 'package:flow/utils/optional.dart';

/// Fuzzy finding is case insensitive regardless of [caseInsensitive]
class TransactionSearchData {
  /// Recomend using normalizedKeyword.
  final String? keyword;

  /// [keyword] trimmed, and lowercased if [caseInsensitive] is [true]
  ///
  /// Returns null when [keyword] is null or empty
  String? get normalizedKeyword {
    final trimmed = keyword?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    if (caseInsensitive) {
      return trimmed.toLowerCase();
    }

    return trimmed;
  }

  /// When [true], uses fuzzy matching
  /// else, exact matching
  final bool smartMatch;

  /// Fuzzy finding is case insensitive regardless of this
  final bool caseInsensitive;

  /// Base score is [10.0]
  ///
  /// Defaults to [80.0]
  ///
  /// Exact match is [110.0]
  final double smartMatchThreshold;

  const TransactionSearchData({
    this.keyword,
    this.smartMatch = true,
    this.caseInsensitive = true,
    this.smartMatchThreshold = 80.0,
  });

  bool predicate(Transaction t) {
    if (!smartMatch) {
      return _stupidMatching(t);
    }

    if (normalizedKeyword == null) return true;

    final double score = t.titleSuggestionScore(
      query: normalizedKeyword,
      fuzzyPartial: false,
    );

    return score >= smartMatchThreshold;
  }

  bool _stupidMatching(Transaction t) {
    if (normalizedKeyword == null) return true;

    final String? normalizedTitle =
        caseInsensitive ? t.title?.trim().toLowerCase() : t.title?.trim();

    if (normalizedTitle == null) return false;

    return normalizedTitle.contains(
      normalizedKeyword!,
    );
  }

  /// Filter is not available when smart match isn't enabled
  Condition<Transaction>? get filter {
    if (smartMatch) {
      return null;
    }

    if (normalizedKeyword == null) {
      return null;
    }

    return Transaction_.title.contains(
      normalizedKeyword!,
      caseSensitive: !caseInsensitive,
    );
  }

  TransactionSearchData copyWithOptional({
    Optional<String>? keyword,
    bool? smartMatch,
    bool? caseInsensitive,
    double? smartMatchThreshold,
  }) {
    return TransactionSearchData(
      keyword: keyword == null ? this.keyword : keyword.value,
      smartMatch: smartMatch ?? this.smartMatch,
      caseInsensitive: caseInsensitive ?? this.caseInsensitive,
      smartMatchThreshold: smartMatchThreshold ?? this.smartMatchThreshold,
    );
  }

  @override
  int get hashCode => Object.hashAll(
      [keyword, smartMatch, caseInsensitive, smartMatchThreshold]);

  @override
  operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! TransactionSearchData) {
      return false;
    }

    return keyword == other.keyword &&
        smartMatch == other.smartMatch &&
        caseInsensitive == other.caseInsensitive &&
        smartMatchThreshold == other.smartMatchThreshold;
  }
}
