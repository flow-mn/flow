import "package:objectbox/objectbox.dart";

/// Contract for entities that sync across devices: a stable [uuid] identity and
/// an [updatedAt] clock for delta sync / last-write-wins.
abstract class EntityBase {
  String get uuid;

  /// UTC time of last local write. `null` for legacy/imported rows — treat as
  /// "as old as `createdDate`". Stamp via `SyncableBox.putSynced`; leave
  /// untouched on import so remote records keep their own clock.
  DateTime? get updatedAt;
  set updatedAt(DateTime? value);
}

extension ToOneRelationSerializer on ToOne<EntityBase> {
  String? relationToJson() => target?.uuid;
  String relationToJsonForced() => target!.uuid;
}
