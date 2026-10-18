import "dart:io";

import "package:flow/entity/_base.dart";
import "package:flow/objectbox.dart";
import "package:flow/utils/json/utc_datetime_converter.dart";
import "package:json_annotation/json_annotation.dart";
import "package:objectbox/objectbox.dart";
import "package:path/path.dart" as path;
import "package:uuid/uuid.dart";

part "file_attachment.g.dart";

@Entity()
@JsonSerializable(explicitToJson: true, converters: [UTCDateTimeConverter()])
class FileAttachment extends EntityBase {
  @JsonKey(includeFromJson: false, includeToJson: false)
  int id;

  @override
  @Unique()
  String uuid;

  @Property(type: PropertyType.date)
  DateTime createdDate;

  /// Display name. If null, the file name will be used.
  String? name;

  /// Relative path from objectbox root directory.
  String filePath;

  File get file {
    final String resolved = path.normalize(
      path.join(ObjectBox.appDataDirectory, filePath),
    );

    // Imported backups may carry arbitrary paths
    if (!path.isWithin(ObjectBox.filesDirectory, resolved)) {
      return File(path.join(ObjectBox.filesDirectory, path.basename(filePath)));
    }

    return File(resolved);
  }

  @Transient()
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get fileName => path.basename(filePath);

  FileAttachment({
    this.id = 0,
    this.name,
    required this.filePath,
    DateTime? createdDate,
  }) : uuid = const Uuid().v4(),
       createdDate = createdDate ?? DateTime.now();

  factory FileAttachment.fromJson(Map<String, dynamic> json) =>
      _$FileAttachmentFromJson(json);
  Map<String, dynamic> toJson() => _$FileAttachmentToJson(this);
}
