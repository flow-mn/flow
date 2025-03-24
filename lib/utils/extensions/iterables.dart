extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
    <K, List<E>>{},
    (Map<K, List<E>> map, E element) =>
        map..putIfAbsent(keyFunction(element), () => <E>[]).add(element),
  );

  /// Creates map from [Iterable] by unique id. Will throw [StateError] if
  /// duplicate key is found.
  Map<K, E> mapBy<K>(K Function(E) keyFunction) =>
      fold(<K, E>{}, (Map<K, E> map, E element) {
        final K key = keyFunction(element);

        if (map[key] != null) {
          throw StateError("Duplicate key found: $key");
        }

        map[key] = element;

        return map;
      });

  E? firstWhereOrNull(bool Function(E element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  /// Returns a list with items alternating from [this] and [other].
  ///
  /// Both iterables must have the same length.
  ///
  /// Example:
  /// ```dart
  /// List<Object> list1 = [1, 2, 3];
  /// List<Object> list2 = ['a', 'b', 'c'];
  /// list1.alternate(list2); // [1, 'a', 2, 'b', 3, 'c']
  /// ```
  List<E> alternate(Iterable<E> other) {
    if (length != other.length) {
      throw ArgumentError("Both iterables must have the same length");
    }

    List<E> result = [];

    for (int i = 0; i < length; i++) {
      result.add(elementAt(i));
      result.add(other.elementAt(i));
    }

    return result;
  }
}
