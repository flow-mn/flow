import "package:flow/entity/account.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:uuid/uuid.dart";

class AccountsService {
  static AccountsService? _instance;

  factory AccountsService() => _instance ??= AccountsService._internal();

  AccountsService._internal() {
    // Constructor
  }

  Future<Account?> getOne(int id) async {
    return ObjectBox().box<Account>().getAsync(id);
  }

  Account? getOneSync(int id) {
    return ObjectBox().box<Account>().get(id);
  }

  Future<List<Account>> getAll() async {
    return ObjectBox().box<Account>().getAllAsync();
  }

  Future<Account?> findOne(dynamic identifier) async {
    if (identifier is int) {
      return await getOne(identifier);
    }

    if (identifier case String uuid when Uuid.isValidUUID(fromString: uuid)) {
      final q = ObjectBox()
          .box<Account>()
          .query(Account_.uuid.equals(uuid))
          .build();

      final Account? result = await q.findFirstAsync();

      q.close();
      return result;
    }

    if (identifier case String name) {
      final q = ObjectBox()
          .box<Account>()
          .query(Account_.name.equals(name))
          .build();

      final Account? result = await q.findFirstAsync();

      q.close();
      return result;
    }

    return null;
  }

  Account? findOneSync(dynamic identifier) {
    if (identifier is int) {
      return getOneSync(identifier);
    }

    if (identifier case String uuid when Uuid.isValidUUID(fromString: uuid)) {
      final q = ObjectBox()
          .box<Account>()
          .query(Account_.uuid.equals(uuid))
          .build();

      final Account? result = q.findFirst();

      q.close();
      return result;
    }

    if (identifier case String name) {
      final q = ObjectBox()
          .box<Account>()
          .query(Account_.name.equals(name))
          .build();

      final Account? result = q.findFirst();

      q.close();
      return result;
    }

    return null;
  }

  Account? findOneActiveSync(dynamic identifier) {
    final account = findOneSync(identifier);
    if (account != null && !account.archived) {
      return account;
    }
    return null;
  }
}
