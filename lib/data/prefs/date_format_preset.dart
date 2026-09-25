import "package:flow/l10n/date_format_moment_localization.dart";
import "package:moment_dart/moment_dart.dart";

enum DateFormatPreset {
  system("system", null, null, null),
  iso("iso", "YYYY-MM-DD", "YYYY-MM-DD", "MM-DD"),
  dayMonthYearSlash("dmySlash", "DD/MM/YYYY", "DD/MM/YYYY", "D/M"),
  monthDayYearSlash("mdySlash", "MM/DD/YYYY", "MM/DD/YYYY", "M/D"),
  dayMonthYearDot("dmyDot", "DD.MM.YYYY", "DD.MM.YYYY", "D.M"),
  dayMonthNameYear("dMonY", "D MMM YYYY", "D MMMM YYYY", "D MMM");

  final String value;

  /// moment_dart patterns, null means follow the locale
  final String? pattern;
  final String? longPattern;
  final String? dayMonthPattern;

  const DateFormatPreset(
    this.value,
    this.pattern,
    this.longPattern,
    this.dayMonthPattern,
  );

  static DateFormatPreset? tryParse(String? value) {
    for (final DateFormatPreset preset in values) {
      if (preset.value == value) return preset;
    }

    return null;
  }

  /// Wraps [localization] so it formats dates with this preset
  MomentLocalization apply(MomentLocalization localization) {
    final MomentLocalization base = localization is DateFormatMomentLocalization
        ? localization.inner
        : localization;

    if (this == .system) return base;

    return DateFormatMomentLocalization(base, this);
  }
}
