import "dart:io";

import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/sync/sync.dart";
import "package:flow/utils/extensions/string.dart";
import "package:json_annotation/json_annotation.dart";
import "package:objectbox/objectbox.dart";

@Entity()
class BackupEntry {
  int id;

  int syncModelVersion;

  @Property(type: PropertyType.date)
  DateTime createdDate;

  String filePath;

  /// Does not have a leading dot.
  ///
  /// See [ExportMode]
  String fileExt;

  @Property()
  String type;

  @Transient()
  BackupEntryType get backupEntryType =>
      BackupEntryType.values
          .where((element) => element.value == (type))
          .firstOrNull ??
      BackupEntryType.other;

  @Transient()
  set backupEntryType(BackupEntryType value) {
    type = value.value;
  }

  @Transient()
  FlowIconData get icon => fileExt.backupExtensionIcon;

  Future<bool> exists() => File(filePath).exists();
  bool existsSync() => File(filePath).existsSync();
  Future<int> getFileSize() => File(filePath).length();
  int? getFileSizeSync() {
    try {
      return File(filePath).lengthSync();
    } catch (e) {
      return null;
    }
  }

  BackupEntry({
    this.id = 0,
    required this.filePath,
    DateTime? createdDate,
    this.syncModelVersion = latestSyncModelVersion,
    required this.type,
    required this.fileExt,
  }) : createdDate = createdDate ?? DateTime.now();
}

@JsonEnum(valueField: "value")
enum BackupEntryType with LocalizedEnum {
  manual("manual"),
  automated("automated"),
  preAccountDeletion("preAccountDeletion"),
  preImport("preImport"),
  other("other");

  final String value;

  const BackupEntryType(this.value);

  @override
  String get localizationEnumValue => name;
  @override
  String get localizationEnumName => "BackupEntryType";
}
