import "package:flow/data/money.dart";
import "package:flow/entity/recurring_transaction.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/services/recurring_transactions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions.dart";
import "package:flow/utils/primary_currency_dependent_state.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/home/stats/bento/bento_tile.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";

/// Bento preview of committed recurring outflow over the next [_windowDays]
/// days. Range-independent — recurring charges are always forward-looking.
class RecurringTile extends StatefulWidget {
  const RecurringTile({super.key});

  @override
  State<RecurringTile> createState() => _RecurringTileState();
}

class _RecurringTileState extends State<RecurringTile>
    with PrimaryCurrencyDependentState<RecurringTile> {
  static const int _windowDays = 30;

  bool busy = true;
  bool loaded = false;

  double outflow = 0.0;
  int upcoming = 0;

  @override
  Widget build(BuildContext context) {
    return BentoTile(
      label: "tabs.stats.analytics.recurring".t(context),
      icon: Symbols.autorenew_rounded,
      height: 158.0,
      busy: busy && !loaded,
      onTap: () => context.push("/stats/recurring"),
      child: Column(
        crossAxisAlignment: .start,
        mainAxisAlignment: .center,
        children: [
          Text(
            "tabs.stats.analytics.recurring.committedShort".t(context, {
              "days": _windowDays,
            }),
            style: context.textTheme.bodySmall?.semi(context),
          ),
          const SizedBox(height: 4.0),
          MoneyText(
            Money(outflow, primaryCurrency),
            style: context.textTheme.headlineSmall,
            autoSize: true,
            initiallyAbbreviated: true,
          ),
          const SizedBox(height: 8.0),
          Text(
            upcoming == 0
                ? "tabs.stats.analytics.recurring.nothingUpcoming".t(context)
                : "tabs.stats.analytics.recurring.upcomingCharges".t(
                    context,
                    upcoming,
                  ),
            style: context.textTheme.bodySmall?.semi(context),
          ),
        ],
      ),
    );
  }

  @override
  Future<void> fetch() async {
    try {
      final DateTime now = DateTime.now();
      final TimeRange window = CustomTimeRange(
        now,
        now.add(const Duration(days: _windowDays)),
      );

      final query = RecurringTransactionsService().activeRecurringsQb().build();
      final List<RecurringTransaction> recurrings = query.find();
      query.close();

      double totalOutflow = 0.0;
      int count = 0;

      for (final RecurringTransaction recurring in recurrings) {
        final Transaction? template = _decodeTemplate(recurring);
        if (template == null) continue;

        // Only expenses are "charges". Counting income/transfer recurrings
        // here would inflate the upcoming count while contributing nothing to
        // the outflow total, leaving the two figures describing different sets.
        if (template.type != TransactionType.expense) continue;

        final Money? money = _templateMoney(template);
        if (money == null) continue;

        final List<DateTime> occurrences = recurring.recurrence.occurrences(
          subrange: window,
        );
        count += occurrences.length;

        final double? converted = money.tryConvertAmount(
          primaryCurrency,
          rates,
        );
        if (converted != null) {
          totalOutflow += converted.abs() * occurrences.length;
        }
      }

      outflow = totalOutflow;
      upcoming = count;
      loaded = true;
    } finally {
      busy = false;
      if (mounted) setState(() {});
    }
  }

  Transaction? _decodeTemplate(RecurringTransaction recurring) {
    try {
      return recurring.template;
    } catch (_) {
      return null;
    }
  }

  Money? _templateMoney(Transaction template) {
    try {
      return template.money;
    } catch (_) {
      return null;
    }
  }
}
