import "package:flow/entity/transaction/type.dart";
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

  static String? _getSingle(dynamic value) {
    if (value is Iterable) {
      return value.firstOrNull;
    }

    if (value is num) {
      return value.toString();
    }

    if (value is String) {
      return value;
    }

    return null;
  }

  static double? _getSingleDouble(dynamic value) {
    final stringValue = _getSingle(value);
    if (stringValue != null) {
      return double.tryParse(stringValue);
    }
    return null;
  }

  static List<String>? _getStringList(dynamic value) {
    if (value is Iterable) {
      return value.whereType<String>().where((x) => x.isNotEmpty).toList();
    }

    if (value is String) {
      return [value];
    }

    return null;
  }

  static TransactionProgrammableObject parse(Map<String, dynamic> params) {
    final DateTime? transactionDate = switch (_getSingle(
      params["transactionDate"],
    )) {
      String dateString => DateTime.tryParse(dateString),
      _ => null,
    };

    final TransactionType? type = switch (_getSingle(params["type"])) {
      String typeString => TransactionType.values.firstWhereOrNull(
        (value) => value.value.toLowerCase() == typeString.toLowerCase(),
      ),
      _ => null,
    };

    return TransactionProgrammableObject(
      transactionDate: transactionDate,
      categoryUuid: _getSingle(params["categoryUuid"]),
      category: _getSingle(params["category"]),
      notes: _getSingle(params["notes"]),
      title: _getSingle(params["title"]),
      amount: _getSingleDouble(params["amount"]),
      fromAccountUuid: _getSingle(params["fromAccountUuid"]),
      fromAccount: _getSingle(params["fromAccount"]),
      toAccountUuid: _getSingle(params["toAccountUuid"]),
      toAccount: _getSingle(params["toAccount"]),
      type: type,
      isPending: _getSingle(params["isPending"])?.toLowerCase() == "true",
      transferConversionRate: _getSingleDouble(
        params["transferConversionRate"],
      ),
      tagsUuids: _getStringList(params["tagsUuids"]),
      tags: _getStringList(params["tags"]),
      lat: _getSingleDouble(params["lat"]),
      lng: _getSingleDouble(params["lng"]),
    );
  }

  static TransactionProgrammableObject? tryParse(Map<String, dynamic> params) {
    try {
      return parse(params);
    } catch (e) {
      return null;
    }
  }
}
