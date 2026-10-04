import "package:flow/data/insights/insight_engine.dart";
import "package:flow/prefs/insights_preferences.dart";
import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";

void main() {
  final InsightsLocalPreferences preferences =
      InsightsLocalPreferences.initialize(_MemoryPreferences());

  setUp(() async {
    await preferences.hiddenTypes.set([]);
    await preferences.sightings.set([]);
  });

  test("hidden types round trip and ignore unknown names", () async {
    await preferences.setHidden(.monthPace, true);
    await preferences.setHidden(.priceChange, true);
    await preferences.hiddenTypes.addItem("somethingRemoved");

    expect(preferences.hiddenTypeSet, {
      InsightType.monthPace,
      InsightType.priceChange,
    });

    await preferences.setHidden(.monthPace, false);
    expect(preferences.hiddenTypeSet, {InsightType.priceChange});
  });

  test("sightings keep the latest per key and forget old ones", () async {
    const NewCategoryInsight pets = NewCategoryInsight(
      score: 0.1,
      categoryUuid: "pets",
      current: 140.0,
      entryCount: 2,
      transactionUuids: [],
    );
    const NewCategoryInsight garden = NewCategoryInsight(
      score: 0.1,
      categoryUuid: "garden",
      current: 90.0,
      entryCount: 1,
      transactionUuids: [],
    );

    await preferences.recordSightings([pets, garden], DateTime(2026, 6, 1));
    await preferences.recordSightings([pets], DateTime(2026, 8, 20));

    final List<InsightSighting> sightings = preferences.sightingList;
    expect(sightings.map((sighting) => sighting.key), [pets.key]);
    expect(sightings.single.shownAt, DateTime(2026, 8, 20));
    expect(sightings.single.stake, 140.0);
  });
}

class _MemoryPreferences extends Fake implements SharedPreferencesWithCache {
  final Map<String, Object> _values = {};

  @override
  bool containsKey(String key) => _values.containsKey(key);

  @override
  List<String>? getStringList(String key) =>
      (_values[key] as List<String>?)?.toList();

  @override
  Future<void> setStringList(String key, List<String> value) async {
    _values[key] = value.toList();
  }
}
