import "package:flow/entity/transaction.dart";

class IvyWalletTransaction {
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

  final DateTime? transactionDate;

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
    this.transactionDate,
  });

  double get conversionRate {
    if (type != TransactionType.transfer ||
        transferToAmount == 0 ||
        transferToAmount == null) {
      return 1;
    }

    return amount / transferToAmount!;
  }

  @override
  String toString() {
    return "IvyWalletTransaction{uuid: $uuid, title: $title, note: $note, amount: $amount, currency: $currency, type: $type, account: $account, category: $category, transferToAccount: $transferToAccount, transferToCurrency: $transferToCurrency, transferToAmount: $transferToAmount, transactionDate: $transactionDate}";
  }
}
