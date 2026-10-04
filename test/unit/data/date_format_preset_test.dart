import "package:flow/data/prefs/date_format_preset.dart";
import "package:flutter_test/flutter_test.dart";
import "package:moment_dart/moment_dart.dart";

void main() {
  final DateTime date = DateTime(2026, 9, 5, 14, 30);

  String format(DateFormatPreset preset, String payload) => Moment(
    date,
    localization: preset.apply(MomentLocalizations.enUS()),
  ).format(payload);

  test("presets format short dates", () {
    expect(format(.system, "l"), "9/5/2026");
    expect(format(.iso, "l"), "2026-09-05");
    expect(format(.dayMonthYearSlash, "l"), "05/09/2026");
    expect(format(.monthDayYearSlash, "L"), "09/05/2026");
    expect(format(.dayMonthYearDot, "ll"), "05.09.2026");
    expect(format(.dayMonthNameYear, "ll"), "5 Sep 2026");
    expect(format(.dayMonthNameYear, "LL"), "5 September 2026");
  });

  test("presets keep the locale's time format", () {
    expect(format(.iso, "lll"), "2026-09-05 2:30 PM");
    expect(format(.dayMonthYearDot, "llll"), "Sat, 05.09.2026 2:30 PM");
    expect(format(.iso, "LT"), "2:30 PM");
  });

  test("calendar falls back to the preset for distant dates", () {
    final Moment moment = Moment(
      date,
      localization: DateFormatPreset.iso.apply(MomentLocalizations.enUS()),
    );

    expect(
      moment.calendar(reference: DateTime(2026, 10, 20), omitHours: true),
      "2026-09-05",
    );
    expect(moment.calendar(reference: DateTime(2026, 9, 6)), startsWith("Y"));
  });

  test("custom ranges use the preset", () {
    final MomentLocalization localization = DateFormatPreset.dayMonthYearSlash
        .apply(MomentLocalizations.enUS());

    expect(
      CustomTimeRange(
        DateTime(2026, 1, 1),
        DateTime(2026, 2, 1),
      ).format(localization: localization, anchor: DateTime(2026, 9, 25)),
      "01/01/2026 - 01/02/2026",
    );
  });

  test("apply does not stack wrappers", () {
    final MomentLocalization wrapped = DateFormatPreset.iso.apply(
      MomentLocalizations.enUS(),
    );

    expect(DateFormatPreset.system.apply(wrapped).locale, "en_US");
    expect(DateFormatPreset.system.apply(wrapped), isNot(same(wrapped)));
  });

  test("tryParse maps stored values", () {
    expect(
      DateFormatPreset.tryParse("dmySlash"),
      DateFormatPreset.dayMonthYearSlash,
    );
    expect(DateFormatPreset.tryParse("nope"), isNull);
    expect(DateFormatPreset.tryParse(null), isNull);
  });
}
