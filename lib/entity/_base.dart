import "package:objectbox/objectbox.dart";

abstract class EntityBase {
  String get uuid;
}

extension ToOneRelationSerializer on ToOne<EntityBase> {
  String? relationToJson() => target?.uuid;
  String relationToJsonForced() => target!.uuid;
}
