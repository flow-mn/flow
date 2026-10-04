import "package:flow/data/insights/insight_engine.dart";
import "package:flow/data/insights/insight_thresholds.dart";
import "package:local_settings/local_settings.dart";
import "package:logging/logging.dart";
import "package:shared_preferences/shared_preferences.dart";

final Logger _log = Logger("InsightsLocalPreferences");

class InsightsLocalPreferences {
  final SharedPreferencesWithCache _prefs;

  static InsightsLocalPreferences? _instance;

  factory InsightsLocalPreferences() {
    if (_instance == null) {
      throw Exception(
        "You must initialize InsightsLocalPreferences by calling initialize().",
      );
    }

    return _instance!;
  }

  /// [InsightType.name]s the user chose not to see.
  late final StringListSettingsEntry hiddenTypes;

  /// Insights shown for the current month, latest per key. Used for the
  /// engine's cooldown.
  late final JsonListSettingsEntry<InsightSighting> sightings;

  InsightsLocalPreferences._internal(this._prefs) {
    SettingsEntry.defaultPrefix = "flow.insights.";

    hiddenTypes = StringListSettingsEntry(
      key: "hiddenTypes",
      preferences: _prefs,
      removeDuplicates: true,
    );

    sightings = JsonListSettingsEntry<InsightSighting>(
      key: "sightings",
      preferences: _prefs,
      fromJson: (json) => InsightSighting(
        key: json["key"] as String,
        shownAt: DateTime.parse(json["shownAt"] as String),
        stake: (json["stake"] as num).toDouble(),
      ),
      toJson: (sighting) => {
        "key": sighting.key,
        "shownAt": sighting.shownAt.toIso8601String(),
        "stake": sighting.stake,
      },
    );
  }

  Set<InsightType> get hiddenTypeSet {
    final Map<String, InsightType> byName = InsightType.values.asNameMap();

    return (hiddenTypes.get() ?? const [])
        .map((name) => byName[name])
        .nonNulls
        .toSet();
  }

  Future<void> setHidden(InsightType type, bool hidden) => hidden
      ? hiddenTypes.addItem(type.name)
      : hiddenTypes.removeItem(type.name);

  List<InsightSighting> get sightingList {
    try {
      return sightings.get() ?? const [];
    } catch (e, stackTrace) {
      _log.warning("Failed to read insight sightings", e, stackTrace);
      return const [];
    }
  }

  /// Replaces older sightings of the same keys, and forgets the ones too old
  /// to matter.
  Future<void> recordSightings(List<Insight> insights, DateTime now) async {
    final Set<String> keys = insights.map((insight) => insight.key).toSet();
    final DateTime cutoff = now.subtract(
      const Duration(days: InsightThresholds.cooldownDays * 2),
    );

    await sightings.set([
      ...sightingList.where(
        (sighting) =>
            !keys.contains(sighting.key) && sighting.shownAt.isAfter(cutoff),
      ),
      for (final Insight insight in insights)
        InsightSighting(key: insight.key, shownAt: now, stake: insight.stake),
    ]);
  }

  static InsightsLocalPreferences initialize(
    SharedPreferencesWithCache instance,
  ) => _instance ??= InsightsLocalPreferences._internal(instance);
}
