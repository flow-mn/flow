import "dart:convert";
import "dart:io";

import "package:csv/csv.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/sync/model/external/ivy_wallet_transaction.dart";
import "package:flow/sync/model/external/parsers.dart";
import "package:flow/utils/line_break_normalizer.dart";

class IvyWalletCsv {
  static const Set<String> supportedHeaders = {
    "Date",
    "Title",
    "Category",
    "Account",
    "Amount",
    "Currency",
    "Type",
    "Transfer Amount",
    "Transfer Currency",
    "To Account",
    "Receive Amount",
    "Receive Currency",
    "Description",
    "ID",
  };

  late final List<IvyWalletTransaction> transactions;

  Set<String> get accountNames => transactions.map((x) => x.account).toSet();
  Set<String?> get categoryNames => transactions.map((x) => x.category).toSet();

  IvyWalletCsv(List<List<dynamic>> data) {
    final Map<String, int> headerMap = {};

    final List headerRow = data.removeAt(0);

    for (int i = 0; i < headerRow.length; i++) {
      final String header = headerRow[i].toString().trim();
      if (supportedHeaders.contains(header)) {
        headerMap[header] = i;
      }
    }

    if (!supportedHeaders.every((header) => headerMap[header] != null)) {
      throw Exception("CSV data must have all the required headers");
    }

    transactions =
        data
            .map(
              (row) => IvyWalletTransaction(
                uuid: parseUuid(row[headerMap["ID"]!]),
                title: row[headerMap["Title"]!],
                note: row[headerMap["Description"]!],
                amount: double.parse(row[headerMap["Amount"]!]!),
                currency: parseRequiredString(row[headerMap["Currency"]!]),
                type: switch (parseRequiredString(row[headerMap["Type"]!])) {
                  "Expense" => TransactionType.expense,
                  "Income" => TransactionType.income,
                  "Transfer" => TransactionType.transfer,
                  _ => throw Exception("Unknown transaction type"),
                },
                account: parseRequiredString(row[headerMap["Account"]!]),
                category: parseOptionalString(row[headerMap["Category"]!]),
                transferToAccount: parseOptionalString(
                  row[headerMap["To Account"]!],
                ),
                transferToCurrency: parseOptionalString(
                  row[headerMap["Transfer Currency"]!],
                ),
                transferToAmount: double.tryParse(
                  row[headerMap["Transfer Amount"]!] ?? "",
                ),
              ),
            )
            .toList();
  }

  static Future<IvyWalletCsv> fromFile(File file) async {
    final Stream<List<int>> readStream = file.openRead();

    final List<List<dynamic>> rows =
        await readStream
            .transform(utf8.decoder)
            .transform(LineBreakNormalizer())
            .transform(CsvToListConverter(eol: LineBreakNormalizer.terminator))
            .toList();

    return IvyWalletCsv(rows);
  }
}
