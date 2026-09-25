import "dart:collection";
import "dart:math" as math;

import "package:flow/data/insights/insight_math.dart";
import "package:flow/data/insights/insight_request.dart";
import "package:flow/data/insights/insight_thresholds.dart";

enum RecurringCadence {
  weekly(52),
  monthly(12),
  yearly(1);

  final int perYear;

  const RecurringCadence(this.perYear);
}

class RecurringOccurrence {
  final String transactionUuid;
  final DateTime date;

  /// Absolute amount, in the primary currency.
  final double amount;

  const RecurringOccurrence({
    required this.transactionUuid,
    required this.date,
    required this.amount,
  });
}

/// A charge that repeats on a steady cadence.
class RecurringSeries {
  /// `recurring:<uuid>` for Flow recurring transactions, `title:<title>`
  /// otherwise (with a `:<n>` suffix when one title holds several amounts).
  final String key;

  /// Title of the latest occurrence.
  final String? title;

  final RecurringCadence cadence;

  /// Monthly: day of month (clamped in short months). Weekly: weekday of the
  /// latest charge. Yearly: day of month of the latest charge.
  final int anchorDay;

  /// Oldest first.
  final List<RecurringOccurrence> occurrences;

  /// False for variable bills, like utilities.
  final bool isFixedPrice;

  /// Index in [occurrences] where the current price starts, if it changed.
  final int? priceChangeIndex;

  final String? categoryUuid;
  final String? accountUuid;

  /// Already set up as recurring in Flow.
  final bool isTracked;

  const RecurringSeries({
    required this.key,
    required this.title,
    required this.cadence,
    required this.anchorDay,
    required this.occurrences,
    required this.isFixedPrice,
    required this.priceChangeIndex,
    required this.categoryUuid,
    required this.accountUuid,
    required this.isTracked,
  });

  /// Median amount at the current price.
  double get typicalAmount => median(
    occurrences.skip(priceChangeIndex ?? 0).map((item) => item.amount),
  );

  /// Median amount before the price change.
  double? get previousAmount => priceChangeIndex == null
      ? null
      : median(occurrences.take(priceChangeIndex!).map((item) => item.amount));

  double get annualCost => typicalAmount * cadence.perYear;

  /// Month index of the charge [occurrence] belongs to. Monthly charges paid
  /// a few days early or late still land in their own month.
  int periodOf(RecurringOccurrence occurrence) => switch (cadence) {
    .monthly => nearestSlot(occurrence.date, anchorDay).slot,
    _ => monthIndexOf(occurrence.date),
  };
}

/// Finds repeating charges among [expenses] (negative amounts).
///
/// Charges are grouped by their Flow recurring transaction, or else by
/// [normalizeTitle]. Untitled charges are never grouped.
List<RecurringSeries> detectRecurringSeries(
  List<InsightTransaction> expenses, {
  List<InsightRecurringTemplate> templates = const [],
}) {
  final SplayTreeMap<String, List<InsightTransaction>> groups = SplayTreeMap();

  for (final InsightTransaction expense in expenses) {
    final String? title = normalizeTitle(expense.title);

    final String? key = expense.recurringUuid != null
        ? "recurring:${expense.recurringUuid}"
        : title != null
        ? "title:$title"
        : null;

    if (key == null) continue;

    (groups[key] ??= []).add(expense);
  }

  final List<RecurringSeries> result = [];

  for (final MapEntry<String, List<InsightTransaction>> group
      in groups.entries) {
    final List<InsightTransaction> items = group.value
      ..sort(_compareTransactions);

    final RecurringSeries? whole = _detect(group.key, items, templates);
    if (whole != null) {
      result.add(whole);
      continue;
    }

    final List<List<InsightTransaction>> clusters = _amountClusters(items);
    if (clusters.length < 2) continue;

    for (int i = 0; i < clusters.length; i++) {
      final RecurringSeries? series = _detect(
        "${group.key}:$i",
        clusters[i]..sort(_compareTransactions),
        templates,
      );
      if (series != null) result.add(series);
    }
  }

  return result;
}

