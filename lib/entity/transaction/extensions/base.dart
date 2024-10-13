import "package:flow/entity/transaction.dart";
import "package:flow/utils/jasonable.dart";

abstract class TransactionExtension implements Jasonable {
  String get key;
  String? get relatedTransactionUuid;
  set relatedTransactionUuid(String? uuid);

  void setRelatedTransactionUuid(String uuid) =>
      relatedTransactionUuid = relatedTransactionUuid;

  const TransactionExtension();
}

abstract class TransactionDataExtension extends TransactionExtension {
  final Transaction transaction;

  const TransactionDataExtension(this.transaction) : super();
}
