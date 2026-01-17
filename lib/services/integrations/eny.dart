import "dart:convert";

import "package:cross_file/cross_file.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/categories.dart";
import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;
import "package:logging/logging.dart";

final Logger _log = Logger("EnyService");

class EnyCredsError implements Exception {
  const EnyCredsError() : super();

  @override
  String toString() => "EnyError: Invalid credentials";
}

class EnyService {
  static EnyService? _instance;

  final ValueNotifier<String?> _apiKey = ValueNotifier<String?>(null);
  ValueListenable<String?> get apiKey => _apiKey;

  final ValueNotifier<int?> _remainingCredits = ValueNotifier<int?>(null);
  ValueListenable<int?> get remainingCredits => _remainingCredits;

  String? _email;
  String? get email => _email;

  factory EnyService() => _instance ??= EnyService._internal();

  EnyService._internal() {
    _init();
  }

  void _init() async {
    try {
      _apiKey.value = LocalPreferences().enyApiKey.get();
      _email = LocalPreferences().enyEmail.get();
      _log.fine(
        "Eny API key loaded, exists: ${_apiKey.value != null}, email: ${_email != null}",
      );
    } catch (e) {
      _log.warning("Failed to load Eny API key", e);
    }
  }

  Future<void> setApiKey({required String? apiKey, String? email}) async {
    try {
      await LocalPreferences().enyApiKey.set(apiKey ?? "");
      _apiKey.value = apiKey;
      _log.fine("Eny API key saved");
    } catch (e) {
      _log.warning("Failed to save Eny API key", e);
    }
    try {
      await LocalPreferences().enyEmail.set(email ?? "");
      _email = email;
      _log.fine("Eny email saved");
    } catch (e) {
      _log.warning("Failed to save Eny email", e);
    }
  }

  Future<int?> checkCredits() async {
    final String? xApiKey = _apiKey.value;

    if (xApiKey == null) {
      throw EnyCredsError();
    }

    try {
      final response = await fetchRemainingCredits(xApiKey);
      _remainingCredits.value = response;
      return response;
    } catch (e) {
      if (e is EnyCredsError) {
        rethrow;
      }
      _log.warning("Failed to check credits", e);
      return null;
    }
  }

  static Future<int?> fetchRemainingCredits(String xApiKey) async {
    final response = await http.get(
      Uri.parse("https://eny.gege.mn/api/v1/usage"),
      headers: {"X-API-KEY": xApiKey},
    );

    if (response.statusCode == 401) {
      throw EnyCredsError();
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map) return null;

    final remaining = decoded["remainingCredits"] as num?;

    return remaining?.toInt();
  }

  Future<String?> processReceipt(XFile file) async {
    final String? xApiKey = _apiKey.value;

    if (xApiKey == null) {
      throw EnyCredsError();
    }

    try {
      final Stream<Uint8List> stream = file.openRead();
      final int length = await file.length();

      final request = http.MultipartRequest(
        "post",
        Uri.parse("https://eny.gege.mn/api/v1/receipts"),
      );

      http.MediaType? contentType;

      try {
        if (file.mimeType case String mimeType) {
          contentType = http.MediaType.parse(mimeType);
        }
      } catch (e) {
        //
      }

      request.files.add(
        http.MultipartFile(
          "image",
          stream,
          length,
          filename: file.name,
          contentType: contentType,
        ),
      );
      request.fields["categories"] = await CategoriesService().getAll().then(
        (categories) => categories.take(32).map((x) => x.name).join(","),
      );
      request.headers["X-API-KEY"] = xApiKey;

      final response = await request.send().then(http.Response.fromStream);

      if (response.statusCode == 401) {
        throw EnyCredsError();
      }

      final decoded = jsonDecode(response.body);

      return decoded["id"];
    } catch (e, stackTrace) {
      if (e is EnyCredsError) {
        rethrow;
      }
      _log.severe("Failed to process receipt", e, stackTrace);
      return null;
    }
  }

  Future<bool> connect({required String apiKey, String? email}) async {
    try {
      final int? remainingCredits = await fetchRemainingCredits(apiKey);

      if (remainingCredits == null) {
        throw Exception("Failed to verify API key");
      }

      await setApiKey(apiKey: apiKey, email: email);
      _remainingCredits.value = remainingCredits;

      return true;
    } catch (e) {
      _log.warning("Failed to connect to Eny", e);
      return false;
    }
  }

  Future<void> disconnect() async {
    _apiKey.value = null;
    _email = null;
    _remainingCredits.value = null;
    await setApiKey(apiKey: null, email: null);
  }
}
