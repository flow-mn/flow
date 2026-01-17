import "dart:convert";

import "package:flow/data/transaction_programmable_object.dart";

class TransactionMultiProgrammableObject {
  final List<TransactionProgrammableObject> t;

  const TransactionMultiProgrammableObject({required this.t});

  Map<String, String> toMap() {
    final map = <String, String>{};
    map["t"] = jsonEncode(t.map((e) => e.toMap()));
    return map;
  }

  static TransactionMultiProgrammableObject parse(Map<String, dynamic> params) {
    final List<dynamic> tList = (params["t"].runtimeType == String
        ? jsonDecode(params["t"] ?? "[]") as List<dynamic>
        : params["t"] as List<dynamic>);
    final transactions = tList
        .map(
          (e) => TransactionProgrammableObject.tryParse(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .nonNulls
        .toList();
    return TransactionMultiProgrammableObject(t: transactions);
  }

  static TransactionMultiProgrammableObject? tryParse(
    Map<String, dynamic> params,
  ) {
    try {
      return parse(params);
    } catch (e) {
      return null;
    }
  }

  static TransactionMultiProgrammableObject? fromUri(Uri uri) {
    try {
      final params = uri.queryParameters;

      if (params["json"] case String jason) {
        return tryParse(jsonDecode(jason));
      } else {
        throw Exception("No json parameter");
      }
    } catch (e) {
      return null;
    }
  }
}
