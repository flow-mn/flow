import "dart:io";

import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/named_enum.dart";
import "package:json_annotation/json_annotation.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:objectbox/objectbox.dart";
import "package:flow/sync/sync.dart";

@Entity()
class BackupEntry {
  int id;

  int syncModelVersion;

  @Property(type: PropertyType.date)
  DateTime createdDate;

  String filePath;

  String fileExt;

  /// For iCloud files. This does not guarantee that the file is
  /// actually in iCloud.
  ///
  /// This is set after a successful upload to iCloud, and never touched again.
  String? iCloudRelativePath;

  /// The date when the file was last changed in iCloud.
  @Property(type: PropertyType.date)
  DateTime? iCloudChangeDate;

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
  FlowIconData get icon => switch (fileExt) {
    "zip" => FlowIconData.icon(Symbols.hard_drive_rounded),
    "json" => FlowIconData.icon(Symbols.hard_drive_rounded),
    "csv" => FlowIconData.icon(Symbols.table_rounded),
    _ => FlowIconData.icon(Symbols.error_rounded),
  };

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
    this.iCloudRelativePath,
  }) : createdDate = createdDate ?? DateTime.now();
}

@JsonEnum(valueField: "value")
enum BackupEntryType implements LocalizedEnum {
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
