import "package:flow/data/exchange_rates.dart";
import "package:flow/data/money.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flutter/material.dart";
import "package:flutter_map/flutter_map.dart";
import "package:latlong2/latlong.dart";
import "package:moment_dart/moment_dart.dart";

/// [dev] Spending map.
///
/// Clusters geo-bearing expenses (from `Transaction.location` / the geo
/// extension) into ~100 m places, sizes a marker by total spend, and ranks
/// the places. Reads location data already stored on-device.
class DebugSpendingMapPage extends StatefulWidget {
  const DebugSpendingMapPage({super.key});

  @override
  State<DebugSpendingMapPage> createState() => _DebugSpendingMapPageState();
}

enum _Period {
  m1("1M", 30),
  m3("3M", 90),
  y1("1Y", 365);

  final String label;
  final int days;

  const _Period(this.label, this.days);
}

class _Place {
  final LatLng center;
  final double total;
  final int count;
  final String name;

  const _Place({
    required this.center,
    required this.total,
    required this.count,
    required this.name,
  });
}

class _PlaceAccumulator {
  double sumLat = 0.0;
  double sumLng = 0.0;
  double total = 0.0;
  int count = 0;
  final Map<String, int> titleFrequency = {};

  void add(LatLng point, double amount, String? title) {
    sumLat += point.latitude;
    sumLng += point.longitude;
    total += amount;
    count++;

    final String? key = title?.trim();
    if (key != null && key.isNotEmpty) {
      titleFrequency[key] = (titleFrequency[key] ?? 0) + 1;
    }
  }

  String get topTitle {
    if (titleFrequency.isEmpty) return "Pinned location";
    return titleFrequency.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  _Place toPlace() => _Place(
    center: LatLng(sumLat / count, sumLng / count),
    total: total,
    count: count,
    name: topTitle,
  );
}

class _DebugSpendingMapPageState extends State<DebugSpendingMapPage> {
  /// Caps how many place markers are drawn so a dense window stays smooth;
  /// places are sorted by spend, so the most significant ones win.
  static const int _maxMarkers = 150;

  _Period period = _Period.m3;

  bool busy = false;
  bool missingRates = false;

  late String primaryCurrency;
  ExchangeRates? rates;

  List<_Place> places = [];
  double mappedTotal = 0.0;
  int locatedCount = 0;
  int totalExpenseCount = 0;

  @override
  void initState() {
    super.initState();

    primaryCurrency = UserPreferencesService().primaryCurrency;
    rates = ExchangeRatesService().getPrimaryCurrencyRates();

    fetch();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasData = places.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Spending map (dev)"),
        elevation: 0.0,
        scrolledUnderElevation: 1.0,
        centerTitle: false,
        shadowColor: context.colorScheme.onSurface.withAlpha(0x40),
        backgroundColor: context.colorScheme.surface,
        surfaceTintColor: kTransparent,
      ),
      body: SafeArea(
        child: busy && places.isEmpty
            ? const Spinner.center()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16.0),
                    Frame(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Mapped spend",
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
                            "$locatedCount of $totalExpenseCount expenses have "
                            "a location",
                            style: context.textTheme.bodyMedium?.semi(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Frame(
                      child: Wrap(
                        spacing: 8.0,
                        children: _Period.values
                            .map(
                              (p) => FilterChip(
                                label: Text(p.label),
                                selected: p == period,
                                onSelected: busy ? null : (_) => _setPeriod(p),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    if (hasData) ...[
                      Frame(child: _buildMap(context)),
                      const SizedBox(height: 24.0),
                      const ListHeader("Top places"),
                      const SizedBox(height: 8.0),
                      ..._buildPlaceRows(context),
                    ] else
                      const Frame(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 48.0),
                          child: Center(
                            child: Text("No located spending in this window."),
                          ),
                        ),
                      ),
                    if (missingRates) ...[
                      const SizedBox(height: 8.0),
                      Frame(
                        child: Text(
                          "Some non-primary currency amounts were skipped "
                          "(missing exchange rates).",
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.flowColors.expense,
                          ),
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
      borderRadius: const BorderRadius.all(Radius.circular(16.0)),
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
                final String label =
                    "${place.name}: "
                    "${Money(place.total, primaryCurrency).formatted}";

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

  List<Widget> _buildPlaceRows(BuildContext context) {
    return places.take(12).toList().asMap().entries.map((entry) {
      final int rank = entry.key + 1;
      final _Place place = entry.value;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        child: Row(
          children: [
            SizedBox(
              width: 24.0,
              child: Text(
                "$rank",
                style: context.textTheme.titleSmall?.semi(context),
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyLarge,
                  ),
                  Text(
                    "${place.count} ${place.count == 1 ? "visit" : "visits"}",
                    style: context.textTheme.bodySmall?.semi(context),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            MoneyText(
              Money(place.total, primaryCurrency),
              style: context.textTheme.titleSmall,
            ),
          ],
        ),
      );
    }).toList();
  }

  void _setPeriod(_Period value) {
    if (value == period) return;
    period = value;
    fetch();
  }

  Future<void> fetch() async {
    if (!mounted) return;
    setState(() {
      busy = true;
    });

    bool missing = false;

    try {
      primaryCurrency = UserPreferencesService().primaryCurrency;
      rates = ExchangeRatesService().getPrimaryCurrencyRates();

      final DateTime now = DateTime.now();
      final TimeRange window = CustomTimeRange(
        now.subtract(Duration(days: period.days)),
        now,
      );

      final List<Transaction> transactions = await ObjectBox()
          .transcationsByRange(window, includeTransfers: false);

      final Map<String, _PlaceAccumulator> clusters = {};
      double mapped = 0.0;
      int located = 0;
      int expenses = 0;

      for (final Transaction transaction in transactions) {
        if (transaction.type != TransactionType.expense) continue;
        expenses++;

        final LatLng? point = _latLngOf(transaction);
        if (point == null) continue;

        final double? converted = _convert(transaction.money, primaryCurrency);
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
        (clusters[key] ??= _PlaceAccumulator()).add(
          point,
          magnitude,
          transaction.title,
        );
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

  double? _convert(Money money, String currency) {
    if (money.currency == currency) return money.amount;

    final ExchangeRates? rates = this.rates;
    if (rates == null) return null;

    try {
      return money.convert(currency, rates).amount;
    } catch (_) {
      return null;
    }
  }
}
