import "dart:convert";
import "dart:io";

import "package:test/test.dart";
import "package:path/path.dart";

List<String> getKeys(File file) {
  final String content = file.readAsStringSync();
  final Map<String, dynamic> jsonMap = jsonDecode(content);
  return jsonMap.keys.toList();
}

const _pluralSuffixes = [".zero", ".one", ".two", ".few", ".many", ".other"];

bool _isPluralVariant(String key) {
  return _pluralSuffixes.any((suffix) => key.endsWith(suffix));
}

String _baseKey(String key) {
  for (final suffix in _pluralSuffixes) {
    if (key.endsWith(suffix)) {
      return key.substring(0, key.length - suffix.length);
    }
  }
  return key;
}

void main() {
  final Directory directory = Directory("assets/l10n");

  final File baseFile = File("assets/l10n/en.json");

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

  final List<String> baseKeys =
      keys.where((k) => !_isPluralVariant(k)).toList();
  final Set<String> baseKeySet = baseKeys.toSet();

  for (final entry in directory.listSync()) {
    if (entry is! File) continue;
    if (!entry.path.endsWith(".json")) continue;
    if (entry.path == baseFile.path) continue;

    final String name = basename(entry.path);

    test("File $name has all base keys in same order", () {
      final languageKeys = getKeys(entry);
      final languageBaseKeys =
          languageKeys.where((k) => !_isPluralVariant(k)).toList();

      expect(languageBaseKeys.length, baseKeys.length,
          reason: "Key count mismatch");
      for (int i = 0; i < baseKeys.length; i++) {
        expect(languageBaseKeys[i], baseKeys[i]);
      }
    });

    test("File $name plural keys have valid base keys and ordering", () {
      final languageKeys = getKeys(entry);

      for (int i = 0; i < languageKeys.length; i++) {
        final key = languageKeys[i];
        if (!_isPluralVariant(key)) continue;

        final base = _baseKey(key);
        expect(baseKeySet.contains(base), true,
            reason: "Plural key '$key' has no base key '$base' in en.json");

        final baseIndex = languageKeys.indexOf(base);
        expect(baseIndex, isNot(-1),
            reason: "Plural key '$key' missing base key '$base' in file");
        expect(baseIndex, lessThan(i),
            reason:
                "Plural key '$key' should come after its base key '$base'");
      }
    });
  }
}
