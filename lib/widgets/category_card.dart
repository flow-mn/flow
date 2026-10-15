import "dart:async";

import "package:flow/data/exchange_rates.dart";
import "package:flow/data/multi_currency_flow.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/services/transactions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/optional.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:moment_dart/moment_dart.dart";

class CategoryCard extends StatefulWidget {
  final Category category;

  final BorderRadius borderRadius;

  final ExchangeRates? rates;

  final bool excludeTransfersInTotal;

  final bool showAmount;

  final Optional<VoidCallback>? onTapOverride;

  final Widget? trailing;

  const CategoryCard({
    super.key,
    required this.category,
    this.onTapOverride,
    this.trailing,
    this.rates,
    this.showAmount = true,
    this.excludeTransfersInTotal = true,
    this.borderRadius = const .all(Radius.circular(16.0)),
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  static const Duration _transactionRefreshDebounce = Duration(
    milliseconds: 300,
  );

  Category get category => widget.category;

  MultiCurrencyFlow _flow = MultiCurrencyFlow();

  Timer? _transactionDebounce;

  @override
  void initState() {
    super.initState();

    _computeFlow();
    TransactionsService().addListener(_onTransactionsChanged);
  }

  @override
  void didUpdateWidget(CategoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!identical(oldWidget.category, widget.category) ||
        oldWidget.showAmount != widget.showAmount ||
        oldWidget.excludeTransfersInTotal != widget.excludeTransfersInTotal) {
      _computeFlow();
    }
  }

  @override
  void dispose() {
    _transactionDebounce?.cancel();
    TransactionsService().removeListener(_onTransactionsChanged);
    super.dispose();
  }

  void _onTransactionsChanged() {
    if (!widget.showAmount) return;

    _transactionDebounce?.cancel();
    _transactionDebounce = Timer(_transactionRefreshDebounce, () {
      if (!mounted) return;
      setState(_computeFlow);
    });
  }

  void _computeFlow() {
    if (!widget.showAmount || category.id <= 0) {
      _flow = MultiCurrencyFlow();
      return;
    }

    final DateTime now = DateTime.now();

    final List<Transaction> transactions = TransactionsService()
        .findSettledBetweenSync(
          Transaction_.category.equals(category.id),
          now.startOfMonth(),
          now.endOfMonth(),
        );

    _flow = MultiCurrencyFlow()
      ..addAll(
        (widget.excludeTransfersInTotal
                ? transactions.nonTransfers
                : transactions)
            .map((transaction) => transaction.money),
      );
  }

  @override
  Widget build(BuildContext context) {
    final String primaryCurrency = UserPreferencesService().primaryCurrency;

    final BorderRadius borderRadius = widget.borderRadius;
    final Optional<VoidCallback>? onTapOverride = widget.onTapOverride;
    final Widget? trailing = widget.trailing;

    final FlowColorScheme? colorScheme = category.colorScheme;

    return Surface(
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      builder: (context) => InkWell(
        borderRadius: borderRadius,
        onTap: onTapOverride == null
            ? () => context.push("/category/${category.id}")
            : onTapOverride.value,
        child: Row(
          children: [
            FlowIcon(
              category.icon,
              size: 32.0,
              plated: true,
              colorScheme: colorScheme,
            ),
            const SizedBox(width: 12.0),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: .start,
              children: [
                Text(category.name, style: context.textTheme.titleSmall),
                if (widget.showAmount)
                  MoneyText(
                    _flow.merge(primaryCurrency, widget.rates).totalFlow,
                  ),
              ],
            ),
            const Spacer(),
            if (trailing != null) ...[trailing, const SizedBox(width: 12.0)],
          ],
        ),
      ),
    );
  }
}
