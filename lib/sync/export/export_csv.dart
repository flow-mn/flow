import "package:csv/csv.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/services/transactions.dart";
import "package:flow/sync/export/headers/header_v1.dart";
import "package:intl/intl.dart";
import "package:moment_dart/moment_dart.dart";

Future<String> generateCSVContent() async {
  final transactions = await TransactionsService().findMany(
    TransactionFilter.empty,
  );

  final headers = [
    CSVHeadersV1.uuid.localizedName,
    CSVHeadersV1.title.localizedName,
    CSVHeadersV1.notes.localizedName,
    CSVHeadersV1.amount.localizedName,
    CSVHeadersV1.currency.localizedName,
    CSVHeadersV1.account.localizedName,
    CSVHeadersV1.accountUuid.localizedName,
    CSVHeadersV1.category.localizedName,
    CSVHeadersV1.categoryUuid.localizedName,
    CSVHeadersV1.type.localizedName,
    CSVHeadersV1.subtype.localizedName,
    CSVHeadersV1.createdDate.localizedName,
    CSVHeadersV1.transactionDate.localizedName,
    CSVHeadersV1.transactionDateIso8601.localizedName,
    CSVHeadersV1.latitude.localizedName,
    CSVHeadersV1.longitude.localizedName,
    CSVHeadersV1.extra.localizedName,
  ];

  final Map<String, int> numberOfDecimalsToKeep = {};

  final transformed =
      transactions
          .map(
            (e) => [
              e.uuid,
              e.title ?? "",
              e.description ?? "",
              e.amount.toStringAsFixed(
                numberOfDecimalsToKeep[e.currency] ??=
                    NumberFormat.currency(name: e.currency).decimalDigits ?? 2,
              ),
              e.currency,
              e.account.target?.name,
              e.account.target?.uuid,
              e.category.target?.name,
              e.category.target?.uuid,
              e.type.localizedName,
              e.transactionSubtype?.localizedName,
              e.createdDate.format(payload: "LLL", forceLocal: true),
              e.transactionDate.format(payload: "LLL", forceLocal: true),
              e.transactionDate.toUtc().toIso8601String(),
              e.extensions.geo?.latitude?.toString() ?? "",
              e.extensions.geo?.longitude?.toString() ?? "",
              e.extra,
            ],
          )
          .toList()
        ..insert(0, headers);

  return const ListToCsvConverter().convert(
    transformed,
    convertNullTo: "",
    eol: "\n",
  );
}
