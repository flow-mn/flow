import "package:flow/entity/transaction/type.dart";

class TransactionProgrammableObject {
  final String? title;
  final double? amount;
  final String? fromAccountUuid;
  final String? toAccountUuid;
  final TransactionType? type;
  final DateTime? transactionDate;
  final String? categoryUuid;
  final String? notes;

  /// Only applicable if the type is "transfer" and the accounts have different
  /// currencies. If the device is online, and has the currency rates fetched,
  /// the user will be suggested to fill this in automatically. Otherwise, the
  /// user will need to fill this in manually.
  final double? transferConversionRate;

  /// True by default if the [transactionDate] is in the future
  final bool? isPending;

  const TransactionProgrammableObject({
    required this.transactionDate,
    required this.categoryUuid,
    required this.notes,
    required this.title,
    required this.amount,
    required this.fromAccountUuid,
    required this.toAccountUuid,
    required this.type,
    required this.isPending,
    required this.transferConversionRate,
  });

  Map<String, String> toMap() {
    final map = <String, String>{};
    if (transactionDate != null) {
      map["transactionDate"] = transactionDate!.toIso8601String();
    }
    if (categoryUuid != null) map["categoryUuid"] = categoryUuid!;
    if (notes != null) map["notes"] = notes!;
    if (title != null) map["title"] = title!;
    if (amount != null) map["amount"] = amount!.toString();
    if (fromAccountUuid != null) map["fromAccountUuid"] = fromAccountUuid!;
    if (toAccountUuid != null) map["toAccountUuid"] = toAccountUuid!;
    if (type != null) map["type"] = type!.name;
    if (isPending != null) map["isPending"] = isPending! ? "true" : "false";
    if (transferConversionRate != null) {
      map["transferConversionRate"] = transferConversionRate!.toString();
    }
    return map;
  }

  static TransactionProgrammableObject fromUri(Uri uri) {
    final params = uri.queryParameters;

    return parse(params);
  }

  static TransactionProgrammableObject parse(Map<String, String> params) {
    return TransactionProgrammableObject(
      transactionDate: params["transactionDate"] != null
          ? DateTime.tryParse(params["transactionDate"]!)
          : null,
      categoryUuid: params["categoryUuid"],
      notes: params["notes"],
      title: params["title"],
      amount: params["amount"] != null
          ? double.tryParse(params["amount"]!)
          : null,
      fromAccountUuid: params["fromAccountUuid"],
      toAccountUuid: params["toAccountUuid"],
      type: params["type"] != null
          ? TransactionType.values.byName(params["type"]!)
          : null,
      isPending: params["isPending"]?.toLowerCase() == "true",
      transferConversionRate: params["transferConversionRate"] != null
          ? double.tryParse(params["transferConversionRate"]!)
          : null,
    );
  }

  static TransactionProgrammableObject? tryParse(Map<String, String> params) {
    try {
      return parse(params);
    } catch (e) {
      return null;
    }
  }
}
