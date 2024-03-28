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
        .map((e) => titleCaseLowercaseWords.contains(e.toLowerCase())
            ? e.toLowerCase()
            : e.capitalize())
        .join(" ");
  }
}
