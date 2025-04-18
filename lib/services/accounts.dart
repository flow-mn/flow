import "package:flow/entity/account.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";

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

  Future<Account?> findOne(dynamic identifier) async {
    if (identifier is int) {
      return await getOne(identifier);
    }

    if (identifier case String uuid) {
      final q =
          ObjectBox().box<Account>().query(Account_.uuid.equals(uuid)).build();

      final Account? result = await q.findFirstAsync();

      q.close();
      return result;
    }

    return null;
  }
}
