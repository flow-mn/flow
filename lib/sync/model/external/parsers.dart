import "package:uuid/uuid.dart";

String? parseOptionalString(dynamic x) {
  if (x is! String) return null;

  final String trimmed = x.trim();

  if (trimmed.isNotEmpty) {
    return trimmed;
  }

  return null;
}

String parseRequiredString(dynamic x) {
  if (x is! String) {
    throw Exception("Expected a string");
  }

  final String trimmed = x.trim();

  if (trimmed.isEmpty) {
    throw Exception("Expected a non-empty string");
  }

  return trimmed;
}

String parseUuid(dynamic x) {
  if (x is! String) {
    throw Exception("Expected a string");
  }

  x = x.trim();

  if (!Uuid.isValidUUID(fromString: x)) {
    throw Exception("Expected a valid UUID");
  }

  return x;
}
