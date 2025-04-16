import "package:flow/entity/transaction.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/utils/optional.dart";
import "package:json_annotation/json_annotation.dart";

part "search_data.g.dart";

@JsonEnum(valueField: "value")
enum TransactionSearchMode implements LocalizedEnum {
  /// Fuzzy matching, allows for little error
  smart("smart"),

  /// Text must contain the keyword, no room for error
  substring("substring"),

  /// Text must be exactly the keyword
  exact("exact"),

  /// Text must be empty string or null
  none("none");

  final String value;

  const TransactionSearchMode(this.value);

  @override
  String get localizationEnumValue => value;
  @override
  String get localizationEnumName => "TransactionSearchMode";
}

/// Fuzzy finding is case insensitive regardless of [caseInsensitive]
@JsonSerializable(explicitToJson: true)
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

    return trimmed.toLowerCase();
  }

  final TransactionSearchMode mode;

  final bool includeDescription;

  /// Base score is [10.0]
  ///
  /// Defaults to [80.0]
  ///
  /// Exact match is [110.0]
  final double smartMatchThreshold;

  const TransactionSearchData({
    this.keyword,
    this.mode = TransactionSearchMode.smart,
    this.smartMatchThreshold = 80.0,
    this.includeDescription = true,
  });

  bool predicate(Transaction t) {
    if (includeDescription &&
        normalizedKeyword != null &&
        t.description?.toLowerCase().contains(normalizedKeyword!) == true) {
      return true;
    }

    return switch (mode) {
      TransactionSearchMode.smart => _smartMatching(t),
      TransactionSearchMode.substring => _substringMatching(t),
      TransactionSearchMode.exact => _exactMatching(t),
      TransactionSearchMode.none => _emptyMatching(t),
    };
  }

  /// Filter is not available when smart match isn't enabled
  Condition<Transaction>? get filter {
    if (normalizedKeyword == null) {
      return null;
    }

    if (!includeDescription) {
      return _titleFilter;
    }

    final Condition<Transaction> descriptionFilter = Transaction_.description
        .contains(normalizedKeyword!, caseSensitive: false);

    if (_titleFilter != null) {
      return _titleFilter!.or(descriptionFilter);
    }

    return Transaction_.title.notNull().or(descriptionFilter);
  }

  Condition<Transaction>? get _titleFilter {
    if (mode == TransactionSearchMode.none) {
      return Transaction_.title.isNull() | Transaction_.title.equals("");
    }

    if (mode == TransactionSearchMode.smart) {
      return null;
    }

    if (mode == TransactionSearchMode.exact) {
      return Transaction_.title.equals(
        normalizedKeyword!,
        caseSensitive: false,
      );
    }

    return Transaction_.title.contains(
      normalizedKeyword!,
      caseSensitive: false,
    );
  }

  TransactionSearchData copyWithOptional({
    Optional<String>? keyword,
    TransactionSearchMode? mode,
    bool? includeDescription,
    double? smartMatchThreshold,
  }) {
    return TransactionSearchData(
      keyword: keyword == null ? this.keyword : keyword.value,
      mode: mode ?? this.mode,
      includeDescription: includeDescription ?? this.includeDescription,
      smartMatchThreshold: smartMatchThreshold ?? this.smartMatchThreshold,
    );
  }

  @override
  int get hashCode =>
      Object.hashAll([keyword, mode, includeDescription, smartMatchThreshold]);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! TransactionSearchData) {
      return false;
    }

    return keyword == other.keyword &&
        mode == other.mode &&
        includeDescription == other.includeDescription &&
        smartMatchThreshold == other.smartMatchThreshold;
  }

  bool _smartMatching(Transaction t) {
    if (normalizedKeyword == null) return true;

    final double score = t.titleSuggestionScore(
      query: normalizedKeyword,
      fuzzyPartial: true,
    );

    return score >= smartMatchThreshold;
  }

  bool _substringMatching(Transaction t) {
    if (normalizedKeyword == null) return true;

    final String? normalizedTitle = t.title?.trim().toLowerCase();

    if (normalizedTitle == null) return false;

    return normalizedTitle.contains(normalizedKeyword!);
  }

  bool _exactMatching(Transaction t) {
    if (normalizedKeyword == null) return true;

    final String? normalizedTitle = t.title?.trim().toLowerCase();

    if (normalizedTitle == null) return false;

    return normalizedTitle == normalizedKeyword!;
  }

  bool _emptyMatching(Transaction t) {
    return t.title == null || t.title!.isEmpty;
  }

  factory TransactionSearchData.fromJson(Map<String, dynamic> json) =>
      _$TransactionSearchDataFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionSearchDataToJson(this);
}
