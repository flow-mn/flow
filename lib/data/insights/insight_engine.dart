import "dart:math" as math;

import "package:flow/data/insights/insight.dart";
import "package:flow/data/insights/insight_math.dart";
import "package:flow/data/insights/insight_request.dart";
import "package:flow/data/insights/insight_thresholds.dart";

export "package:flow/data/insights/insight.dart";
export "package:flow/data/insights/insight_request.dart";

/// Entry point for `compute()`.
InsightReport computeInsights(InsightRequest request) =>
    InsightEngine(request).run();

class _Expense {
  final InsightTransaction source;
  final double amount;

  /// Month index this expense is compared in. Differs from the calendar
  /// month only for monthly charges paid a few days early or late.
  int bucket;

  /// Set for members of a monthly series.
  RecurringSeries? monthlySeries;

  /// A yearly charge that happened before, so not unusual.
  bool isYearlyRepeat = false;

  _Expense(this.source)
    : amount = source.amount.abs(),
      bucket = monthIndexOf(source.date);

  String get uuid => source.uuid;
  String? get categoryUuid => source.categoryUuid;

  /// A fixed monthly charge or a yearly one seen before. Usual by
  /// definition, so it never explains an unusual month.
  bool get isRoutine =>
      (monthlySeries?.isFixedPrice ?? false) || isYearlyRepeat;
}

/// Local, deterministic spending insights for one month.
///
/// Baselines are medians over the last [InsightThresholds.baselineMonths]
/// complete months, so one big purchase doesn't move what counts as usual. A
/// month in progress is compared with the same point of earlier months.
class InsightEngine {
  final InsightRequest request;

  InsightEngine(this.request);

  late final int _month = monthIndexOf(request.month);
  late final bool _inProgress = _month == monthIndexOf(request.now);
  late final int? _throughDay = _inProgress ? request.now.day : null;

  /// Nothing at or after this is considered.
  late final DateTime _cutoff = _inProgress
      ? DateTime(request.now.year, request.now.month, request.now.day + 1)
      : monthStartOf(_month + 1);

  late final List<int> _baseline = [
    for (int i = InsightThresholds.baselineMonths; i >= 1; i--) _month - i,
  ];

  final Map<int, List<_Expense>> _buckets = {};
  List<RecurringSeries> _series = const [];

  /// Monthly series already charged for the analyzed month.
  final Set<String> _includedSeries = {};

  /// Monthly series expected later in the analyzed month.
  final Set<String> _deferredSeries = {};

  List<int> _active = const [];
  double _usualTotal = 0.0;
  double _floor = 0.0;

  InsightReport run() {
    if (_month > monthIndexOf(request.now)) {
      return _report(.futureMonth, const []);
    }

    _prepare();

    _active = _baseline
        .where(
          (month) =>
              _full(month).length >= InsightThresholds.minExpensesPerMonth,
        )
        .toList();

    if (_active.length < InsightThresholds.minActiveMonths) {
      return _report(.notEnoughHistory, const []);
    }

    _usualTotal = median(_active.map((month) => _sum(_full(month))));

    if (_usualTotal <= 0.0) {
      return _report(.notEnoughHistory, const []);
    }

    final double medianExpense = median(
      _active.expand(_full).map((expense) => expense.amount),
    );

    _floor = math.max(
      _usualTotal * InsightThresholds.materialityShare,
      medianExpense * InsightThresholds.materialityMedianMultiple,
    );

    final bool tooEarly =
        _inProgress && _throughDay! < InsightThresholds.minDayOfMonth;

    final List<Insight> candidates = [
      if (!tooEarly) ...[
        ?_monthPace(),
        ..._categorySpikes(),
        ..._categoryDrops(),
        ..._newCategories(),
      ],
      // Suggesting to track a charge only helps while the month is current.
      if (_inProgress) ..._recurringCharges(),
      ..._priceChanges(),
    ];

    return _report(
      tooEarly ? .tooEarly : .ready,
      _rank(
        candidates
            .where((insight) => !request.hiddenTypes.contains(insight.type))
            .toList(),
      ),
    );
  }

