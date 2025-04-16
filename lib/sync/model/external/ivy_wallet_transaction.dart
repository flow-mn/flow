import "package:flow/entity/transaction.dart";

class IvyWalletTransaction {
  //     "Date",
  //     "Title",
  //     "Category",
  //     "Account",
  //     "Amount",
  //     "Currency",
  //     "Type",
  //     "Transfer Amount",
  //     "Transfer Currency",
  //     "To Account",
  //     "Receive Amount",
  //     "Receive Currency",
  //     "Description",
  //     "ID",

  final String uuid;
  final String? title;
  final String? note;

  final double amount;
  final String currency;

  final TransactionType type;

  final String account;
  final String? category;

  final String? transferToAccount;
  final String? transferToCurrency;
  final double? transferToAmount;

  const IvyWalletTransaction({
    required this.uuid,
    required this.title,
    required this.note,
    required this.amount,
    required this.currency,
    required this.type,
    required this.account,
    required this.category,
    required this.transferToAccount,
    required this.transferToCurrency,
    required this.transferToAmount,
  });
}
