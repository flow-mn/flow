import "dart:convert";

import "package:json_annotation/json_annotation.dart";
import "package:latlong2/latlong.dart";

part "payload.g.dart";

@JsonSerializable()
class TransactionTagLocationPayload {
  final double lat;
  final double lng;

  @JsonKey(includeFromJson: false, includeToJson: false)
  LatLng get latLng => LatLng(lat, lng);

  const TransactionTagLocationPayload(this.lat, this.lng);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionTagLocationPayload &&
        other.lat == lat &&
        other.lng == lng;
  }

  @override
  int get hashCode => Object.hash(lat, lng);

  factory TransactionTagLocationPayload.fromJson(Map<String, dynamic> json) =>
      _$TransactionTagLocationPayloadFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionTagLocationPayloadToJson(this);
}

@JsonSerializable()
class TransactionContactTag {
  final String? id;
  final String? name;

  const TransactionContactTag({this.id, this.name});

  factory TransactionContactTag.fromJson(Map<String, dynamic> json) =>
      _$TransactionContactTagFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionContactTagToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionContactTag &&
        other.id == id &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, name);
}

@JsonSerializable()
class TransactionTagPayload {
  final TransactionTagLocationPayload? location;
  final TransactionContactTag? contact;

  const TransactionTagPayload({this.location, this.contact});

  factory TransactionTagPayload.fromJson(Map<String, dynamic> json) =>
      _$TransactionTagPayloadFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionTagPayloadToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionTagPayload &&
        other.location == location &&
        other.contact == contact;
  }

  @override
  int get hashCode => Object.hash(location, contact);

  TransactionTagPayload copyWith({
    TransactionTagLocationPayload? location,
    TransactionContactTag? contact,
  }) {
    return TransactionTagPayload(
      location: location ?? this.location,
      contact: contact ?? this.contact,
    );
  }

  static TransactionTagPayload? tryParse(String? payload) {
    if (payload == null) return null;

    try {
      final Map<String, dynamic> json = jsonDecode(payload);
      return TransactionTagPayload.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  String serialize() {
    return jsonEncode(toJson());
  }
}