int _compareTransactions(InsightTransaction a, InsightTransaction b) {
  final int byDate = a.date.compareTo(b.date);
  return byDate != 0 ? byDate : a.uuid.compareTo(b.uuid);
}

/// Splits a title that covers several prices, like two "Apple" plans.
List<List<InsightTransaction>> _amountClusters(List<InsightTransaction> items) {
  final List<InsightTransaction> byAmount = [...items]
    ..sort((a, b) => b.amount.compareTo(a.amount));

  final List<List<InsightTransaction>> clusters = [];

  for (final InsightTransaction item in byAmount) {
    final List<InsightTransaction>? last = clusters.lastOrNull;

    if (last != null &&
        item.amount.abs() <=
            last.last.amount.abs() * InsightThresholds.amountClusterRatio) {
      last.add(item);
    } else {
      clusters.add([item]);
    }
  }

  return clusters;
}

RecurringSeries? _detect(
  String key,
  List<InsightTransaction> items,
  List<InsightRecurringTemplate> templates,
) {
  final ({RecurringCadence cadence, int anchorDay})? rhythm =
      _monthly(items) ?? _weekly(items) ?? _yearly(items);

  if (rhythm == null) return null;

  final List<double> amounts = items.map((item) => item.amount.abs()).toList();

  final ({bool isFixedPrice, int? priceChangeIndex})? price = _price(
    amounts,
    rhythm.cadence,
  );

  if (price == null) return null;

  final List<RecurringOccurrence> occurrences = items
      .map(
        (item) => RecurringOccurrence(
          transactionUuid: item.uuid,
          date: item.date,
          amount: item.amount.abs(),
        ),
      )
      .toList();

  final double typicalAmount = median(
    amounts.skip(price.priceChangeIndex ?? 0),
  );

  return RecurringSeries(
    key: key,
    title: items.last.title,
    cadence: rhythm.cadence,
    anchorDay: rhythm.anchorDay,
    occurrences: occurrences,
    isFixedPrice: price.isFixedPrice,
    priceChangeIndex: price.priceChangeIndex,
    categoryUuid: _mostCommon(items.map((item) => item.categoryUuid)),
    accountUuid: _mostCommon(items.map((item) => item.accountUuid)),
    isTracked:
        key.startsWith("recurring:") ||
        _matchesTemplate(items.last.title, [
          typicalAmount,
          amounts.last,
        ], templates),
  );
}

/// Same calendar day each month, give or take a few days, with at most a
/// couple of skipped months. Short months clamp the day (31st -> Feb 28th).
({RecurringCadence cadence, int anchorDay})? _monthly(
  List<InsightTransaction> items,
) {
  if (items.length < InsightThresholds.recurringMinOccurrences) return null;

  ({int anchorDay, int outliers, int total, int worst})? best;

  for (int anchorDay = 1; anchorDay <= 31; anchorDay++) {
    int outliers = 0;
    int total = 0;
    int worst = 0;

    for (final InsightTransaction item in items) {
      final int offset = nearestSlot(item.date, anchorDay).offset.abs();
      if (offset > InsightThresholds.monthlyDayJitter) outliers++;
      total += offset;
      worst = math.max(worst, offset);
    }

    if (best == null ||
        outliers < best.outliers ||
        (outliers == best.outliers && total < best.total)) {
      best = (
        anchorDay: anchorDay,
        outliers: outliers,
        total: total,
        worst: worst,
      );
    }
  }

  // A long series may have the odd charge paid well early or late.
  final int allowedOutliers = math.min(
    math.max(1, items.length ~/ 5),
    items.length - InsightThresholds.recurringMinOccurrences,
  );

  if (best!.outliers > allowedOutliers ||
      best.worst > InsightThresholds.monthlyMaxShift) {
    return null;
  }

  final List<int> slots = items
      .map((item) => nearestSlot(item.date, best!.anchorDay).slot)
      .toList();

  int consecutive = 0;

  for (int i = 1; i < slots.length; i++) {
    final int step = slots[i] - slots[i - 1];

    if (step < 1 || step > InsightThresholds.monthlyMaxStep) return null;
    if (step == 1) consecutive++;
  }

  // Mostly month after month, so every-other-month charges don't qualify.
  if (consecutive * 2 < slots.length - 1) return null;

  return (cadence: .monthly, anchorDay: best.anchorDay);
}

