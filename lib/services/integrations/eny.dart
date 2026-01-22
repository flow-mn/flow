import "dart:async";
import "dart:convert";

import "package:cross_file/cross_file.dart";
import "package:flow/data/transaction_multi_programmable_object.dart";
import "package:flow/data/transaction_programmable_object.dart";
import "package:flow/entity/transaction/extensions/default/eny_receipt.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs/eny_preferences.dart";
import "package:flow/services/categories.dart";
import "package:flow/services/user_preferences.dart";
import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;
import "package:logging/logging.dart";
import "package:uuid/uuid.dart";

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

  final Map<String, dynamic> _sessionCache = {};

  int _currentConcurrentRequests = 0;
  static const int _maxConcurrentRequests = 3;

  String? _email;
  String? get email => _email;

  factory EnyService() => _instance ??= EnyService._internal();

  EnyService._internal() {
    _init();
  }

  void _init() async {
    try {
      _apiKey.value = EnyLocalPreferences().apiKey.get();
      _email = EnyLocalPreferences().email.get();
      _log.fine(
        "Eny API key loaded, exists: ${_apiKey.value != null}, email: ${_email != null}",
      );
    } catch (e) {
      _log.warning("Failed to load Eny API key", e);
    }
    unawaited(resolveProcessedReceipt());
  }

  Future<void> setApiKey({required String? apiKey, String? email}) async {
    try {
      await EnyLocalPreferences().apiKey.set(apiKey ?? "");
      _apiKey.value = apiKey;
      _log.fine("Eny API key saved");
    } catch (e) {
      _log.warning("Failed to save Eny API key", e);
    }
    try {
      await EnyLocalPreferences().email.set(email ?? "");
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

  Future<Map?> fetchReceiptDetails(String receiptId) async {
    final response = await http.get(
      Uri.parse("https://eny.gege.mn/api/v1/receipts/$receiptId"),
      headers: {"X-API-KEY": _apiKey.value!},
    );

    if (response.statusCode == 401) {
      throw EnyCredsError();
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map) return null;

    return decoded;
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
        Uri.parse("https://eny.gege.mn/api/v1/receipts?async"),
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
      request.fields["categories"] = await CategoriesService()
          .getAllWithFrecencySort()
          .then(
            (categories) => categories.take(32).map((x) => x.name).join("\t"),
          );
      request.headers["X-API-KEY"] = xApiKey;
      request.headers["X-Client-Name"] = "Flow";

      final response = await request.send().then(http.Response.fromStream);

      if (response.statusCode == 401) {
        throw EnyCredsError();
      }

      final decoded = jsonDecode(response.body);

      if (decoded case Map decodedResult) {
        if (decoded["id"] case String id) {
          if (decodedResult["status"] != "processing" &&
              decodedResult["result"] != null) {
            _sessionCache[id] = decodedResult;
          }
          await EnyLocalPreferences().pendingReceipts.addItem(id).catchError((
            error,
          ) {
            _log.warning("Failed to save pending receipt ID", error);
          });
          unawaited(
            Future.delayed(
              const Duration(seconds: 10),
              resolveProcessedReceipt,
            ),
          );
          return decoded["id"];
        }
      }
    } catch (e, stackTrace) {
      if (e is EnyCredsError) {
        rethrow;
      }
      _log.severe("Failed to process receipt", e, stackTrace);
      return null;
    }
    return null;
  }

  Future<void> resolveProcessedReceipt() async {
    try {
      final List<String>? items = EnyLocalPreferences().pendingReceipts.get();
      if (items == null || items.isEmpty) {
        _log.finer("No pending receipts to resolve");
        return;
      }

      if (_currentConcurrentRequests >= _maxConcurrentRequests) {
        _log.fine(
          "Max concurrent requests reached ($_currentConcurrentRequests), delaying...",
        );
        return;
      }

      await Future.wait(
        items.take(_maxConcurrentRequests - _currentConcurrentRequests).map((
          id,
        ) {
          _currentConcurrentRequests += 1;
          return _resolveProcessedReceipt(id).whenComplete(() {
            _currentConcurrentRequests -= 1;
          });
        }),
      );

      await Future.delayed(const Duration(seconds: 3));

      return await resolveProcessedReceipt();
    } catch (e) {
      _log.warning("Failed to resolve processed receipt", e);
    }
  }

  Future<void> _resolveProcessedReceipt(String id, [int retryCount = 0]) async {
    _log.fine("Resolving processed receipt with ID $id");

    final Map? enyJson = switch (_sessionCache[id]) {
      Map m => m,
      _ => await fetchReceiptDetails(id),
    };

    bool completed = false;

    if (enyJson == null || enyJson["status"] == "processing") {
      _log.fine("Receipt $id is still processing");
      return Future.delayed(
        Duration(seconds: 5 + (retryCount * 5)),
        () => _resolveProcessedReceipt(id, retryCount + 1),
      );
    }

    if (enyJson["status"] != "completed" || enyJson["result"] is! Map) {
      completed = true;
    } else if (enyJson["result"]["data"] case Map enySuccessResult) {
      if (UserPreferencesService().createTransactionsPerItemInScans) {
        final parsed = TransactionMultiProgrammableObject.fromEnyJson(
          enySuccessResult,
        );
        for (final tranasction in parsed?.t ?? []) {
          tranasction.save(
            EnyReceipt(
              uuid: const Uuid().v4(),
              enyImageUrl: enySuccessResult["imageUrl"] as String?,
              enyReceiptId: id,
              partOfMultiTransaction: true,
            ),
          );
        }
        completed = parsed != null && parsed.t.isNotEmpty;
      } else {
        final parsed = TransactionProgrammableObject.fromEnyJson(
          enySuccessResult,
        );
        parsed?.save(
          extensions: [
            EnyReceipt(
              uuid: const Uuid().v4(),
              enyImageUrl: enySuccessResult["imageUrl"] as String?,
              enyReceiptId: id,
            ),
          ],
        );
        completed = parsed != null;
      }
    }

    if (completed) {
      await EnyLocalPreferences().pendingReceipts
          .removeItem(id)
          .catchError((error) => false);
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
