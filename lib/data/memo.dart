class Memoizer<K, V> {
  final V Function(K) compute;

  final Map<K, V> _cache = {};

  Memoizer({required this.compute});

  V get(K key) {
    if (!_cache.containsKey(key)) {
      _cache[key] = compute(key);
    }
    return _cache[key] = compute(key);
  }

  void remove(K key) {
    _cache.remove(key);
  }
}