  InsightReport _report(InsightReportStatus status, List<Insight> insights) =>
      InsightReport(
        month: monthStartOf(_month),
        status: status,
        insights: insights,
        usualMonthTotal: _usualTotal > 0.0 ? _usualTotal : null,
        throughDay: _throughDay,
        hasMissingRates: request.hasMissingRates,
      );

  void _prepare() {
    final List<InsightTransaction> valid =
        request.transactions
            .where(
              (transaction) =>
                  !transaction.isTransfer &&
                  !transaction.isPending &&
                  transaction.amount.isFinite &&
                  transaction.amount != 0.0 &&
                  transaction.date.isBefore(_cutoff),
            )
            .toList()
          ..sort((a, b) {
            final int byDate = a.date.compareTo(b.date);
            return byDate != 0 ? byDate : a.uuid.compareTo(b.uuid);
          });

    final Set<String> refunded = _matchRefunds(valid);

    final List<_Expense> expenses = valid
        .where(
          (transaction) =>
              transaction.amount < 0.0 && !refunded.contains(transaction.uuid),
        )
        .map(_Expense.new)
        .toList();

    _series = detectRecurringSeries(
      expenses.map((expense) => expense.source).toList(),
      templates: request.recurringTemplates,
    );

    final Map<String, _Expense> byUuid = {
      for (final _Expense expense in expenses) expense.uuid: expense,
    };

    for (final RecurringSeries series in _series) {
      for (int i = 0; i < series.occurrences.length; i++) {
        final RecurringOccurrence occurrence = series.occurrences[i];
        final _Expense expense = byUuid[occurrence.transactionUuid]!;

        switch (series.cadence) {
          case .monthly:
            expense.monthlySeries = series;
            expense.bucket = series.periodOf(occurrence);
          case .yearly:
            expense.isYearlyRepeat = i > 0;
          case .weekly:
            break;
        }
      }
    }

    for (final _Expense expense in expenses) {
      (_buckets[expense.bucket] ??= []).add(expense);
    }

    if (_inProgress) _splitSeriesByTiming();
  }

  /// Pairs a positive transaction with an earlier expense of the same amount
  /// and title (or category), so a returned purchase isn't counted as spend.
  Set<String> _matchRefunds(List<InsightTransaction> valid) {
    final Map<String, List<InsightTransaction>> expensesByKey = {};

    for (final InsightTransaction transaction in valid) {
      if (transaction.amount >= 0.0) continue;

      final String? key = _refundKey(transaction);
      if (key != null) (expensesByKey[key] ??= []).add(transaction);
    }

    final Set<String> matched = {};

    for (final InsightTransaction refund in valid) {
      if (refund.amount <= 0.0) continue;

      final String? key = _refundKey(refund);
      final List<InsightTransaction>? candidates = expensesByKey[key];
      if (candidates == null) continue;

      for (final InsightTransaction expense in candidates.reversed) {
        if (matched.contains(expense.uuid)) continue;
        if (expense.date.isAfter(refund.date)) continue;
        if (dayDifference(expense.date, refund.date) >
            InsightThresholds.refundWindowDays) {
          break;
        }

        final double difference = (expense.amount.abs() - refund.amount).abs();
        if (difference <=
            refund.amount * InsightThresholds.refundAmountTolerance) {
          matched
            ..add(expense.uuid)
            ..add(refund.uuid);
          break;
        }
      }
    }

    return matched;
  }

  String? _refundKey(InsightTransaction transaction) {
    final String? title = normalizeTitle(transaction.title);
    if (title != null) return "title:$title";

    final String? category = transaction.categoryUuid;
    return category == null ? null : "category:$category";
  }

  /// For a month in progress, a monthly charge that already happened is
  /// compared in full against earlier months, and one still to come is left
  /// out of both sides. Rent paid on the 20th instead of the 28th is then
  /// not "spending more".
  void _splitSeriesByTiming() {
    for (final RecurringSeries series in _series) {
      if (series.cadence != .monthly) continue;

      final List<int> periods = series.occurrences
          .map(series.periodOf)
          .toList();

      if (periods.contains(_month)) {
        _includedSeries.add(series.key);
      } else if (periods.last >= _month - 2 &&
          chargeDayOf(_month, series.anchorDay).day > _throughDay!) {
        _deferredSeries.add(series.key);
      }
    }
  }

  List<_Expense> _full(int month) => _buckets[month] ?? const [];

