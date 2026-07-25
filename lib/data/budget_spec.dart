import "dart:typed_data";

import "package:flow/data/exchange_rates.dart";

/// Everything the spend computation needs about one budget, as plain data.
///
/// Deliberately not the `Budget` entity: an entity carries a `ToMany<Category>`
/// bound to whichever ObjectBox store materialized it, and that is exactly the
/// kind of thing that must not cross an isolate boundary. Resolving the
/// relation to a list of uuids on the main isolate keeps the entity graph where
/// it belongs.
class BudgetSpec {
  /// Caller-chosen key for matching the result back to what was asked.
  ///
  /// `computeAllProgressAsync` uses `Budget.id` (one spec per budget);
  /// `computeHistoryAsync` uses the period's index (many specs, one budget).
  final int correlationId;

  final String currency;

  /// Empty means "count every expense".
  final List<String> categoryUuids;

  /// The resolved period — already derived by `BudgetService.currentPeriod`, so
  /// the isolate never has to reason about anchors or renewal.
  final DateTime from;
  final DateTime to;

  const BudgetSpec({
    required this.correlationId,
    required this.currency,
    required this.categoryUuids,
    required this.from,
    required this.to,
  });
}

/// What the isolate hands back for one [BudgetSpec].
class BudgetSpend {
  final int correlationId;

  /// Absolute spend over the period, in the spec's currency.
  final double spent;

  /// A foreign-currency transaction couldn't be converted, so [spent] is an
  /// undercount.
  final bool hasMissingData;

  const BudgetSpend({
    required this.correlationId,
    required this.spent,
    required this.hasMissingData,
  });
}

/// The full payload sent to the background isolate.
///
/// [storeReference] comes from `ObjectBox().store.reference`; it is sendable
/// and lets the isolate attach to the already-open store instead of reopening
/// the database.
class BudgetSpendRequest {
  final ByteData storeReference;
  final List<BudgetSpec> specs;
  final ExchangeRates? rates;

  const BudgetSpendRequest({
    required this.storeReference,
    required this.specs,
    required this.rates,
  });
}
