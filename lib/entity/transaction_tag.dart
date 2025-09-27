import "dart:convert";

import "package:flow/data/flow_icon.dart";
import "package:flow/data/transaction_contact_tag.dart";
import "package:flow/entity/_base.dart";
import "package:flow/entity/transaction/tag_type.dart";
import "package:flow/theme/color_themes/registry.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/utils/extensions/transaction_tag_type.dart";
import "package:flow/utils/json/utc_datetime_converter.dart";
import "package:json_annotation/json_annotation.dart";
import "package:objectbox/objectbox.dart";
import "package:uuid/uuid.dart";

part "transaction_tag.g.dart";

@Entity()
@JsonSerializable(explicitToJson: true, converters: [UTCDateTimeConverter()])
class TransactionTag extends EntityBase {
  @JsonKey(includeFromJson: false, includeToJson: false)
  int id;

  @override
  @Unique()
  String uuid;

  @Property(type: PropertyType.date)
  DateTime createdDate;

  bool? isDeleted;

  @Property(type: PropertyType.date)
  DateTime? deletedDate;

  static const int maxTitleLength = 96;

  String title;

  String? iconCode;

  String? colorSchemeName;

  @Transient()
  FlowColorScheme? get colorScheme => getThemeStrict(colorSchemeName);

  @Transient()
  FlowIconData get icon {
    if (iconCode == null) {
      return FlowIconData.icon(tagType.icon);
    }

    try {
      return FlowIconData.parse(iconCode!);
    } catch (e) {
      return FlowIconData.icon(tagType.icon);
    }
  }

  @Transient()
  TransactionTagType get tagType => TransactionTagType.fromString(type);

  /// Type of tag, e.g., generic, location, contact, etc.
  ///
  /// See [TransactionTagType] for possible values.
  String? type;

  String? payload;

  TransactionTag({
    this.id = 0,
    String? uuid,
    DateTime? createdDate,
    this.isDeleted,
    this.deletedDate,
    required this.title,
    this.type,
    this.payload,
    this.iconCode,
    this.colorSchemeName,
  }) : createdDate = createdDate ?? DateTime.now(),
       uuid = Uuid.isValidUUID(fromString: uuid ?? "")
           ? uuid!
           : const Uuid().v4();

  static Object? parsePayload(TransactionTagType type, String? payload) {
    if (payload == null) return null;

    switch (type) {
      case TransactionTagType.generic:
        return payload;
      case TransactionTagType.location:
        {
          try {
            final List<double?> coordinates = payload
                .split(",")
                .map((e) => double.tryParse(e))
                .toList();

            if (coordinates.length != 2 ||
                coordinates.any((element) => element == null)) {
              return null;
            }

            return coordinates;
          } catch (e) {
            return null;
          }
        }
      case TransactionTagType.contact:
        {
          try {
            final Map<String, dynamic> json = jsonDecode(payload);
            return TransactionContactTag.fromJson(json);
          } catch (e) {
            return null;
          }
        }
    }
  }

  static String? serializePayload(Object? payload) {
    if (payload == null) return null;

    if (payload is String) {
      return payload;
    } else if (payload is List<double>) {
      return payload.join(",");
    } else if (payload is TransactionContactTag) {
      return jsonEncode(payload.toJson());
    } else {
      return null;
    }
  }
}
