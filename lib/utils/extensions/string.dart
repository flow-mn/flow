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
          (e) =>
              titleCaseLowercaseWords.contains(e.toLowerCase())
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
