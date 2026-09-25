/// Every tuning knob of the insight engine, in one place.
abstract final class InsightThresholds {
  /// Complete months before the analyzed one that make up the baseline.
  static const int baselineMonths = 6;

  /// A baseline month with fewer expenses is treated as a logging gap.
  static const int minExpensesPerMonth = 10;

  /// Active baseline months required before the engine says anything.
  static const int minActiveMonths = 3;

  /// Month comparisons stay quiet before this day of an in-progress month.
  static const int minDayOfMonth = 7;

  static const double monthAboveRatio = 1.25;
  static const double monthBelowRatio = 0.80;

  /// Materiality floor: max(share × usual month, multiple × median expense).
  static const double materialityShare = 0.05;
  static const double materialityMedianMultiple = 3.0;

  /// A single transaction covering this share of a change gets named.
  static const double attributionShare = 0.5;

  static const double categorySpikeRatio = 1.5;
  static const int categorySpikeMinEntries = 3;
  static const int maxCategorySpikes = 2;

  /// Months a category must appear in to have a usual amount.
  static const int categoryMinMonthsPresent = 3;

  static const double categoryDropRatio = 0.6;

  /// Categories smaller than this share of the usual month can't "drop".
  static const double categoryDropMinShare = 0.05;

  /// Early in a month everything looks low.
  static const int categoryDropMinDay = 20;

  /// A category change covering this share of the month change is folded
  /// into the month insight.
  static const double explainedShare = 0.8;

  /// Weight for insights that come with an action.
  static const double actionWeight = 1.5;

  static const int maxInsights = 3;
  static const int maxRecurringSuggestions = 1;

  static const int cooldownDays = 28;

  /// A cooled-down insight comes back early if it grew by this factor.
  static const double cooldownGrowth = 1.5;

  static const int recurringMinOccurrences = 3;
  static const int yearlyMinOccurrences = 2;

  /// Allowed distance from the usual charge day (weekends, bank delays).
  static const int monthlyDayJitter = 4;

  /// Longer series tolerate the odd charge paid this far off.
  static const int monthlyMaxShift = 10;

  /// Longest step between charges, in months (skipped months).
  static const int monthlyMaxStep = 3;

  static const int weeklyDayJitter = 1;
  static const int yearlyMinGap = 360;
  static const int yearlyMaxGap = 370;

  /// Coefficient of variation allowed for a fixed-price charge.
  static const double recurringMaxVariation = 0.10;

  /// Looser variation for variable bills (utilities), only used to line up
  /// month boundaries, never suggested.
  static const double variableChargeMaxVariation = 0.5;

  /// Amounts further apart than this ratio are split into separate series.
  static const double amountClusterRatio = 1.25;

  static const double priceChangeMinRatio = 0.05;
  static const double priceChangeMinAmount = 1.0;

  /// The step must also beat this many times the charges' own wobble.
  static const double priceChangeNoiseMultiple = 3.0;

  /// Bigger jumps are more likely a different charge than a price change.
  static const double priceChangeMaxRatio = 0.5;

  /// A Flow recurring template matches a series within this amount ratio.
  static const double templateAmountTolerance = 0.25;

  static const double refundAmountTolerance = 0.01;
  static const int refundWindowDays = 60;

  static const int maxDrivers = 3;
  static const int maxEvidenceTransactions = 5;
}
