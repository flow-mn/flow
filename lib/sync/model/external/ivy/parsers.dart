import "package:moment_dart/moment_dart.dart";
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

DateTime? parseOptionalDate(dynamic x) {
  try {
    return parseDate(x);
  } catch (e) {
    return null;
  }
}

DateTime parseDate(dynamic x) {
  if (x is DateTime) {
    return x;
  }

  if (x is! String) {
    throw Exception("Expected a string");
  }

  x = x.trim();

  if (x.isEmpty) {
    throw Exception("Expected a non-empty string");
  }

  try {
    return Moment.parse(x);
  } catch (e) {
    // Silent fail
  }

  try {
    final RegExpMatch? match =
        RegExp(
          r"(?<day>[0123]?\d)[\/-](?<month>[01]?\d)[\/-](?<year>\d\d\d\d)\s+(?<hour>[012]?\d)[:-](?<minute>[012345]?\d)[^\d]*",
        ).firstMatch(x) ??
        RegExp(
          r"(?<year>\d\d\d\d)[\/-](?<month>\d?\d)[\/-](?<day>[0123]+)[\sT]+(?<hour>\d+)[:-](?<minute>\d+)[:-](?<second>\d+)",
        ).firstMatch(x);

    if (match == null) {
      throw Exception("Failed to parse date");
    }

    return DateTime(
      int.parse(match.namedGroup("year")!),
      int.parse(match.namedGroup("month")!),
      int.parse(match.namedGroup("day")!),
      int.parse(match.namedGroup("hour") ?? "0"),
      int.parse(match.namedGroup("minute") ?? "0"),
      int.parse(match.namedGroup("second") ?? "0"),
    );
  } catch (e) {
    throw Exception("Failed to parse date ($x): $e");
  }
}
