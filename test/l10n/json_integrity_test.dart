import "dart:convert";
import "dart:io";

import "package:test/test.dart";
import "package:path/path.dart";

List<String> getKeys(File file) {
  final String content = file.readAsStringSync();
  final Map<String, dynamic> jsonMap = jsonDecode(content);
  return jsonMap.keys.toList();
}

void main() {
  final Directory directory = Directory("assets/l10n");

  final File baseFile = File("assets/l10n/en_US.json");

  test("Directory exists", () {
    expect(directory.existsSync(), true);
  });

  test("Base file exists", () {
    expect(baseFile.existsSync(), true);
  });

  final List<String> keys = getKeys(baseFile);

  test("No duplicate keys in base file", () {
    final Set<String> uniqueKeys = keys.toSet();
    expect(uniqueKeys.length, keys.length);
  });

  for (final entry in directory.listSync()) {
    if (entry is! File) continue;
    if (!entry.path.endsWith(".json")) continue;
    if (entry.path == baseFile.path) continue;

    test("File ${basename(entry.path)} has all keys in same order", () {
      final languageKeys = getKeys(entry);

      for (int i = 0; i < keys.length; i++) {
        expect(languageKeys[i], keys[i]);
      }
    });
  }
}
