import "package:flow/data/money.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions.dart";
import "package:flow/utils/primary_currency_dependent_state.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/home/stats/bento/bento_tile.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:latlong2/latlong.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";

/// Bento preview of located spending over the trailing [_days] days: how much
/// spend carries a location. Range-independent.
class MapTile extends StatefulWidget {
  const MapTile({super.key});

  @override
  State<MapTile> createState() => _MapTileState();
}

class _MapTileState extends State<MapTile>
    with PrimaryCurrencyDependentState<MapTile> {
  static const int _days = 90;

  bool busy = true;
  bool loaded = false;

  double mappedTotal = 0.0;
  int locatedCount = 0;

  @override
  Widget build(BuildContext context) {
    final bool hasData = locatedCount > 0;

    return BentoTile(
      label: "tabs.stats.analytics.spendingMap".t(context),
      icon: Symbols.map_rounded,
      height: 158.0,
      busy: busy && !loaded,
      onTap: () => context.push("/stats/map"),
      child: hasData
          ? Column(
              crossAxisAlignment: .start,
              mainAxisAlignment: .center,
              children: [
                Text(
                  "tabs.stats.analytics.map.mappedShort".t(context, {
                    "days": _days,
                  }),
                  style: context.textTheme.bodySmall?.semi(context),
                ),
                const SizedBox(height: 4.0),
                MoneyText(
                  Money(mappedTotal, primaryCurrency),
                  style: context.textTheme.headlineSmall,
                  autoSize: true,
                  initiallyAbbreviated: true,
                ),
              ],
            )
          : Text(
              "tabs.stats.analytics.map.noneYet".t(context),
              style: context.textTheme.bodySmall?.semi(context),
            ),
    );
  }

  @override
  Future<void> fetch() async {
    try {
      final DateTime now = DateTime.now();
      final List<Transaction> transactions = await ObjectBox()
          .transcationsByRange(
            CustomTimeRange(now.subtract(const Duration(days: _days)), now),
            includeTransfers: false,
          );

      double mapped = 0.0;
      int located = 0;

      for (final Transaction transaction in transactions) {
        if (transaction.type != TransactionType.expense) continue;

        final LatLng? point = _latLngOf(transaction);
        if (point == null) continue;

        final double? converted = transaction.money.tryConvertAmount(
          primaryCurrency,
          rates,
        );
        if (converted == null) continue;

        located++;
        mapped += converted.abs();
      }

      mappedTotal = mapped;
      locatedCount = located;
      loaded = true;
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
