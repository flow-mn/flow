import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions.dart";
import "package:flow/utils/primary_currency_dependent_state.dart";
import "package:flow/widgets/home/stats/bento/bento_tile.dart";
import "package:flow/widgets/home/stats/bento/calendar_heatmap.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";

/// Bento preview of the spending calendar: a compact GitHub-style heatmap of
/// daily expense over the trailing [_weeks] weeks. Range-independent.
class CalendarTile extends StatefulWidget {
  const CalendarTile({super.key});

  @override
  State<CalendarTile> createState() => _CalendarTileState();
}

class _CalendarTileState extends State<CalendarTile>
    with PrimaryCurrencyDependentState<CalendarTile> {
  static const int _weeks = 13;

  bool busy = true;
  bool loaded = false;

  /// Day (midnight) -> total expense in the primary currency.
  Map<DateTime, double> dailyExpense = {};
  double maxDaily = 0.0;

  /// Monday at the start of the grid window — resolved lazily so it's ready
  /// before the mixin runs the first [fetch].
  late final DateTime gridStart = _resolveGridStart();

  @override
  Widget build(BuildContext context) {
    return BentoTile(
      label: "tabs.stats.analytics.calendar".t(context),
      icon: Symbols.calendar_month_rounded,
      height: 158.0,
      busy: busy && !loaded,
      onTap: () => context.push("/stats/calendar"),
      child: dailyExpense.isEmpty
          ? Text(
              "tabs.stats.analytics.noSpendingWindow".t(context),
              style: context.textTheme.bodySmall?.semi(context),
            )
          : Align(
              alignment: AlignmentDirectional.centerStart,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: CalendarHeatmap(
                  gridStart: gridStart,
                  weeks: _weeks,
                  dailyExpense: dailyExpense,
                  maxDaily: maxDaily,
                  filled: context.colorScheme.primary,
                  empty: context.colorScheme.onSurface.withAlpha(0x14),
                ),
              ),
            ),
    );
  }

  @override
  Future<void> fetch() async {
    try {
      final DateTime now = DateTime.now();
      final List<Transaction> transactions = await ObjectBox()
          .transcationsByRange(
            CustomTimeRange(gridStart, now),
            includeTransfers: false,
          );

      final Map<DateTime, double> daily = {};

      for (final Transaction transaction in transactions) {
        if (transaction.type != TransactionType.expense) continue;

        final double? converted = transaction.money.tryConvertAmount(
          primaryCurrency,
          rates,
        );
        if (converted == null) continue;

        final DateTime day = DateTime(
          transaction.transactionDate.year,
          transaction.transactionDate.month,
          transaction.transactionDate.day,
        );
        daily[day] = (daily[day] ?? 0.0) + converted.abs();
      }

      dailyExpense = daily;
      maxDaily = daily.values.isEmpty
          ? 0.0
          : daily.values.reduce((a, b) => a > b ? a : b);
      loaded = true;
    } finally {
      busy = false;
      if (mounted) setState(() {});
    }
  }

  /// Monday at the start of the grid window, [_weeks] weeks back.
  DateTime _resolveGridStart() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime thisMonday = today.subtract(
      Duration(days: today.weekday - 1),
    );
    return thisMonday.subtract(Duration(days: (_weeks - 1) * 7));
  }
}
