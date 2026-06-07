import "package:flow/entity/account.dart";

/// One account's current balance, as a slice of total net worth.
class AccountBalanceShare {
  final Account account;
  final double amount;

  const AccountBalanceShare(this.account, this.amount);
}
