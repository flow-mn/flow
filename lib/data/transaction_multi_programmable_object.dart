import "dart:convert";

import "package:flow/data/transaction_programmable_object.dart";
import "package:flow/utils/loose_parsers.dart";

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

  static TransactionMultiProgrammableObject? fromEnyJson(Map json) {
    try {
      final List<dynamic>? items = json["items"] as List<dynamic>?;
      if (items == null || items.isEmpty) {
        return null;
      }
      final transactions = items
          .map((item) {
            try {
              final itemMap = item as Map?;

              if (itemMap == null) return null;

              final String title = looseString(itemMap["name"]) ?? "An item";
              final double amount = -(looseDouble(itemMap["amount"]) ?? 0.0);
              final DateTime transactionDate = switch (looseString(
                json["date"],
              )) {
                String dateString =>
                  DateTime.tryParse(dateString) ?? DateTime.now(),
                _ => DateTime.now(),
              };
              final int quantity =
                  looseDouble(itemMap["quantity"])?.toInt() ?? 1;
              final String notes = "Quantity: $quantity\n\nImported from Eny";

              return TransactionProgrammableObject(
                title: title,
                amount: amount,
                transactionDate: transactionDate,
                notes: notes,
              );
            } catch (e) {
              return null;
            }
          })
          .whereType<TransactionProgrammableObject>()
          .toList();
      return TransactionMultiProgrammableObject(t: transactions);
    } catch (e) {
      return null;
    }
  }
}
