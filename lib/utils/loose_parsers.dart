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

double? looseDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }

  final stringValue = looseString(value);
  if (stringValue != null) {
    return double.tryParse(stringValue);
  }
  return null;
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
