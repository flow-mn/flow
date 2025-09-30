// ignore_for_file: avoid_print

import "dart:convert";
import "dart:io";
import "dart:isolate";

import "package:openai_dart/openai_dart.dart";
import "package:path/path.dart";

Future<Map<String, dynamic>?> translate(
  String englishJson,
  String targetLanguage,
) async {
  final String? openaiApiKey = Platform.environment["OPENAI_API_KEY"];
  final OpenAIClient client = OpenAIClient(apiKey: openaiApiKey);

  final CreateChatCompletionResponse
  response = await client.createChatCompletion(
    request: CreateChatCompletionRequest(
      model: ChatCompletionModel.modelId("gpt-5"),
      responseFormat: ResponseFormat.text(type: ResponseFormatType.jsonObject),
      messages: [
        ChatCompletionMessage.developer(
          content: ChatCompletionDeveloperMessageContent.text(
            "You are a professional translator with expertise in user interface design. You will be provided a JSON localization file in english, and you should translate the file into a localization json in $targetLanguage language.",
          ),
        ),
        ChatCompletionMessage.user(
          content: ChatCompletionUserMessageContent.string(englishJson),
        ),
      ],
    ),
  );

  if (response.choices.first.message.content == null) {
    return null;
  }

  return jsonDecode(response.choices.first.message.content!);
}

final Map<String, String> filenameToTargetLanguageMapping = {
  "ar.json": "Arabic (generic)",
  "de_DE.json": "German (Germany)",
  "en.json": "English (generic)",
  "es_ES.json": "Spanish (Spain)",
  "fr_FR.json": "French (France)",
  "it_IT.json": "Italian (Italy)",
  "mn_MN.json": "Mongolian (Mongolia)",
  "ru_RU.json": "Russian (Russia)",
  "tr_TR.json": "Turkish (Turkey)",
  "uk_UA.json": "Ukrainian (Ukraine)",
};

Future<void> translateMissingKeys(
  File file,
  Map<String, dynamic> english,
) async {
  final Map<String, dynamic> contents = await File(
    file.path,
  ).readAsString().then((str) => jsonDecode(str) as Map<String, dynamic>);

  final List<String> missingKeys = [];

  for (final String key in english.keys) {
    if (contents.containsKey(key)) continue;

    missingKeys.add(key);
  }

  print(
    "Found ${missingKeys.length} missing keys in ${file.path}, translating...",
  );

  final String missingContentStr = jsonEncode(
    Map.fromEntries(
      english.entries.where((entry) => missingKeys.contains(entry.key)),
    ),
  ).toString();

  final String? targetLanguage =
      filenameToTargetLanguageMapping[basename(file.path)];

  if (targetLanguage == null) {
    print("Target language not found for ${file.path}");
    return;
  }

  final Map<String, dynamic>? translationToBeAdded = await translate(
    missingContentStr,
    targetLanguage,
  );

  if (translationToBeAdded == null) {
    print("Translation failed for ${file.path}");
    return;
  }

  // Add the missing translations to the original contents
  for (final MapEntry<String, dynamic> entry in translationToBeAdded.entries) {
    contents[entry.key] = entry.value;
  }

  // Write the updated contents back to the file
  await File(file.path).writeAsString(jsonEncode(contents));
}

Future<void> main() async {
  final Directory directory = Directory("assets/l10n");

  if (!directory.existsSync()) {
    throw Exception("Directory does not exist");
  }

  final Map<String, dynamic> english = await File(
    "assets/l10n/en.json",
  ).readAsString().then((str) => jsonDecode(str) as Map<String, dynamic>);

  print("Found ${english.length} keys in English");

  final List<File> files = directory
      .listSync()
      .where((file) => file.path.endsWith(".json"))
      .whereType<File>()
      .toList();

  await Future.wait(
    files.map((file) => Isolate.run(() => translateMissingKeys(file, english))),
  );

  print("Completed translations.");
  exit(0);
}
