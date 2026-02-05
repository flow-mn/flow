String replaceEverythingExcept(
  String input,
  List<String> whitelist, [
  String replacement = "",
]) {
  if (whitelist.isEmpty) return input.replaceAll(RegExp(r"."), replacement);

  final patternString = whitelist.map((item) => RegExp.escape(item)).join("|");
  final pattern = RegExp(patternString);

  return input.splitMapJoin(
    pattern,
    onMatch: (m) => m[0]!, // Keep the whitelisted match exactly as it is
    onNonMatch: (n) => n.isEmpty ? "" : replacement, // Replace everything else
  );
}
