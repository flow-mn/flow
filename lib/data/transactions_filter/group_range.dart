import "package:flow/entity/transaction.dart";
import "package:flow/l10n/named_enum.dart";
import "package:json_annotation/json_annotation.dart";
import "package:moment_dart/moment_dart.dart";

@JsonEnum(valueField: "value")
enum TransactionGroupRange implements LocalizedEnum {
  hour("hour"),

  /// Default
  day("day"),
  week("week"),
  month("month"),
  year("year"),
  allTime("allTime");

  final String value;

  const TransactionGroupRange(this.value);

  @override
  String get localizationEnumName => "TransactionGroupRange";

  @override
  String get localizationEnumValue => name;

  TimeRange fromTransaction(Transaction t) => switch (this) {
        TransactionGroupRange.hour =>
          HourTimeRange.fromDateTime(t.transactionDate),
        TransactionGroupRange.day =>
          DayTimeRange.fromDateTime(t.transactionDate),
        TransactionGroupRange.week => LocalWeekTimeRange(t.transactionDate),
        TransactionGroupRange.month =>
          MonthTimeRange.fromDateTime(t.transactionDate),
        TransactionGroupRange.year =>
          YearTimeRange.fromDateTime(t.transactionDate),
        TransactionGroupRange.allTime => TimeRange.allTime(),
      };
}