  /// [_full], cut to the same day of month as the analyzed month.
  Iterable<_Expense> _comparable(int month) =>
      _full(month).where((expense) => _counts(expense, month));

  bool _counts(_Expense expense, int month) {
    if (!_inProgress || month == _month) return true;

    final RecurringSeries? series = expense.monthlySeries;

    if (series != null) {
      if (_includedSeries.contains(series.key)) return true;
      if (_deferredSeries.contains(series.key)) return false;
    }

    return _dayInBucket(expense) <= math.min(_throughDay!, daysInMonth(month));
  }

  int _dayInBucket(_Expense expense) {
    final int calendarMonth = monthIndexOf(expense.source.date);

    if (calendarMonth < expense.bucket) return 1;
    if (calendarMonth > expense.bucket) return 31;
    return expense.source.date.day;
  }

  double _sum(Iterable<_Expense> expenses) =>
      expenses.fold(0.0, (total, expense) => total + expense.amount);

  Iterable<_Expense> _inCategory(Iterable<_Expense> expenses, String? uuid) =>
      expenses.where((expense) => expense.categoryUuid == uuid);

  List<_Expense> _biggestFirst(Iterable<_Expense> expenses) =>
      expenses.toList()..sort((a, b) {
        final int byAmount = b.amount.compareTo(a.amount);
        return byAmount != 0 ? byAmount : a.uuid.compareTo(b.uuid);
      });

  List<String> _evidence(Iterable<_Expense> expenses) => _biggestFirst(expenses)
      .take(InsightThresholds.maxEvidenceTransactions)
      .map((expense) => expense.uuid)
      .toList();

  /// The biggest unusual expense, when it covers most of [delta].
  InsightAttribution? _attribute(Iterable<_Expense> expenses, double delta) {
    final _Expense? biggest = _biggestFirst(
      expenses.where((expense) => !expense.isRoutine),
    ).firstOrNull;

    if (biggest == null ||
        biggest.amount < delta * InsightThresholds.attributionShare) {
      return null;
    }

    return InsightAttribution(
      transactionUuid: biggest.uuid,
      title: biggest.source.title,
      categoryUuid: biggest.categoryUuid,
      date: biggest.source.date,
      amount: biggest.amount,
    );
  }

  /// A yearly charge that was paid last year too shouldn't make a month
  /// look unusual.
  bool _survivesYearlyRepeats(
    Iterable<_Expense> current,
    double usual,
    double ratio,
  ) {
    final double withoutRepeats = _sum(
      current.where((expense) => !expense.isYearlyRepeat),
    );

    return withoutRepeats >= usual * ratio && withoutRepeats - usual >= _floor;
  }

  List<InsightMonthValue> _history(double Function(int month) value) => [
    for (final int month in _baseline)
      InsightMonthValue(
        month: monthStartOf(month),
        amount: value(month),
        counted: _active.contains(month),
      ),
  ];

  Set<String?> _categories(Iterable<int> months, {bool comparable = false}) => {
    for (final int month in months)
      for (final _Expense expense
          in comparable ? _comparable(month) : _full(month))
        expense.categoryUuid,
  };

  double _score(double stake, {double weight = 1.0}) =>
      stake / _usualTotal * weight;

  MonthPaceInsight? _monthPace() {
    final List<_Expense> current = _comparable(_month).toList();
    final double currentTotal = _sum(current);
    final double usual = median(
      _active.map((month) => _sum(_comparable(month))),
    );

    if (usual <= 0.0) return null;

    final double ratio = currentTotal / usual;
    final double delta = currentTotal - usual;

    final InsightDirection? direction =
        ratio >= InsightThresholds.monthAboveRatio
        ? .above
        : ratio <= InsightThresholds.monthBelowRatio
        ? .below
        : null;

    if (direction == null || delta.abs() < _floor) return null;

    if (direction == .above &&
        !_survivesYearlyRepeats(
          current,
          usual,
          InsightThresholds.monthAboveRatio,
        )) {
      return null;
    }

    return MonthPaceInsight(
      score: _score(delta.abs()),
      direction: direction,
      current: currentTotal,
      usual: usual,
      throughDay: _throughDay,
      history: _history((month) => _sum(_comparable(month))),
      attribution: direction == .above ? _attribute(current, delta) : null,
      drivers: _drivers(direction),
      transactionUuids: _evidence(current),
    );
  }

