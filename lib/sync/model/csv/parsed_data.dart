import "package:flow/sync/model/csv/csv_parsed_transaction.dart";
import "package:flow/sync/model/csv/parsers.dart";

class CSVParsedData {
  /// `null` for irrelevant columns
  late final List<CSVCellParser?> orderedParserList;

  late final List<CSVParsedTransaction> transactions;

  Set<String> get accountNames => transactions.map((x) => x.account).toSet();
  Set<String?> get categoryNames => transactions.map((x) => x.category).toSet();

  /// This is very prone to throwing, please catch it
  CSVParsedData(List<List<dynamic>> data) {
    if (data.length < 2) {
      throw const FormatException("CSV data must have at least 2 rows");
    }

    orderedParserList = _prepareParsers(data);

    if (orderedParserList
            .where(
              (x) => x is AmountParser && x.column == CSVParserColumn.amount,
            )
            .length !=
        1) {
      throw const FormatException(
        "CSV data must have exactly one 'Amount' or 'flow_amount' column",
      );
    }

    if (orderedParserList
            .where(
              (x) => x is StringParser && x.column == CSVParserColumn.account,
            )
            .length !=
        1) {
      throw const FormatException(
        "CSV data must have exactly one 'Account' or 'flow_account' column",
      );
    }

    transactions =
        data
            .sublist(1)
            .map((row) => CSVParsedTransaction.parse(row, orderedParserList))
            .toList();
  }

  /// This methods recognizes the promised format headers, and prepares parsers
  /// for each column according to the order of the headers.
  List<CSVCellParser?> _prepareParsers(List<List<dynamic>> data) {
    final List<CSVCellParser?> value = [];

    for (dynamic header in data.first) {
      switch (header?.toString().toLowerCase()) {
        case "flow_title":
        case "Title":
          value.add(StringParser(CSVParserColumn.title));
        case "flow_notes":
        case "Notes":
          value.add(StringParser(CSVParserColumn.notes));
        case "flow_account_name":
        case "Account":
          value.add(StringParser(CSVParserColumn.account));
        case "flow_amount":
        case "Amount":
          value.add(AmountParser(CSVParserColumn.amount));
        case "flow_date_of_transaction":
        case "Transaction date":
        case "Date":
          value.add(DateParser(CSVParserColumn.transactionDate));
        case "flow_time_of_transaction_optional":
        case "Transaction time":
        case "Time":
          value.add(TimeParser(CSVParserColumn.transactionTime));
        case "flow_date_of_transaction_iso_8601":
        case "Transaction date (ISO 8601)":
          value.add(ISO8601DateParser(CSVParserColumn.transactionDateIso8601));
        case "flow_category_optional":
        case "Category":
          value.add(StringParser(CSVParserColumn.category));
        default:
          value.add(null);
      }
    }

    return value;
  }
}
