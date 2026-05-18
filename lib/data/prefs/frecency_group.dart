import "package:flow/data/prefs/frecency.dart";
import "package:json_annotation/json_annotation.dart";

part "frecency_group.g.dart";

@JsonSerializable()
class FrecencyGroup {
  final List<FrecencyData> data;

  const FrecencyGroup(this.data);

  double getScore(String uuid) => data
      .where((element) => element.uuid == uuid)
      .map((element) => element.score)
      .fold(0.0, (a, b) => a + b);

  factory FrecencyGroup.fromJson(Map<String, dynamic> json) =>
      _$FrecencyGroupFromJson(json);
  Map<String, dynamic> toJson() => _$FrecencyGroupToJson(this);
}
