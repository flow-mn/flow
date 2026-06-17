import "dart:convert";

import "package:drift/drift.dart";

/// Stores a [DateTime] as ISO-8601 **UTC** text (always `…Z`), regardless of
/// whether the value handed in is UTC or local.
///
/// Drift's built-in text-date storage only emits UTC when `DateTime.isUtc`, but
/// Flow builds dates from local `DateTime.now()`. Without this, on-disk text
/// would carry a local offset and diverge from PowerSync's UTC strings — which
/// breaks the string-based date-range queries SQLite/PowerSync run on text
/// dates, and the JSON export format ([UTCDateTimeConverter]).
class UtcDateTimeConverter extends TypeConverter<DateTime, String> {
  const UtcDateTimeConverter();

  @override
  DateTime fromSql(String fromDb) => DateTime.parse(fromDb).toUtc();

  @override
  String toSql(DateTime value) => value.toUtc().toIso8601String();
}

/// Stores a `List<String>` as a JSON array text column (e.g. a transaction's
/// `extra_tags`). Empty/blank text decodes to an empty list.
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return const [];
    final List<dynamic> decoded = jsonDecode(fromDb) as List<dynamic>;
    return decoded.cast<String>();
  }

  @override
  String toSql(List<String> value) => jsonEncode(value);
}
