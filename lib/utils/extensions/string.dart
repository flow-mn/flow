import "package:flow/data/flow_icon.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:path/path.dart" as path;

extension Casings on String {
  static RegExp whitespaceMatcher = RegExp(r"\s");

  static List<String> titleCaseLowercaseWords = [
    "a",
    "an",
    "the",
    "at",
    "by",
    "for",
    "in",
    "of",
    "on",
    "to",
    "up",
    "and",
    "as",
    "but",
    "or",
    "nor",
  ];

  String capitalize() {
    if (isEmpty) return this;

    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  /// Does not preserve original whitespace characters.
  ///
  /// All whitespace will be replaced with a single space.
  String titleCase() {
    if (isEmpty) return this;

    return split(whitespaceMatcher)
        .map(
          (e) => titleCaseLowercaseWords.contains(e.toLowerCase())
              ? e.toLowerCase()
              : e.capitalize(),
        )
        .join(" ");
  }

  String get digitsObscured => replaceAll(RegExp(r"\d"), "*");

  /// Removes leading zeroes from a string.
  ///
  /// e.g.,
  /// 0a -> a
  /// 02 -> 2
  /// 03xe -> 3xe
  String get withoutLeadingZeroes => replaceAll(RegExp(r"^0*"), "");
}

extension StringUtils on String {
  FlowIconData get backupExtensionIcon => switch (path.extension(this)) {
    ".zip" || "zip" => FlowIconData.icon(Symbols.hard_drive_rounded),
    ".json" || "json" => FlowIconData.icon(Symbols.hard_drive_rounded),
    ".csv" || "csv" => FlowIconData.icon(Symbols.table_rounded),
    _ => FlowIconData.icon(Symbols.error_rounded),
  };
}
