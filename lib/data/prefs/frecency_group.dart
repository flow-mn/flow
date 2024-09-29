import "package:flow/data/prefs/frecency.dart";
import "package:flow/utils/utils.dart";
import "package:json_annotation/json_annotation.dart";

part "frecency_group.g.dart";

@JsonSerializable()
class FrecencyGroup {
  final List<FrecencyData> data;

  const FrecencyGroup(this.data);

  double getScore(String uuid) =>
      data.firstWhereOrNull((element) => element.uuid == uuid)?.score ?? 0.0;

  factory FrecencyGroup.fromJson(Map<String, dynamic> json) =>
      _$FrecencyGroupFromJson(json);
  Map<String, dynamic> toJson() => _$FrecencyGroupToJson(this);
}
