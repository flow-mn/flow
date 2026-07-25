import "package:flow/data/money.dart";
import "package:flow/entity/budget.dart";
import "package:moment_dart/moment_dart.dart";

/// How a budget is tracking against its limit, as a coarse three-way status.
enum BudgetStatus {
  /// Under the warning threshold.
  healthy,

  /// At or past the warning threshold, but not yet over the limit.
  warning,

  /// Spending has reached or exceeded the budgeted amount.
  over,
}

/// Whether the current spend rate projects to land under, on, or over the
/// limit by the end of the period.
enum BudgetPace { under, on, over }

/// The single most relevant rule-based takeaway for a budget. The UI maps
/// each value to a localized sentence (see `budget.insight.*`).
enum BudgetInsightType {
  /// Already over the limit.
  over,

  /// Close to the limit ([BudgetStatus.warning]) but not over.
  nearingLimit,

  /// Healthy now, but the current pace projects an overrun.
  overpacing,

  /// Comfortably on track.
  onTrack,

  /// Well under the limit with much of the period elapsed.
  underspending,
}

/// A pure, point-in-time view of how a [Budget] is tracking against its limit
/// over one period.
///
/// All money is expressed in the budget's own [Budget.currency]. Construct via
/// `BudgetService.computeProgress` rather than directly.
class BudgetProgress {
  final Budget budget;

  /// The period this progress covers.
  ///
  /// Deliberately explicit rather than read off [budget]: [Budget.range] is a
  /// non-moving *anchor*, and a budget has as many periods as you care to page
  /// to (see `BudgetService.currentPeriod`). This is whichever one was measured
  /// — usually the live period, but any past period computes the same way.
  final TimeRange range;

  /// Absolute spend within the period, in [Budget.currency].
  final Money spent;

  /// The budgeted amount, in [Budget.currency].
  final Money limit;

  /// True when a foreign-currency transaction couldn't be converted, so
  /// [spent] is an undercount.
  final bool hasMissingData;

  /// The moment this snapshot was computed against.
  final DateTime asOf;

  const BudgetProgress({
    required this.budget,
    required this.range,
    required this.spent,
    required this.limit,
    required this.asOf,
    this.hasMissingData = false,
  });

  /// The budget's currency, shared by [spent] and [limit].
  String get currency => limit.currency;

  /// Spent / limit. `0` when the limit is non-positive.
  double get ratio => limit.amount > 0 ? (spent.amount / limit.amount) : 0.0;

  /// [ratio] as a whole-number percentage, e.g. `92`.
  int get percent => (ratio * 100).round();

  /// Remaining headroom; negative once over budget.
  Money get remaining => limit - spent;

  /// How far over the limit, clamped to non-negative.
  Money get overBy {
    final Money diff = spent - limit;
    return diff.amount > 0 ? diff : Money(0.0, currency);
  }

  /// Fraction of [range] that has elapsed at [asOf], clamped to 0..1. A period
  /// entirely in the past reads as `1`.
  double get periodElapsed {
    final int total = range.to.difference(range.from).inSeconds;
    if (total <= 0) return 1.0;
    final int elapsed = asOf.difference(range.from).inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  /// Whole days remaining in [range]; `0` once it has ended.
  int get daysLeft {
    final DateTime to = range.to;
    if (!to.isAfter(asOf)) return 0;
    return to.difference(asOf).inDays;
  }

  /// Extrapolated end-of-period ratio if spending continues at the current
  /// rate. Falls back to [ratio] before any of the period has elapsed.
  double get projectedRatio {
    final double elapsed = periodElapsed;
    if (elapsed <= 0.0) return ratio;
    return ratio / elapsed;
  }

  BudgetStatus get status {
    if (ratio >= 1.0) return BudgetStatus.over;
    if (ratio >= warningThreshold) return BudgetStatus.warning;
    return BudgetStatus.healthy;
  }

  BudgetPace get pace {
    final double projected = projectedRatio;
    if (projected > 1.05) return BudgetPace.over;
    if (projected < 0.75) return BudgetPace.under;
    return BudgetPace.on;
  }

  /// Whether [range] includes [asOf] — i.e. this is the live period rather
  /// than a past one being inspected.
  bool get isCurrent => range.contains(asOf);

  /// True when the budget warrants a nudge: at/over the warning threshold in
  /// its live period.
  bool get needsAttention => isCurrent && status != BudgetStatus.healthy;

  /// The single most relevant rule-based takeaway.
  BudgetInsightType get primaryInsight {
    switch (status) {
      case BudgetStatus.over:
        return BudgetInsightType.over;
      case BudgetStatus.warning:
        return BudgetInsightType.nearingLimit;
      case BudgetStatus.healthy:
        // Require enough of the period to have elapsed before projecting an
        // overrun — early on, a small spend extrapolates to a wildly
        // overstated (and alarming) projection.
        if (isCurrent && periodElapsed > 0.2 && pace == BudgetPace.over) {
          return BudgetInsightType.overpacing;
        }
        if (periodElapsed > 0.5 && pace == BudgetPace.under) {
          return BudgetInsightType.underspending;
        }
        return BudgetInsightType.onTrack;
    }
  }

  /// Sorting weight — higher means more in need of attention. Over-budget
  /// outranks warning outranks healthy; ties break by [ratio].
  double get severity => switch (status) {
    BudgetStatus.over => 2.0 + ratio,
    BudgetStatus.warning => 1.0 + ratio,
    BudgetStatus.healthy => ratio,
  };

  /// The [ratio] at or above which a budget is considered "near" its limit.
  static const double warningThreshold = 0.9;
}

/// A status roll-up across several current [BudgetProgress]es: how many are
/// over or nearing their limit, and which one is worst.
///
/// Deliberately carries **no summed money total**. Flow's budgets are
/// independent — they can overlap in categories (an "all spending" budget plus
/// category sub-budgets counts the same transaction twice) and span different
/// periods (a monthly grocery budget next to a yearly travel one). Summing
/// their spends and limits would double-count and mix timeframes, producing a
/// misleading number, so this is a count/status view instead. Construct via
/// `BudgetService.computeSummary`.
class BudgetsSummary {
  final int budgetCount;
  final int overCount;
  final int warningCount;

  /// The most in-need-of-attention budget (highest [BudgetProgress.severity]),
  /// or null when there are no budgets.
  final BudgetProgress? worst;

  /// True when at least one budget had unconvertible foreign spend, so its
  /// status may understate reality.
  final bool hasMissingData;

  const BudgetsSummary({
    required this.budgetCount,
    required this.overCount,
    required this.warningCount,
    this.worst,
    this.hasMissingData = false,
  });

  /// No budget is over or nearing its limit.
  bool get allHealthy => overCount == 0 && warningCount == 0;

  bool get isEmpty => budgetCount == 0;
}
