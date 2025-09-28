import "dart:io";

import "package:flow/entity/transaction.dart";
import "package:flow/sync/model/external/ivy/ivy_wallet_transaction.dart";
import "package:flow/sync/model/external/ivy/parsers.dart";
import "package:flow/utils/csv_parser.dart";
import "package:intl/intl.dart";

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

    transactions = data
        .map((row) {
          if (row.isEmpty) {
            return null;
          }

          final type = switch (parseRequiredString(
            row[headerMap["Type"]!]?.toString().toUpperCase(),
          )) {
            "EXPENSE" => TransactionType.expense,
            "INCOME" => TransactionType.income,
            "TRANSFER" => TransactionType.transfer,
            _ => throw Exception("Unknown transaction type"),
          };

          final bool isTransfer = type == TransactionType.transfer;

          dynamic amount =
              row[headerMap[isTransfer ? "Transfer Amount" : "Amount"]!] ?? 0.0;

          if (amount is String) {
            amount =
                NumberFormat(null, "en_US").tryParse(amount)?.toDouble() ??
                double.tryParse(amount) ??
                0.0;
          } else {
            amount = (amount as num).toDouble();
          }

          dynamic transferToAmount = row[headerMap["Receive Amount"]!];
          if (transferToAmount is String) {
            transferToAmount = double.tryParse(transferToAmount);
          }

          return IvyWalletTransaction(
            uuid: parseUuid(row[headerMap["ID"]!]),
            title: parseOptionalString(row[headerMap["Title"]!]),
            note: row[headerMap["Description"]!],
            amount: amount,
            currency: parseRequiredString(
              row[headerMap[isTransfer ? "Transfer Currency" : "Currency"]!],
            ),
            type: type,
            account: parseRequiredString(row[headerMap["Account"]!]),
            category: parseOptionalString(row[headerMap["Category"]!]),
            transferToAccount: parseOptionalString(
              row[headerMap["To Account"]!],
            ),
            transferToCurrency: parseOptionalString(
              row[headerMap["Receive Currency"]!],
            ),
            transferToAmount: transferToAmount,
            transactionDate: parseOptionalDate(row[headerMap["Date"]!]),
          );
        })
        .nonNulls
        .toList();
  }

  static Future<IvyWalletCsv> fromFile(File file) async {
    return IvyWalletCsv(await parseCsvFromFile(file));
  }
}
