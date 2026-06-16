import "package:flow/entity/_base.dart";
import "package:objectbox/objectbox.dart";

/// Put helpers that stamp [EntityBase.updatedAt] for delta sync / last-write-
/// wins. Use for user-initiated writes; never on import/restore, or remote
/// records always look newer than local and merge breaks.
extension SyncableBox<T extends EntityBase> on Box<T> {
  int putSynced(T object, {PutMode mode = PutMode.put}) {
    object.updatedAt = DateTime.now().toUtc();
    return put(object, mode: mode);
  }

  Future<int> putSyncedAsync(T object, {PutMode mode = PutMode.put}) {
    object.updatedAt = DateTime.now().toUtc();
    return putAsync(object, mode: mode);
  }

  Future<T> putAndGetSyncedAsync(T object, {PutMode mode = PutMode.put}) {
    object.updatedAt = DateTime.now().toUtc();
    return putAndGetAsync(object, mode: mode);
  }

  List<int> putManySynced(List<T> objects, {PutMode mode = PutMode.put}) {
    final DateTime now = DateTime.now().toUtc();
    for (final T object in objects) {
      object.updatedAt = now;
    }
    return putMany(objects, mode: mode);
  }

  Future<List<int>> putManySyncedAsync(
    List<T> objects, {
    PutMode mode = PutMode.put,
  }) {
    final DateTime now = DateTime.now().toUtc();
    for (final T object in objects) {
      object.updatedAt = now;
    }
    return putManyAsync(objects, mode: mode);
  }
}
