String? looseString(dynamic value) {
  if (value is Iterable) {
    return looseString(value.firstOrNull);
  }

  if (value is num) {
    return value.toString();
  }

  if (value is String) {
    return value;
  }

  return null;
}

/// Returns `null` for non-finite values (NaN, Infinity)
double? looseDouble(dynamic value) {
  final double? parsed = switch (value) {
    num number => number.toDouble(),
    _ => double.tryParse(looseString(value) ?? ""),
  };

  return parsed?.isFinite == true ? parsed : null;
}

List<String>? looseStringList(dynamic value) {
  if (value is Iterable) {
    return value.whereType<String>().where((x) => x.isNotEmpty).toList();
  }

  if (value is String) {
    return [value];
  }

  return null;
}
