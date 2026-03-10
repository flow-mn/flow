import "package:flow/entity/_base.dart";
import "package:flutter/foundation.dart";
import "package:json_annotation/json_annotation.dart";

typedef Comparer<T> = bool Function(T a, T b);

/// Used to filter items based on a whitelist or blacklist of items.
///
/// Only [MultiFilter<String>] can be serialized
class MultiFilter<T> {
  final bool whitelist;

  final List<T> items;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final Comparer<T>? comparer;

  const MultiFilter({
    required this.whitelist,
    required this.items,
    this.comparer,
  });
  const MultiFilter.keepNothing()
    : items = const [],
      whitelist = true,
      comparer = _alwaysFalse;
  const MultiFilter.keepEverything()
    : items = const [],
      whitelist = false,
      comparer = _alwaysFalse;
  const MultiFilter.whitelist(this.items, {this.comparer}) : whitelist = true;
  const MultiFilter.blacklist(this.items, {this.comparer}) : whitelist = false;

  static bool _alwaysFalse(dynamic a, dynamic b) => false;
  static bool flowDefaultComparer(dynamic a, dynamic b) {
    if (a is EntityBase && b is EntityBase) {
      return a.uuid == b.uuid;
    }

    if (a is List && b is List) {
      return listEquals(a, b);
    }

    if (a is Set && b is Set) {
      return setEquals(a, b);
    }

    if (a is Map && b is Map) {
      return mapEquals(a, b);
    }

    return a == b;
  }

  /// Always outputs the items to keep.
  List<T> filter(Iterable<T> input) {
    final Comparer<T> comparer = this.comparer ?? flowDefaultComparer;
    return input.where((element) {
      final bool contains = items.any((item) => comparer(item, element));
      return whitelist ? contains : !contains;
    }).toList();
  }

  List<K> mappedFilter<K>(Iterable<K> input, T Function(K) mapper) {
    final Comparer<T> comparer = this.comparer ?? flowDefaultComparer;
    return input.where((element) {
      final T mapped = mapper(element);
      final bool contains = items.any((item) => comparer(item, mapped));
      return whitelist ? contains : !contains;
    }).toList();
  }

  bool contains(T item) {
    final Comparer<T> comparer = this.comparer ?? flowDefaultComparer;
    final bool contains = items.any((i) => comparer(i, item));
    return whitelist ? contains : !contains;
  }
}
