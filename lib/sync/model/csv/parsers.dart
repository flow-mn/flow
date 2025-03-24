import "package:flow/l10n/named_enum.dart";
import "package:logging/logging.dart";

final Logger _log = Logger("CSVCellParser");

/// Used to report current status to user
enum CSVCellParserError implements LocalizedEnum {
  invalidDate,
  invalidAmount,
  invalid;

  @override
  String get localizationEnumValue => name;
  @override
  String get localizationEnumName => "CSVCellParserError";
}

enum CSVParserColumn {
  title,
  notes,
  account,
  amount,
  transactionDate,
  transactionTime,
  transactionDateIso8601,
  category,
}

/// https://docs.google.com/spreadsheets/d/1wxdJ1T8PSvzayxvGs7bVyqQ9Zu0DPQ1YwiBLy1FluqE/edit?usp=sharing
abstract class CSVCellParser<T> {
  T parse(String cell, {int? row});

  CSVParserColumn get column;
}

class StringParser implements CSVCellParser<String> {
  @override
  final CSVParserColumn column;

  const StringParser(this.column);

  @override
  String parse(String cell, {int? row}) {
    return cell.trim();
  }
}

class DateParser implements CSVCellParser<DateTime> {
  /// Test -> https://regex101.com/r/XaDJOw/2
  static final RegExp dateRegex = RegExp(
    r"^\s*(?<y>(1|2)\d{3})[./-](?<m>(0?\d)|10|11|12)[./-](?<d>[0,1,2,3]?\d)\s*$",
  );

  @override
  final CSVParserColumn column;

  const DateParser(this.column);

  @override
  DateTime parse(String cell, {int? row}) {
    try {
      final RegExpMatch match = dateRegex.allMatches(cell).single;

      final int y = int.parse(match.namedGroup("y") ?? "~");
      final int m = int.parse(match.namedGroup("m") ?? "~");
      final int d = int.parse(match.namedGroup("d") ?? "~");

      if (m < 1 || m > 12) throw "bad month part";
      if (d < 1 || d > 31) throw "bad day part";

      return DateTime(y, m, d);
    } catch (e) {
      _log.severe("Cannot parse regular date on row $row - $cell");
      throw CSVCellParserError.invalidDate;
    }
  }
}

class TimeParser implements CSVCellParser<(int, int, int?)> {
  /// Test -> https://regex101.com/r/qqG35K/3
  static final RegExp timeRegex = RegExp(
    r"^\s*(?<h>\d?\d)(:|\.)(?<m>\d?\d)((:|\.)(?<s>\d?\d))?\s*(?<meridiem>(a\.?m|p\.?m).?)?\s*$",
  );

  @override
  final CSVParserColumn column;

  const TimeParser(this.column);

  @override
  (int, int, int?) parse(String cell, {int? row}) {
    try {
      final RegExpMatch match = timeRegex.allMatches(cell).single;

      final int rawH = int.parse(match.namedGroup("h") ?? "~");
      final int m = int.parse(match.namedGroup("m") ?? "~");
      final int? s = int.tryParse(match.namedGroup("s") ?? "~");

      if (rawH < 0) throw "bad hour part";

      final bool? isPM = match
          .namedGroup("meridiem")
          ?.toLowerCase()
          .contains("p");

      final int h = rawH + (isPM == true ? 12 : 0);

      if (m < 0 || m > 59) throw "bad minute part";
      if (s != null && (s < 0 || s > 59)) throw "bad second part";

      return (h, m, s);
    } catch (e) {
      _log.severe("Cannot parse regular time on row $row - $cell");
      throw CSVCellParserError.invalidDate;
    }
  }
}

class AmountParser implements CSVCellParser<double> {
  @override
  final CSVParserColumn column;

  const AmountParser(this.column);

  @override
  double parse(String cell, {int? row}) {
    try {
      final String normalized = cell.trim().replaceAll(r"[^\d.e+-]", "");
      return double.parse(normalized);
    } catch (e) {
      _log.severe("Cannot parse amount on row $row - $cell");
      throw CSVCellParserError.invalidAmount;
    }
  }
}

class ISO8601DateParser implements CSVCellParser<DateTime> {
  @override
  final CSVParserColumn column;

  const ISO8601DateParser(this.column);

  @override
  DateTime parse(String cell, {int? row}) {
    try {
      return DateTime.parse(cell);
    } catch (e) {
      _log.severe("Cannot parse iso8601 date on row $row - $cell");
      throw CSVCellParserError.invalidDate;
    }
  }
}
