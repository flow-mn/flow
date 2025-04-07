import "dart:convert";
import "dart:io";

void reformat(File file) {
  final String content = file.readAsStringSync();
  final Map<String, dynamic> jsonMap = jsonDecode(content);
  final List<String> keys = jsonMap.keys.toList();
  final List<String> sortedKeys = List.from(keys)..sort();
  final Map<String, dynamic> sortedJsonMap = {};
  for (String key in sortedKeys) {
    sortedJsonMap[key] = jsonMap[key];
  }

  file.writeAsStringSync(JsonEncoder.withIndent("  ").convert(sortedJsonMap));
}

void main() {
  final Directory directory = Directory("assets/l10n");

  if (!directory.existsSync()) {
    throw Exception("Directory does not exist");
  }

  directory
      .listSync()
      .where((entry) => entry is File && entry.path.endsWith(".json"))
      .cast<File>()
      .forEach(reformat);
}