({RecurringCadence cadence, int anchorDay})? _weekly(
  List<InsightTransaction> items,
) {
  if (items.length < InsightThresholds.recurringMinOccurrences) return null;

  int consecutive = 0;

  for (int i = 1; i < items.length; i++) {
    final int gap = dayDifference(items[i - 1].date, items[i].date);
    final int weeks = (gap / 7).round();

    if (weeks < 1 || weeks > 2) return null;
    if ((gap - weeks * 7).abs() > InsightThresholds.weeklyDayJitter) {
      return null;
    }
    if (weeks == 1) consecutive++;
  }

  if (consecutive * 2 < items.length - 1) return null;

  return (cadence: .weekly, anchorDay: items.last.date.weekday);
}

({RecurringCadence cadence, int anchorDay})? _yearly(
  List<InsightTransaction> items,
) {
  if (items.length < InsightThresholds.yearlyMinOccurrences) return null;

  for (int i = 1; i < items.length; i++) {
    final int gap = dayDifference(items[i - 1].date, items[i].date);

    if (gap < InsightThresholds.yearlyMinGap ||
        gap > InsightThresholds.yearlyMaxGap) {
      return null;
    }
  }

  return (cadence: .yearly, anchorDay: items.last.date.day);
}

/// A fixed price, a fixed price with one change, or (monthly only) a
/// variable bill. Null when amounts are all over the place.
({bool isFixedPrice, int? priceChangeIndex})? _price(
  List<double> amounts,
  RecurringCadence cadence,
) {
  // Two yearly charges can't tell a price change from two different things.
  if (amounts.length >= InsightThresholds.recurringMinOccurrences) {
    for (int split = amounts.length - 1; split >= 1; split--) {
      if (_isPriceChange(amounts.sublist(0, split), amounts.sublist(split))) {
        return (isFixedPrice: true, priceChangeIndex: split);
      }
    }
  }

  final double variation = coefficientOfVariation(amounts);

  if (variation <= InsightThresholds.recurringMaxVariation) {
    return (isFixedPrice: true, priceChangeIndex: null);
  }

  if (cadence == .monthly &&
      variation <= InsightThresholds.variableChargeMaxVariation) {
    return (isFixedPrice: false, priceChangeIndex: null);
  }

  return null;
}

/// Both sides steady, and the step clearly bigger than their wobble (a
/// charge converted from another currency moves a little every month).
bool _isPriceChange(List<double> before, List<double> after) {
  final double noise = math.max(
    coefficientOfVariation(before),
    coefficientOfVariation(after),
  );

  if (noise > InsightThresholds.recurringMaxVariation) return false;

  final double previous = median(before);
  final double change = (median(after) - previous).abs();

  if (previous <= 0.0) return false;

  final double ratio = change / previous;

  return change >= InsightThresholds.priceChangeMinAmount &&
      ratio >=
          math.max(
            InsightThresholds.priceChangeMinRatio,
            noise * InsightThresholds.priceChangeNoiseMultiple,
          ) &&
      ratio <= InsightThresholds.priceChangeMaxRatio;
}

/// Title matches and either amount is close to the template's.
bool _matchesTemplate(
  String? seriesTitle,
  List<double> amounts,
  List<InsightRecurringTemplate> templates,
) {
  final String? title = normalizeTitle(seriesTitle);
  if (title == null) return false;

  return templates.any((template) {
    if (normalizeTitle(template.title) != title) return false;

    final double amount = template.amount.abs();
    final double tolerance = amount * InsightThresholds.templateAmountTolerance;

    return amounts.any((value) => (value - amount).abs() <= tolerance);
  });
}

/// Ties go to the most recent value.
String? _mostCommon(Iterable<String?> values) {
  final List<String?> list = values.toList();
  final Map<String?, int> counts = {};

  for (final String? value in list) {
    counts[value] = (counts[value] ?? 0) + 1;
  }

  String? result;
  int bestCount = 0;

  for (final String? value in list.reversed) {
    if (counts[value]! > bestCount) {
      bestCount = counts[value]!;
      result = value;
    }
  }

  return result;
}
