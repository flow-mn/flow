import 'package:json_annotation/json_annotation.dart';

part 'frecency.g.dart';

@JsonSerializable()
class FrecencyData {
  final String uuid;

  final DateTime lastUsed;

  final int useCount;

  const FrecencyData({
    required this.uuid,
    required this.lastUsed,
    required this.useCount,
  });

  FrecencyData incremented([int increment = 1]) {
    return FrecencyData(
      useCount: useCount + increment,
      lastUsed: DateTime.now(),
      uuid: uuid,
    );
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  double get score {
    final Duration sinceLastUsed = DateTime.now().difference(lastUsed);

    return switch (sinceLastUsed) {
      >= const Duration(days: 60) => useCount * 0.2,
      >= const Duration(days: 30) => useCount * 0.5,
      >= const Duration(days: 14) => useCount * 0.67,
      >= const Duration(days: 7) => useCount * 0.875,
      >= const Duration(hours: 72) => useCount.toDouble(),
      >= const Duration(hours: 24) => useCount * 2,
      >= const Duration(hours: 8) => useCount * 3,
      _ => useCount.toDouble(),
    };
  }

  factory FrecencyData.fromJson(Map<String, dynamic> json) =>
      _$FrecencyDataFromJson(json);
  Map<String, dynamic> toJson() => _$FrecencyDataToJson(this);
}
