import "package:flow/l10n/named_enum.dart";
import "package:flow/sync/import/base.dart";
import "package:flow/sync/import/import_csv/parsers.dart";
import "package:flow/sync/import/import_progress_generic.dart";
import "package:flutter/foundation.dart";

/// See format:
///
/// https://docs.google.com/spreadsheets/d/1wxdJ1T8PSvzayxvGs7bVyqQ9Zu0DPQ1YwiBLy1FluqE/edit?usp=sharing
class ImportCSV extends Importer {
  @override
  final List<List<dynamic>> data;

  final Map<String, String> accountCurrencies = {};
  final Set<String> categories = <String>{};

  Set<String> get accounts => accountCurrencies.keys.toSet();

  /// `null` for irrelevant columns
  final List<CSVCellParser?> orderedParserList = [];

  ImportCSV(this.data) : assert(data.length > 1);

  void parse() {
    _prepareParsers();
  }

  /// This methods recognizes the promised format headers, and prepares parsers
  /// for each column according to the order of the headers.
  void _prepareParsers() {
    orderedParserList.clear();
    for (dynamic header in data.first) {
      switch (header?.toString()) {
        case "flow_title":
        case "Title":
          orderedParserList.add(StringParser(CSVParserColumn.title));
          break;
        case "flow_notes":
        case "Notes":
          orderedParserList.add(StringParser(CSVParserColumn.notes));
          break;
        case "flow_account_name":
        case "Account":
          orderedParserList.add(StringParser(CSVParserColumn.account));
          break;
        case "flow_amount":
        case "Amount":
          orderedParserList.add(AmountParser(CSVParserColumn.title));
          break;
        case "flow_date_of_transaction":
          orderedParserList.add(DateParser(CSVParserColumn.transactionDate));
          break;
        case "flow_time_of_transaction_optional":
        case "Time":
          orderedParserList.add(TimeParser(CSVParserColumn.transactionTime));
          break;
        case "flow_date_of_transaction_iso_8601":
        case "Transaction date (ISO 8601)":
          orderedParserList.add(
            DateParser(CSVParserColumn.transactionDateIso8601),
          );
          break;
        case "flow_category_optional":
        case "Category":
          orderedParserList.add(StringParser(CSVParserColumn.category));
          break;
        default:
          orderedParserList.add(null);
      }
    }
  }

  @override
  Future<String?> execute({bool ignoreSafetyBackupFail = false}) {
    // TODO: implement execute
    throw UnimplementedError();
  }

  @override
  final ValueNotifier<ImportCSVProgress> progressNotifier = ValueNotifier(
    ImportCSVProgress.waitingConfirmation,
  );
}

/// Used to report current status to user
enum ImportCSVProgress implements LocalizedEnum {
  waitingConfirmation,
  parsing,
  erasing,
  creatingAccounts,
  creatingCategories,
  creatingTransactions,
  success,
  error;

  @override
  String get localizationEnumValue => name;
  @override
  String get localizationEnumName => "ImportCSVProgress";
}
