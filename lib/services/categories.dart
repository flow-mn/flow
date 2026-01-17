import "package:flow/entity/category.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:uuid/uuid.dart";

class CategoriesService {
  static CategoriesService? _instance;

  factory CategoriesService() => _instance ??= CategoriesService._internal();

  CategoriesService._internal() {
    // Constructor
  }

  Future<Category?> getOne(int id) async {
    return ObjectBox().box<Category>().getAsync(id);
  }

  Category? getOneSync(int id) {
    return ObjectBox().box<Category>().get(id);
  }

  Future<List<Category>> getAll() async {
    return ObjectBox().box<Category>().getAllAsync();
  }

  Future<Category?> findOne(dynamic identifier) async {
    if (identifier is int) {
      return await getOne(identifier);
    }

    if (identifier case String uuid when Uuid.isValidUUID(fromString: uuid)) {
      final q = ObjectBox()
          .box<Category>()
          .query(Category_.uuid.equals(uuid))
          .build();

      final Category? result = await q.findFirstAsync();

      q.close();
      return result;
    }

    if (identifier case String name) {
      final q = ObjectBox()
          .box<Category>()
          .query(Category_.name.equals(name))
          .build();

      final Category? result = await q.findFirstAsync();

      q.close();
      return result;
    }

    return null;
  }

  Category? findOneSync(dynamic identifier) {
    if (identifier is int) {
      return getOneSync(identifier);
    }

    if (identifier case String uuid when Uuid.isValidUUID(fromString: uuid)) {
      final q = ObjectBox()
          .box<Category>()
          .query(Category_.uuid.equals(uuid))
          .build();

      final Category? result = q.findFirst();

      q.close();
      return result;
    }

    if (identifier case String name) {
      final q = ObjectBox()
          .box<Category>()
          .query(Category_.name.equals(name))
          .build();

      final Category? result = q.findFirst();

      q.close();
      return result;
    }

    return null;
  }
}
