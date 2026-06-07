import "package:flow/data/money.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions.dart";
import "package:flow/utils/primary_currency_dependent_state.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";

/// A slim accent banner inviting the user into their monthly "wrapped" recap.
///
/// Deliberately styled apart from the data tiles — wrapped is a seasonal
/// moment, not a daily chart. Carries a one-line teaser built from this
/// month's transactions.
class WrappedTile extends StatefulWidget {
  const WrappedTile({super.key});

  @override
  State<WrappedTile> createState() => _WrappedTileState();
}

class _WrappedTileState extends State<WrappedTile>
    with PrimaryCurrencyDependentState<WrappedTile> {
  int entryCount = 0;
  double biggestExpense = 0.0;

  @override
  Widget build(BuildContext context) {
    final String month = DateTime.now().toMoment().format("MMMM");
    final Color accent = context.colorScheme.primary;

    final String teaser = entryCount == 0
        ? "tabs.stats.analytics.wrapped.tileTeaserEmpty".t(context)
        : (entryCount == 1
                  ? "tabs.stats.analytics.wrapped.tileTeaser.one"
                  : "tabs.stats.analytics.wrapped.tileTeaser")
              .t(context, {
                "count": entryCount,
                "amount": Money(
                  biggestExpense,
                  primaryCurrency,
                ).formattedCompact,
              });

    return Surface(
      builder: (context) => InkWell(
        borderRadius: .all(Radius.circular(16.0)),
        onTap: () => context.push("/stats/wrapped"),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: .all(Radius.circular(16.0)),
            gradient: LinearGradient(
              begin: AlignmentDirectional.centerStart,
              end: AlignmentDirectional.centerEnd,
              colors: [accent.withAlpha(0x2e), accent.withAlpha(0x08)],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              Icon(Symbols.auto_awesome_rounded, color: accent, size: 22.0),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisSize: .min,
                  children: [
                    Text(
                      "tabs.stats.analytics.wrapped.tileTitle".t(context, month),
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      teaser,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.semi(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Icon(
                Symbols.chevron_right_rounded,
                color: context.flowColors.semi,
                size: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Future<void> fetch() async {
    try {
      final List<Transaction> transactions = await ObjectBox()
          .transcationsByRange(TimeRange.thisMonth(), includeTransfers: false);

      int count = 0;
      double biggest = 0.0;

      for (final Transaction transaction in transactions) {
        count++;
        if (transaction.type != TransactionType.expense) continue;

        final double? converted = transaction.money.tryConvertAmount(
          primaryCurrency,
          rates,
        );
        if (converted == null) continue;

        final double magnitude = converted.abs();
        if (magnitude > biggest) biggest = magnitude;
      }

      entryCount = count;
      biggestExpense = biggest;
    } finally {
      if (mounted) setState(() {});
    }
  }
}
