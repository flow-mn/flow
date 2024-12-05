import "package:flow/entity/transaction.dart";
import "package:moment_dart/moment_dart.dart";

extension TransactionHelpers on Transaction {
  bool confirmable([DateTime? anchor]) {
    if (isPending != true) return false;

    return transactionDate.isPastAnchored(
      anchor ?? Moment.now().endOfNextMinute(),
    );
  }

  bool holdable([DateTime? anchor]) {
    if (isPending != true) return false;

    return transactionDate.isFutureAnchored(
      anchor ?? Moment.now().startOfMinute(),
    );
  }
}
