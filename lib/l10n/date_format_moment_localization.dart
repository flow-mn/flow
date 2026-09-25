import "package:flow/data/prefs/date_format_preset.dart";
import "package:moment_dart/moment_dart.dart";
// ignore: implementation_imports
import "package:moment_dart/src/localizations/mixins/simple_range.dart";

/// Delegates to [inner], except for localized date formats (l, LL, lll...)
class DateFormatMomentLocalization extends MomentLocalization with SimpleRange {
  final MomentLocalization inner;
  final DateFormatPreset preset;

  DateFormatMomentLocalization(this.inner, this.preset)
    : assert(preset.pattern != null && preset.longPattern != null);

  late final Map<FormatterToken, FormatterTokenFn?> _innerFormatters =
      inner.formatters;

  @override
  late final Map<FormatterToken, FormatterTokenFn?> formatters = {
    ..._innerFormatters,
    FormatterToken.l: _short,
    FormatterToken.L: _short,
    FormatterToken.ll: _short,
    FormatterToken.LL: _long,
    FormatterToken.lll: (dateTime) => "${_short(dateTime)} ${_time(dateTime)}",
    FormatterToken.LLL: (dateTime) => "${_long(dateTime)} ${_time(dateTime)}",
    FormatterToken.llll: (dateTime) =>
        "${reformat(dateTime, "ddd")}, ${_short(dateTime)} ${_time(dateTime)}",
    FormatterToken.LLLL: (dateTime) =>
        "${reformat(dateTime, "dddd")}, ${_long(dateTime)} ${_time(dateTime)}",
  };

  String _short(DateTime dateTime) => reformat(dateTime, preset.pattern!);
  String _long(DateTime dateTime) => reformat(dateTime, preset.longPattern!);
  String _time(DateTime dateTime) =>
      _innerFormatters[FormatterToken.LT]?.call(dateTime) ??
      reformat(dateTime, "HH:mm");

  @override
  Map<FormatterToken, FormatterTokenFn?> overrideFormatters() => formatters;

  @override
  SimpleRangeData get simpleRangeData => (inner as SimpleRange).simpleRangeData;

  @override
  String range(TimeRange range, {DateTime? anchor, bool useRelative = true}) {
    if (inner is! SimpleRange) {
      return inner.range(range, anchor: anchor, useRelative: useRelative);
    }

    return super.range(range, anchor: anchor, useRelative: useRelative);
  }

  @override
  String relative(
    Duration duration, {
    bool dropPrefixOrSuffix = false,
    Abbreviation form = Abbreviation.none,
  }) => inner.relative(
    duration,
    dropPrefixOrSuffix: dropPrefixOrSuffix,
    form: form,
  );

  @override
  String duration(
    Duration duration, {
    bool round = true,
    bool omitZeros = true,
    bool includeWeeks = false,
    Abbreviation form = Abbreviation.none,
    String? delimiter,
    DurationFormat format = DurationFormat.auto,
    bool dropPrefixOrSuffix = false,
  }) => inner.duration(
    duration,
    round: round,
    omitZeros: omitZeros,
    includeWeeks: includeWeeks,
    form: form,
    delimiter: delimiter,
    format: format,
    dropPrefixOrSuffix: dropPrefixOrSuffix,
  );

  @override
  String calendarTime(Moment moment) => inner.calendarTime(moment);

  @override
  String calendar(
    Moment moment, {
    DateTime? reference,
    String? customFormat,
    bool omitHours = false,
    bool omitHoursIfDistant = true,
  }) => inner.calendar(
    moment,
    reference: reference,
    customFormat: customFormat,
    omitHours: omitHours,
    omitHoursIfDistant: omitHoursIfDistant,
  );

  @override
  CalendarLocalizationData? get calendarData => inner.calendarData;

  @override
  Map<int, String> get weekdayName => inner.weekdayName;

  @override
  String get languageCode => inner.languageCode;

  @override
  String? get countryCode => inner.countryCode;

  @override
  String get locale => inner.locale;

  @override
  String get endonym => inner.endonym;

  @override
  String get languageNameInEnglish => inner.languageNameInEnglish;

  @override
  int get weekStart => inner.weekStart;
}
