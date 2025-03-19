import "package:flow/l10n/extensions.dart";
import "package:flow/sync/model/csv/parsers.dart";

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
    List<CSVCellParser?> parsers,
    int? row,
  ) {
    assert(data.length <= parsers.length);

    String? title;
    String? notes;
    DateTime? transactionDate;
    DateTime? transactionDateIso8601;
    (int, int, int?)? transactionTime;

    late final double amount;
    late final String account;

    String? category;

    for (int i = 0; i < data.length; i++) {
      final String? cell = data[i]?.toString().trim();

      if (cell == null || cell.isEmpty) continue;

      final CSVCellParser? parser = parsers[i];
      if (parser == null) continue;

      final parsed = parser.parse(cell, row: row);

      switch (parser.column) {
        case CSVParserColumn.title:
          title = parsed;
        case CSVParserColumn.notes:
          notes = parsed;
        case CSVParserColumn.account:
          account = parsed;
        case CSVParserColumn.amount:
          amount = parsed;
        case CSVParserColumn.transactionDate:
          transactionDate = parsed;
        case CSVParserColumn.transactionTime:
          transactionTime = parsed;
        case CSVParserColumn.transactionDateIso8601:
          transactionDateIso8601 = parsed;
        case CSVParserColumn.category:
          category = parsed;
      }
    }

    late final DateTime finalizedTxnDate;

    if (transactionDateIso8601 != null) {
      finalizedTxnDate = transactionDateIso8601;
    } else {
      finalizedTxnDate = (transactionDate ?? DateTime.now()).copyWith(
        hour: transactionTime?.$1,
        minute: transactionTime?.$2,
        second: transactionTime?.$3,
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
