import "package:flow/data/multi_filter.dart";
import "package:flutter/foundation.dart";
import "package:json_annotation/json_annotation.dart";

part "string_multi_filter.g.dart";

@JsonSerializable(explicitToJson: true)
class StringMultiFilter extends MultiFilter<String> {
  static bool _stringComparer(String a, String b) => a == b;

  const StringMultiFilter({required super.whitelist, required super.items})
    : super(comparer: _stringComparer);
  const StringMultiFilter.keepNothing() : super.keepNothing();
  const StringMultiFilter.keepEverything() : super.keepEverything();
  const StringMultiFilter.whitelist(super.items)
    : super.whitelist(comparer: _stringComparer);
  const StringMultiFilter.blacklist(super.items)
    : super.blacklist(comparer: _stringComparer);

  factory StringMultiFilter.fromJson(Map<String, dynamic> json) =>
      _$StringMultiFilterFromJson(json);
  Map<String, dynamic> toJson() => _$StringMultiFilterToJson(this);

  static StringMultiFilter? fromJsonOrList(dynamic json) {
    if (json == null) return null;

    if (json is Iterable) {
      return StringMultiFilter.whitelist(json.map((e) => e as String).toList());
    }

    return StringMultiFilter.fromJson(json as Map<String, dynamic>);
  }

  @override
  int get hashCode => Object.hash(whitelist, items.toSet());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other case StringMultiFilter stringMultiFilter) {
      return stringMultiFilter.whitelist == whitelist &&
          setEquals(stringMultiFilter.items.toSet(), items.toSet());
    }

    if (other case MultiFilter<String> stringMultiFilter) {
      return stringMultiFilter.whitelist == whitelist &&
          setEquals(stringMultiFilter.items.toSet(), items.toSet());
    }

    return false;
  }
}