  List<InsightCategoryDelta> _drivers(InsightDirection direction) {
    final List<InsightCategoryDelta> drivers = [];

    for (final String? category in _categories([
      _month,
      ..._active,
    ], comparable: true)) {
      final double current = _sum(_inCategory(_comparable(_month), category));
      final double usual = median(
        _active.map((month) => _sum(_inCategory(_comparable(month), category))),
      );

      final InsightCategoryDelta driver = InsightCategoryDelta(
        categoryUuid: category,
        current: current,
        usual: usual,
      );

      if (direction == .above ? driver.delta > 0.0 : driver.delta < 0.0) {
        drivers.add(driver);
      }
    }

    drivers.sort((a, b) {
      final int byDelta = b.delta.abs().compareTo(a.delta.abs());
      return byDelta != 0
          ? byDelta
          : (a.categoryUuid ?? "").compareTo(b.categoryUuid ?? "");
    });

    return drivers.take(InsightThresholds.maxDrivers).toList();
  }

  List<CategorySpikeInsight> _categorySpikes() {
    final List<CategorySpikeInsight> spikes = [];

    for (final String? category in _categories([_month])) {
      if (category == null) continue;

      final List<_Expense> current = _inCategory(
        _full(_month),
        category,
      ).toList();

      if (current.length < InsightThresholds.categorySpikeMinEntries) continue;

      final List<double> present = _active
          .map((month) => _sum(_inCategory(_full(month), category)))
          .where((total) => total > 0.0)
          .toList();

      if (present.length < InsightThresholds.categoryMinMonthsPresent) {
        continue;
      }

      // Months without this category don't drag its usual down.
      final double usual = median(present);
      final double currentTotal = _sum(current);
      final double delta = currentTotal - usual;

      if (currentTotal < usual * InsightThresholds.categorySpikeRatio ||
          delta < _floor ||
          !_survivesYearlyRepeats(
            current,
            usual,
            InsightThresholds.categorySpikeRatio,
          )) {
        continue;
      }

      spikes.add(
        CategorySpikeInsight(
          score: _score(delta),
          categoryUuid: category,
          current: currentTotal,
          usual: usual,
          entryCount: current.length,
          history: _history(
            (month) => _sum(_inCategory(_full(month), category)),
          ),
          attribution: _attribute(current, delta),
          transactionUuids: _evidence(current),
        ),
      );
    }

    return spikes;
  }

  List<CategoryDropInsight> _categoryDrops() {
    if (_inProgress && _throughDay! < InsightThresholds.categoryDropMinDay) {
      return const [];
    }

    final List<CategoryDropInsight> drops = [];

    for (final String? category in _categories(_active)) {
      if (category == null) continue;

      final List<double> fullTotals = _active
          .map((month) => _sum(_inCategory(_full(month), category)))
          .toList();

      final int present = fullTotals.where((total) => total > 0.0).length;

      // Only categories that show up nearly every month can "drop".
      if (present <
          math.max(
            InsightThresholds.categoryMinMonthsPresent,
            _active.length - 1,
          )) {
        continue;
      }

      if (median(fullTotals) <
          _usualTotal * InsightThresholds.categoryDropMinShare) {
        continue;
      }

      final List<_Expense> current = _inCategory(
        _comparable(_month),
        category,
      ).toList();
      final double currentTotal = _sum(current);
      final double usual = median(
        _active.map((month) => _sum(_inCategory(_comparable(month), category))),
      );

      if (usual <= 0.0 ||
          currentTotal > usual * InsightThresholds.categoryDropRatio ||
          usual - currentTotal < _floor) {
        continue;
      }

      drops.add(
        CategoryDropInsight(
          score: _score(usual - currentTotal),
          categoryUuid: category,
          current: currentTotal,
          usual: usual,
          throughDay: _throughDay,
          history: _history(
            (month) => _sum(_inCategory(_comparable(month), category)),
          ),
          transactionUuids: _evidence(current),
        ),
      );
    }

    return drops;
  }

