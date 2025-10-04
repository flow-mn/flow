import "dart:io";

import "package:cross_file/cross_file.dart";
import "package:flow/entity/_base.dart";
import "package:flow/logging.dart";
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

  File get file => File(path.join(ObjectBox.appDataDirectory, filePath));

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

  /// Returns the path for [ImageFlowIcon]
  static Future<FileAttachment?> fromFile(XFile xFile) async {
    try {
      final String fileName = "${const Uuid().v4()}/${xFile.name}";
      final File file = File(path.join(ObjectBox.filesDirectory, fileName));
      await file.create(recursive: true);
      await File(xFile.path).copy(file.path);

      return FileAttachment(
        filePath: "${ObjectBox.filesDirectoryName}/$fileName",
      );
    } catch (e, stackTrace) {
      mainLogger.warning(
        "Couldn't create file attachment from $xFile",
        e,
        stackTrace,
      );
      return null;
    }
  }
}
