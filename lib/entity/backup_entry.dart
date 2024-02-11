import 'dart:io';

import 'package:flow/data/flow_icon.dart';
import 'package:flow/l10n/named_enum.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:objectbox/objectbox.dart';
import 'package:flow/sync/sync.dart';

@Entity()
class BackupEntry {
  int id;

  int syncModelVersion;

  @Property(type: PropertyType.date)
  DateTime createdDate;

  String filePath;

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
  FlowIconData get icon => switch (fileExt) {
        "json" => FlowIconData.icon(Symbols.hard_drive_rounded),
        "csv" => FlowIconData.icon(Symbols.table_rounded),
        _ => FlowIconData.icon(Symbols.error_rounded)
      };

  Future<bool> exists() => File(filePath).exists();
  bool existsSync() => File(filePath).existsSync();

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
