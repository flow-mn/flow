import "package:flow/utils/jasonable.dart";

abstract class TransactionExtension implements Jasonable {
  final String uuid;

  String get key;
  String? get relatedTransactionUuid;
  set relatedTransactionUuid(String? uuid);

  void setRelatedTransactionUuid(String uuid) =>
      relatedTransactionUuid = relatedTransactionUuid;

  const TransactionExtension({required this.uuid});
}
