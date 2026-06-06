import "package:flow/data/exchange_rates.dart";
import "package:flow/data/flow_icon.dart";
import "package:flow/data/money.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/recurring_transaction.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/services/accounts.dart";
import "package:flow/services/categories.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/recurring_transactions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";

/// [dev] Subscriptions & recurring radar.
///
/// Projects every active [RecurringTransaction] forward over the next 30 days
/// using its [Recurrence] rules, then lists the upcoming charges and sums the
/// committed outflow. Built entirely from data Flow already stores.
class DebugRecurringPage extends StatefulWidget {
  const DebugRecurringPage({super.key});

  @override
  State<DebugRecurringPage> createState() => _DebugRecurringPageState();
}

/// One projected occurrence of a recurring transaction within the window.
class _Upcoming {
  final DateTime date;
  final Transaction template;

  /// The template's amount, pre-validated so the tile never touches the
  /// throwing [Transaction.money] getter.
  final Money money;
  final Category? category;
  final Account? account;

  const _Upcoming({
    required this.date,
    required this.template,
    required this.money,
    this.category,
    this.account,
  });
}

class _DebugRecurringPageState extends State<DebugRecurringPage> {
  static const int _windowDays = 30;
  static const int _maxRows = 60;

  bool busy = false;
  bool missingRates = false;

  late String primaryCurrency;
  ExchangeRates? rates;

  List<_Upcoming> upcoming = [];
  int activeCount = 0;
  double outflow = 0.0;

  @override
  void initState() {
    super.initState();

    primaryCurrency = UserPreferencesService().primaryCurrency;
    rates = ExchangeRatesService().getPrimaryCurrencyRates();

    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recurring (dev)"),
        elevation: 0.0,
        scrolledUnderElevation: 1.0,
        centerTitle: false,
        shadowColor: context.colorScheme.onSurface.withAlpha(0x40),
        backgroundColor: context.colorScheme.surface,
        surfaceTintColor: kTransparent,
      ),
      body: SafeArea(
        child: busy && upcoming.isEmpty
            ? const Spinner.center()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16.0),
                    _Header(
                      outflow: Money(outflow, primaryCurrency),
                      activeCount: activeCount,
                      windowDays: _windowDays,
                    ),
                    const SizedBox(height: 16.0),
                    if (activeCount == 0)
                      const Frame(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 48.0),
                          child: Center(
                            child: Text("No recurring transactions set up."),
                          ),
                        ),
                      )
                    else if (upcoming.isEmpty)
                      const Frame(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 48.0),
                          child: Center(
                            child: Text("Nothing due in the next 30 days."),
                          ),
                        ),
                      )
                    else
                      ..._buildRows(context),
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

  List<Widget> _buildRows(BuildContext context) {
    final List<Widget> rows = upcoming
        .take(_maxRows)
        .map(
          (item) => _UpcomingTile(item: item, primaryCurrency: primaryCurrency),
        )
        .toList();

    if (upcoming.length > _maxRows) {
      rows.add(
        Frame(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              "+ ${upcoming.length - _maxRows} more not shown",
              style: context.textTheme.bodySmall?.semi(context),
            ),
          ),
        ),
      );
    }

    return rows;
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
        now,
        now.add(const Duration(days: _windowDays)),
      );

      final query = RecurringTransactionsService().activeRecurringsQb().build();
      final List<RecurringTransaction> recurrings = query.find();
      query.close();

      final List<_Upcoming> result = [];
      double totalOutflow = 0.0;
      int active = 0;

      for (final RecurringTransaction recurring in recurrings) {
        final Transaction? template = _decodeTemplate(recurring);
        if (template == null) continue;

        // Money(...) throws on an unknown currency code; skip the recurring
        // rather than letting one stale template break the whole page.
        final Money? money = _templateMoney(template);
        if (money == null) continue;

        active++;

        final Category? category = template.categoryUuid == null
            ? null
            : CategoriesService().findOneSync(template.categoryUuid);
        final Account? account = template.accountUuid == null
            ? null
            : AccountsService().findOneSync(template.accountUuid);

        final List<DateTime> occurrences = recurring.recurrence.occurrences(
          subrange: window,
        );

        for (final DateTime date in occurrences) {
          result.add(
            _Upcoming(
              date: date,
              template: template,
              money: money,
              category: category,
              account: account,
            ),
          );

          if (template.type == TransactionType.expense) {
            final double? converted = _convert(money, primaryCurrency);
            if (converted == null) {
              missing = true;
            } else {
              totalOutflow += converted.abs();
            }
          }
        }
      }

      result.sort((a, b) => a.date.compareTo(b.date));

      upcoming = result;
      activeCount = active;
      outflow = totalOutflow;
      missingRates = missing;
    } finally {
      busy = false;
      if (mounted) setState(() {});
    }
  }

  Transaction? _decodeTemplate(RecurringTransaction recurring) {
    try {
      return recurring.template;
    } catch (_) {
      // A malformed template shouldn't take down the whole list.
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

class _Header extends StatelessWidget {
  final Money outflow;
  final int activeCount;
  final int windowDays;

  const _Header({
    required this.outflow,
    required this.activeCount,
    required this.windowDays,
  });

  @override
  Widget build(BuildContext context) {
    return Frame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Committed outflow",
            style: context.textTheme.titleSmall?.semi(context),
          ),
          const SizedBox(height: 2.0),
          MoneyText(
            outflow,
            style: context.textTheme.displaySmall,
            autoSize: true,
            tapToToggleAbbreviation: true,
          ),
          const SizedBox(height: 4.0),
          Text(
            "$activeCount recurring · next $windowDays days",
            style: context.textTheme.bodyMedium?.semi(context),
          ),
        ],
      ),
    );
  }
}

class _UpcomingTile extends StatelessWidget {
  final _Upcoming item;
  final String primaryCurrency;

  const _UpcomingTile({required this.item, required this.primaryCurrency});

  @override
  Widget build(BuildContext context) {
    final Transaction template = item.template;
    final Color typeColor = template.type.color(context);

    final FlowIconData iconData =
        item.category?.icon ??
        item.account?.icon ??
        FlowIconData.icon(Symbols.autorenew_rounded);

    final String title =
        template.title ?? item.account?.name ?? "Recurring transaction";
    final String subtitle =
        "${item.date.toMoment().fromNow()} · "
        "${item.category?.name ?? item.account?.name ?? "Recurring"}";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Row(
        children: [
          SizedBox(
            width: 40.0,
            child: Column(
              children: [
                Text(
                  item.date.toMoment().format("D"),
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  item.date.toMoment().format("MMM").toUpperCase(),
                  style: context.textTheme.labelSmall?.semi(context),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          FlowIcon(iconData, plated: true, color: typeColor),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyLarge,
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.semi(context),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          MoneyText(
            item.money,
            style: context.textTheme.titleSmall?.copyWith(color: typeColor),
          ),
        ],
      ),
    );
  }
}
