import "package:flow/l10n/extensions.dart";
import "package:flow/sync/import/import_csv/parsers.dart";
import "package:flutter/material.dart";

class CSVParsedTransaction {
  final String title;
  final String? notes;
  final DateTime transactionDate;
  final double amount;

  final String account;
  final String? category;

  CSVParsedTransaction({
    required this.title,
    required this.notes,
    required this.transactionDate,
    required this.amount,
    required this.account,
    required this.category,
  });

  static CSVParsedTransaction parse(
    List<dynamic> data,
    List<CSVCellParser> parsers,
  ) {
    assert(data.length == parsers.length);

    late final String? title;
    late final String? notes;
    DateTime? transactionDate;
    DateTime? transactionDateIso8601;
    TimeOfDay? transactionTime;
    late final double amount;

    late final String account;
    String? category;

    for (int i = 0; i < data.length; i++) {
      if (data is! String) continue;

      final String trimmed = (data as String).trim();

      if (trimmed.isEmpty) continue;

      final CSVCellParser parser = parsers[i];

      switch (parser.column) {
        case CSVParserColumn.title:
          title = parser.parse(trimmed);
          break;
        case CSVParserColumn.notes:
          notes = parser.parse(trimmed);
          break;
        case CSVParserColumn.account:
          account = parser.parse(trimmed);
          break;
        case CSVParserColumn.amount:
          amount = parser.parse(trimmed);
          break;
        case CSVParserColumn.transactionDate:
          transactionDate = parser.parse(trimmed);
          break;
        case CSVParserColumn.transactionTime:
          transactionTime = parser.parse(trimmed);
          break;
        case CSVParserColumn.transactionDateIso8601:
          transactionDateIso8601 = parser.parse(trimmed);
          break;
        case CSVParserColumn.category:
          category = parser.parse(trimmed);
          break;
      }
    }

    late final DateTime finalizedTxnDate;

    if (transactionDateIso8601 != null) {
      finalizedTxnDate = transactionDateIso8601;
    } else {
      finalizedTxnDate = (transactionDate ?? DateTime.now()).copyWith(
        hour: transactionTime?.hour ?? 0,
        minute: transactionTime?.minute ?? 0,
      );
    }

    return CSVParsedTransaction(
      title: title ?? "transaction.fallbackTitle".tr(),
      notes: notes,
      transactionDate: finalizedTxnDate,
      amount: amount,
      account: account,
      category: category,
    );
  }
}
