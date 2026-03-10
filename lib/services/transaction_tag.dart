import "package:flow/entity/transaction_tag.dart";
import "package:flow/objectbox.dart";

class TransactionTagService {
  static TransactionTagService? _instance;

  factory TransactionTagService() =>
      _instance ??= TransactionTagService._internal();

  TransactionTagService._internal() {
    // Constructor
  }

  Future<TransactionTag?> getOne(int id) async {
    return ObjectBox().box<TransactionTag>().getAsync(id);
  }

  TransactionTag? getOneSync(int id) {
    return ObjectBox().box<TransactionTag>().get(id);
  }

  List<String> getAllUuidsSync() {
    final List<TransactionTag> transactionTags = ObjectBox()
        .box<TransactionTag>()
        .getAll();
    return transactionTags.map((tag) => tag.uuid).toList();
  }

  Future<List<TransactionTag>> getAll() async {
    return ObjectBox().box<TransactionTag>().getAllAsync();
  }
}
