import 'package:flow/entity/transaction.dart';
import 'package:flow/utils/jsonable.dart';

abstract class TransactionExtension implements Jasonable {
  final String key;

  const TransactionExtension(this.key);
}

abstract class TransactionDataExtension extends TransactionExtension {
  final Transaction transaction;

  const TransactionDataExtension(super.key, this.transaction) : super();
}
