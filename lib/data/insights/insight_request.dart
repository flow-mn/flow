import "package:flow/data/insights/insight.dart";
import "package:flow/data/insights/insight_thresholds.dart";

/// A transaction as the insight engine sees it. Plain data, safe to send to
/// another isolate.
class InsightTransaction {
  final String uuid;

  /// Local time.
  final DateTime date;

  /// In the primary currency. Negative for expenses.
  final double amount;

  final String? title;
  final String? categoryUuid;
  final String? accountUuid;

  final bool isTransfer;
  final bool isPending;

  /// Uuid of the Flow recurring transaction that created this, if any.
  final String? recurringUuid;

  const InsightTransaction({
    required this.uuid,
    required this.date,
    required this.amount,
    this.title,
    this.categoryUuid,
    this.accountUuid,
    this.isTransfer = false,
    this.isPending = false,
    this.recurringUuid,
  });
}

/// A recurring transaction the user already set up in Flow.
class InsightRecurringTemplate {
  final String? title;

  /// Absolute amount, in the primary currency.
  final double amount;

  const InsightRecurringTemplate({required this.title, required this.amount});
}

/// An insight the UI has shown before, used for the cooldown.
class InsightSighting {
  /// [Insight.key]
  final String key;
  final DateTime shownAt;

  /// [Insight.stake] at the time it was shown.
  final double stake;

  const InsightSighting({
    required this.key,
    required this.shownAt,
    required this.stake,
  });
}

class InsightRequest {
  /// Everything available up to [now]. Pass at least 7 months; recurring
  /// detection benefits from more (yearly charges need two years).
  final List<InsightTransaction> transactions;

  /// Any moment within the month to analyze.
  final DateTime month;

  final DateTime now;

  final List<InsightRecurringTemplate> recurringTemplates;

  /// Types the user chose not to see.
  final Set<InsightType> hiddenTypes;

  final List<InsightSighting> sightings;

  final int limit;

  /// Passed through to [InsightReport.hasMissingRates].
  final bool hasMissingRates;

  const InsightRequest({
    required this.transactions,
    required this.month,
    required this.now,
    this.recurringTemplates = const [],
    this.hiddenTypes = const {},
    this.sightings = const [],
    this.limit = InsightThresholds.maxInsights,
    this.hasMissingRates = false,
  });
}

enum InsightReportStatus {
  ready,

  /// Before [InsightThresholds.minDayOfMonth]; only recurring charge
  /// insights can appear.
  tooEarly,

  /// Fewer than [InsightThresholds.minActiveMonths] usable baseline months.
  notEnoughHistory,

  futureMonth,
}

class InsightReport {
  /// First day of the analyzed month.
  final DateTime month;

  final InsightReportStatus status;

  /// Ranked by money at stake, at most [InsightRequest.limit].
  final List<Insight> insights;

  /// Median spend of a complete baseline month. Null without enough history.
  final double? usualMonthTotal;

  /// Day of month the comparisons run through. Null for a complete month.
  final int? throughDay;

  final bool hasMissingRates;

  const InsightReport({
    required this.month,
    required this.status,
    required this.insights,
    this.usualMonthTotal,
    this.throughDay,
    this.hasMissingRates = false,
  });

  bool get isInProgress => throughDay != null;
}
