import "package:flow/data/money.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/primary_currency_dependent_state.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/stats/missing_rates_notice.dart";
import "package:flow/widgets/stats/stats_app_bar.dart";
import "package:flow/widgets/stats/stats_empty_state.dart";
import "package:flow/widgets/time_range_selector.dart";
import "package:flutter/material.dart";
import "package:flutter_map/flutter_map.dart";
import "package:latlong2/latlong.dart";
import "package:moment_dart/moment_dart.dart";

/// Spending map.
///
/// Clusters geo-bearing expenses (from `Transaction.location` / the geo
/// extension) into ~100 m places and sizes a marker by total spend. Places
/// aren't named or ranked: the only label available is the transaction title,
/// which rarely describes the place, so the heatmap stands on its own.
class SpendingMapPage extends StatefulWidget {
  const SpendingMapPage({super.key});

  @override
  State<SpendingMapPage> createState() => _SpendingMapPageState();
}

class _Place {
  final LatLng center;
  final double total;

  const _Place({required this.center, required this.total});
}

class _PlaceAccumulator {
  double sumLat = 0.0;
  double sumLng = 0.0;
  double total = 0.0;
  int count = 0;

  void add(LatLng point, double amount) {
    sumLat += point.latitude;
    sumLng += point.longitude;
    total += amount;
    count++;
  }

  _Place toPlace() =>
      _Place(center: LatLng(sumLat / count, sumLng / count), total: total);
}

class _SpendingMapPageState extends State<SpendingMapPage>
    with PrimaryCurrencyDependentState<SpendingMapPage> {
  /// Caps how many place markers are drawn so a dense window stays smooth;
  /// places are sorted by spend, so the most significant ones win.
  static const int _maxMarkers = 150;

  TimeRange range = TimeRange.thisYear();

  bool busy = false;
  bool missingRates = false;

  List<_Place> places = [];
  double mappedTotal = 0.0;
  int locatedCount = 0;
  int totalExpenseCount = 0;

  @override
  Widget build(BuildContext context) {
    final bool hasData = places.isNotEmpty;

    return Scaffold(
      appBar: StatsAppBar(title: "tabs.stats.analytics.spendingMap".t(context)),
      body: SafeArea(
        child: busy && places.isEmpty
            ? const Spinner.center()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    const SizedBox(height: 16.0),
                    Frame(
                      child: TimeRangeSelector(
                        initialValue: range,
                        onChanged: _updateRange,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Frame(
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          Text(
                            "tabs.stats.analytics.map.mappedSpend".t(context),
                            style: context.textTheme.titleSmall?.semi(context),
                          ),
                          const SizedBox(height: 2.0),
                          MoneyText(
                            Money(mappedTotal, primaryCurrency),
                            style: context.textTheme.displaySmall,
                            autoSize: true,
                            tapToToggleAbbreviation: true,
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            "tabs.stats.analytics.map.locatedCount".t(context, {
                              "located": locatedCount,
                              "total": totalExpenseCount,
                            }),
                            style: context.textTheme.bodyMedium?.semi(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    if (hasData)
                      Frame(child: _buildMap(context))
                    else
                      StatsEmptyState(
                        message: "tabs.stats.analytics.map.empty".t(context),
                      ),
                    if (missingRates) ...[
                      const SizedBox(height: 8.0),
                      MissingRatesNotice(
                        message: "tabs.stats.analytics.missingRatesAmounts".t(
                          context,
                        ),
                      ),
                    ],
                    const SizedBox(height: 96.0),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildMap(BuildContext context) {
    // Places are sorted by spend, so the first is the maximum.
    final double maxTotal = places.first.total;
    final Color marker = context.colorScheme.primary;

    return ClipRRect(
      borderRadius: .all(Radius.circular(16.0)),
      child: SizedBox(
        height: 320.0,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: places.first.center,
            initialZoom: 12.0,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              fallbackUrl:
                  "http://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png",
              userAgentPackageName: "mn.flow.flow",
            ),
            MarkerLayer(
              markers: places.take(_maxMarkers).map((place) {
                final double factor = maxTotal <= 0
                    ? 0.0
                    : place.total / maxTotal;
                final double size = 16.0 + 34.0 * factor;
                final String label = Money(
                  place.total,
                  primaryCurrency,
                ).formatted;

                return Marker(
                  point: place.center,
                  width: size,
                  height: size,
                  child: Tooltip(
                    message: label,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: marker.withAlpha(0x59),
                        border: Border.all(color: marker, width: 1.5),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  "OpenStreetMap contributors",
                  onTap: () =>
                      openUrl(Uri.parse("https://openstreetmap.org/copyright")),
                ),
              ],
              popupBackgroundColor: const Color(0xC0FFFFFF),
            ),
          ],
        ),
      ),
    );
  }

  void _updateRange(TimeRange value) {
    if (value == range) return;
    range = value;
    fetch();
  }

  @override
  Future<void> fetch() async {
    if (!mounted) return;
    setState(() {
      busy = true;
    });

    bool missing = false;

    try {
      final List<Transaction> transactions = await ObjectBox()
          .transcationsByRange(range, includeTransfers: false);

      final Map<String, _PlaceAccumulator> clusters = {};
      double mapped = 0.0;
      int located = 0;
      int expenses = 0;

      for (final Transaction transaction in transactions) {
        if (transaction.type != TransactionType.expense) continue;
        expenses++;

        final LatLng? point = _latLngOf(transaction);
        if (point == null) continue;

        final double? converted = transaction.money.tryConvertAmount(
          primaryCurrency,
          rates,
        );
        if (converted == null) {
          missing = true;
          continue;
        }

        located++;
        final double magnitude = converted.abs();
        mapped += magnitude;

        // ~100 m grid (3 decimal places) keeps repeat visits in one place.
        final String key =
            "${(point.latitude * 1000).round()}:"
            "${(point.longitude * 1000).round()}";
        (clusters[key] ??= _PlaceAccumulator()).add(point, magnitude);
      }

      final List<_Place> result =
          clusters.values.map((accumulator) => accumulator.toPlace()).toList()
            ..sort((a, b) => b.total.compareTo(a.total));

      places = result;
      mappedTotal = mapped;
      locatedCount = located;
      totalExpenseCount = expenses;
      missingRates = missing;
    } finally {
      busy = false;
      if (mounted) setState(() {});
    }
  }

  LatLng? _latLngOf(Transaction transaction) {
    final List<double>? location = transaction.location;
    if (location != null && location.length == 2) {
      final double lat = location[0];
      final double lng = location[1];
      if (lat.isFinite && lng.isFinite) return LatLng(lat, lng);
    }

    final LatLng? geo = transaction.extensions.geo?.toLatLngPosition();
    if (geo != null && geo.latitude.isFinite && geo.longitude.isFinite) {
      return geo;
    }

    return null;
  }
}