  List<NewCategoryInsight> _newCategories() {
    final Set<String?> seen = _categories(_baseline);
    final List<NewCategoryInsight> result = [];

    for (final String? category in _categories([_month])) {
      if (category == null || seen.contains(category)) continue;

      final List<_Expense> current = _inCategory(
        _full(_month),
        category,
      ).toList();
      final double total = _sum(
        current.where((expense) => !expense.isYearlyRepeat),
      );

      if (total < _floor) continue;

      result.add(
        NewCategoryInsight(
          score: _score(total),
          categoryUuid: category,
          current: _sum(current),
          entryCount: current.length,
          transactionUuids: _evidence(current),
        ),
      );
    }

    return result;
  }

  bool _chargedThisMonth(RecurringSeries series) =>
      series.periodOf(series.occurrences.last) == _month;

  /// Needs two charges at the old price, so a one-off discount isn't a change.
  bool _changedPriceThisMonth(RecurringSeries series) =>
      series.isFixedPrice &&
      series.priceChangeIndex == series.occurrences.length - 1 &&
      series.priceChangeIndex! >= 2 &&
      _chargedThisMonth(series);

  List<RecurringChargeInsight> _recurringCharges() => [
    for (final RecurringSeries series in _series)
      // A price change says more this month; the suggestion can wait.
      if (series.isFixedPrice &&
          !series.isTracked &&
          _chargedThisMonth(series) &&
          !_changedPriceThisMonth(series) &&
          series.annualCost >= _floor)
        RecurringChargeInsight(
          score: _score(
            series.annualCost,
            weight: InsightThresholds.actionWeight,
          ),
          series: series,
        ),
  ];

  List<PriceChangeInsight> _priceChanges() => [
    for (final RecurringSeries series in _series)
      if (_changedPriceThisMonth(series))
        PriceChangeInsight(
          score: _score(
            (series.typicalAmount - series.previousAmount!).abs() *
                series.cadence.perYear,
          ),
          series: series,
          previousAmount: series.previousAmount!,
          currentAmount: series.typicalAmount,
        ),
  ];

  bool _isCoolingDown(Insight insight) {
    if (!_inProgress) return false;

    final DateTime monthStart = monthStartOf(_month);

    // Cooldown only across months; within a month the card stays stable.
    return request.sightings.any(
      (sighting) =>
          sighting.key == insight.key &&
          sighting.shownAt.isBefore(monthStart) &&
          dayDifference(sighting.shownAt, request.now) <
              InsightThresholds.cooldownDays &&
          insight.stake < sighting.stake * InsightThresholds.cooldownGrowth,
    );
  }

  List<Insight> _rank(List<Insight> candidates) {
    final List<Insight> sorted = candidates.toList()
      ..sort((a, b) {
        final int byScore = b.score.compareTo(a.score);
        if (byScore != 0) return byScore;

        final int byType = a.type.index.compareTo(b.type.index);
        return byType != 0 ? byType : a.key.compareTo(b.key);
      });

    // A cooling-down month insight still covers what it explains.
    final MonthPaceInsight? pace = sorted
        .whereType<MonthPaceInsight>()
        .firstOrNull;

    final List<Insight> result = [];
    int spikes = 0;
    int suggestions = 0;

    for (final Insight insight in sorted) {
      if (result.length >= request.limit) break;
      if (_isCoolingDown(insight)) continue;
      if (pace != null && _explains(pace, insight)) continue;

      switch (insight) {
        case CategorySpikeInsight():
          if (++spikes > InsightThresholds.maxCategorySpikes) continue;
        case RecurringChargeInsight():
          if (++suggestions > InsightThresholds.maxRecurringSuggestions) {
            continue;
          }
        default:
          break;
      }

      result.add(insight);
    }

    return result;
  }

  /// Whether [insight] mostly repeats what [pace] already says.
  bool _explains(MonthPaceInsight pace, Insight insight) {
    final bool sameDirection = switch (insight) {
      CategorySpikeInsight() ||
      NewCategoryInsight() => pace.direction == .above,
      CategoryDropInsight() => pace.direction == .below,
      _ => false,
    };

    if (!sameDirection) return false;

    final String? attributed = pace.attribution?.transactionUuid;

    return insight.stake >= pace.stake * InsightThresholds.explainedShare ||
        (attributed != null &&
            insight.transactionUuids.firstOrNull == attributed);
  }
}
