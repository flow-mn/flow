import "package:flow/entity/account.dart";
import "package:flow/objectbox.dart";

class AccountsService {
  static AccountsService? _instance;

  factory AccountsService() => _instance ??= AccountsService._internal();

  AccountsService._internal() {
    // Constructor
  }

  Future<Account?> getOne(int id) async {
    return ObjectBox().box<Account>().getAsync(id);
  }

  Future<List<Account>> getAll() async {
    return ObjectBox().box<Account>().getAllAsync();
  }

  int countAll() {
    return ObjectBox().box<Account>().count();
  }
}
