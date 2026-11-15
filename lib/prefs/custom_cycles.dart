import "dart:convert";

import "package:shared_preferences/shared_preferences.dart";

class CustomCycle {
  final String id;
  final String name;
  final int startDay;
  final int endDay;

  const CustomCycle({
    required this.id,
    required this.name,
    required this.startDay,
    required this.endDay,
  }) : assert(startDay >= 1 && startDay <= 31),
       assert(endDay >= 1 && endDay <= 31);

  factory CustomCycle.fromJson(Map<String, dynamic> json) => CustomCycle(
    id: json["id"] as String? ?? "",
    name: json["name"] as String? ?? "Cycle",
    startDay: (json["startDay"] as num?)?.toInt() ?? 1,
    endDay: (json["endDay"] as num?)?.toInt() ?? 1,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "startDay": startDay,
    "endDay": endDay,
  };
}

class CustomCyclePreferences {
  final SharedPreferencesWithCache _prefs;

  static const String _storageKey = "customCycles";
  static CustomCyclePreferences? _instance;

  factory CustomCyclePreferences() {
    if (_instance == null) {
      throw StateError(
        "CustomCyclePreferences must be initialized before use.",
      );
    }

    return _instance!;
  }

  CustomCyclePreferences._internal(this._prefs);

  List<CustomCycle> get cycles {
    final String? raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return const <CustomCycle>[];

    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! List) return const <CustomCycle>[];

      final List<CustomCycle> values = <CustomCycle>[];
      for (final dynamic entry in decoded) {
        if (entry is Map<String, dynamic>) {
          values.add(CustomCycle.fromJson(entry));
        } else if (entry is Map) {
          values.add(CustomCycle.fromJson(Map<String, dynamic>.from(entry)));
        }
      }
      return values;
    } catch (_) {
      return const <CustomCycle>[];
    }
  }

  CustomCycle? cycleById(String id) {
    for (final cycle in cycles) {
      if (cycle.id == id) return cycle;
    }
    return null;
  }

  Future<void> saveCycles(List<CustomCycle> value) async {
    final encoded = jsonEncode(
      value.map((cycle) => cycle.toJson()).toList(growable: false),
    );
    await _prefs.setString(_storageKey, encoded);
  }

  Future<void> addOrUpdateCycle(CustomCycle cycle) async {
    final List<CustomCycle> next = cycles.toList(growable: true);
    final int index = next.indexWhere((item) => item.id == cycle.id);

    if (index >= 0) {
      next[index] = cycle;
    } else {
      next.add(cycle);
    }

    await saveCycles(next);
  }

  Future<void> deleteCycle(String id) async {
    final List<CustomCycle> next = cycles
        .where((cycle) => cycle.id != id)
        .toList(growable: true);
    await saveCycles(next);
  }

  static CustomCyclePreferences initialize(
    SharedPreferencesWithCache instance,
  ) => _instance ??= CustomCyclePreferences._internal(instance);
}
