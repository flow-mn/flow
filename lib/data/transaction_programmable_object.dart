import "package:flow/data/money.dart";
import "package:flow/entity/transaction/type.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/utils/loose_parsers.dart";
import "package:flow/utils/utils.dart";

class TransactionProgrammableObject {
  final String? title;
  final double? amount;
  final String? fromAccountUuid;
  final String? fromAccount;
  final String? toAccountUuid;
  final String? toAccount;
  final TransactionType? type;
  final DateTime? transactionDate;
  final String? categoryUuid;
  final String? category;
  final String? notes;
  final List<String>? tagsUuids;
  final List<String>? tags;
  final double? lat;
  final double? lng;

  /// Only applicable if the type is "transfer" and the accounts have different
  /// currencies. If the device is online, and has the currency rates fetched,
  /// the user will be suggested to fill this in automatically. Otherwise, the
  /// user will need to fill this in manually.
  final double? transferConversionRate;

  /// True by default if the [transactionDate] is in the future
  final bool? isPending;

  const TransactionProgrammableObject({
    this.transactionDate,
    this.categoryUuid,
    this.category,
    this.notes,
    this.title,
    this.amount,
    this.fromAccountUuid,
    this.fromAccount,
    this.toAccountUuid,
    this.toAccount,
    this.type,
    this.isPending,
    this.transferConversionRate,
    this.tagsUuids,
    this.tags,
    this.lat,
    this.lng,
  });

  Map<String, String> toMap() {
    final map = <String, String>{};
    if (transactionDate != null) {
      map["transactionDate"] = transactionDate!.toIso8601String();
    }
    if (categoryUuid != null) map["categoryUuid"] = categoryUuid!;
    if (category != null) map["category"] = category!;
    if (notes != null) map["notes"] = notes!;
    if (title != null) map["title"] = title!;
    if (amount != null) map["amount"] = amount!.toString();
    if (fromAccountUuid != null) map["fromAccountUuid"] = fromAccountUuid!;
    if (fromAccount != null) map["fromAccount"] = fromAccount!;
    if (toAccountUuid != null) map["toAccountUuid"] = toAccountUuid!;
    if (toAccount != null) map["toAccount"] = toAccount!;
    if (type != null) map["type"] = type!.name;
    if (isPending != null) map["isPending"] = isPending! ? "true" : "false";
    if (transferConversionRate != null) {
      map["transferConversionRate"] = transferConversionRate!.toString();
    }
    if (tagsUuids != null) {
      map["tagsUuids"] = tagsUuids!.join(",");
    }
    if (tags != null) {
      map["tags"] = tags!.join(",");
    }
    if (lat != null) {
      map["lat"] = lat!.toString();
    }
    if (lng != null) {
      map["lng"] = lng!.toString();
    }
    return map;
  }

  static TransactionProgrammableObject? fromUri(Uri uri) {
    final params = uri.queryParametersAll;

    return tryParse(params);
  }

  static TransactionProgrammableObject parse(Map<String, dynamic> params) {
    final DateTime? transactionDate = switch (looseString(
      params["transactionDate"],
    )) {
      String dateString => DateTime.tryParse(dateString),
      _ => null,
    };

    final TransactionType? type = switch (looseString(params["type"])) {
      String typeString => TransactionType.values.firstWhereOrNull(
        (value) => value.value.toLowerCase() == typeString.toLowerCase(),
      ),
      _ => null,
    };

    return TransactionProgrammableObject(
      transactionDate: transactionDate,
      categoryUuid: looseString(params["categoryUuid"]),
      category: looseString(params["category"]),
      notes: looseString(params["notes"]),
      title: looseString(params["title"]),
      amount: looseDouble(params["amount"]),
      fromAccountUuid: looseString(params["fromAccountUuid"]),
      fromAccount: looseString(params["fromAccount"]),
      toAccountUuid: looseString(params["toAccountUuid"]),
      toAccount: looseString(params["toAccount"]),
      type: type,
      isPending: looseString(params["isPending"])?.toLowerCase() == "true",
      transferConversionRate: looseDouble(params["transferConversionRate"]),
      tagsUuids: looseStringList(params["tagsUuids"]),
      tags: looseStringList(params["tags"]),
      lat: looseDouble(params["lat"]),
      lng: looseDouble(params["lng"]),
    );
  }

  static TransactionProgrammableObject? tryParse(Map<String, dynamic> params) {
    try {
      return parse(params);
    } catch (e) {
      return null;
    }
  }

  static TransactionProgrammableObject? fromEnyJson(Map json) {
    try {
      final String title = (json["merchant"] as String?) ?? "Receipt from Eny";
      final double? amount = (json["total"] as num?)?.toDouble();
      final DateTime transactionDate = switch (json["date"]) {
        String dateString => DateTime.tryParse(dateString) ?? DateTime.now(),
        _ => DateTime.now(),
      };
      final String notes = (() {
        final items = json["items"];
        if (items is! List) return "Imported from Eny";

        final itemLines = items
            .map((item) {
              final itemMap = item as Map?;

              if (itemMap == null) return null;

              final String name = looseString(itemMap["name"]) ?? "An item";
              final int quantity =
                  looseDouble(itemMap["quantity"])?.toInt() ?? 1;
              final double itemAmount =
                  -(looseDouble(itemMap["amount"]) ?? 0.0);
              final String? currency = looseString(itemMap["currency"]);

              final String amountStr = Money(
                itemAmount,
                currency ?? UserPreferencesService().primaryCurrency,
              ).formatted;

              return "$quantity x $name - ${amountStr.trim()}";
            })
            .whereType<String>()
            .join("\n");

        return "$itemLines\n\nImported from Eny";
      })();
      return TransactionProgrammableObject(
        title: title,
        amount: amount,
        transactionDate: transactionDate,
        notes: notes,
      );
    } catch (e) {
      return null;
    }
  }
}
