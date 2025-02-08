import "package:json_annotation/json_annotation.dart";

@JsonEnum(valueField: "value")
enum TransactionSortField {
  /// Default
  transactionDate("transactionDate"),
  amount("amount"),
  createdDate("createdDate");

  final String value;

  const TransactionSortField(this.value);
}
