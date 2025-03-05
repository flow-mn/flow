import "package:flow/data/exchange_rates.dart";
import "package:flow/data/flow_analytics.dart";
import "package:flow/data/flow_icon.dart";
import "package:flow/data/money.dart";
import "package:flow/entity/category.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/widgets/general/blur_backgorund.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class MostSpendingCategory extends StatefulWidget {
  final TimeRange range;

  final BorderRadius? borderRadius;

  const MostSpendingCategory({
    super.key,
    required this.range,
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
  });

  @override
  State<MostSpendingCategory> createState() => _MostSpendingCategoryState();
}

class _MostSpendingCategoryState extends State<MostSpendingCategory> {
  late TimeRange range;

  Category? category;
  Money? expense;

  bool busy = false;

  @override
  void initState() {
    super.initState();
    range = widget.range;
    fetch();
  }

  @override
  void didUpdateWidget(MostSpendingCategory oldWidget) {
    if (widget.range != oldWidget.range) {
      setState(() {
        range = widget.range;
        fetch();
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: widget.borderRadius,
      onTap:
          (busy || category == null)
              ? null
              : (() => context.push(
                "/category/${category?.id}?range=${Uri.encodeQueryComponent(range.encodeShort())}",
              )),
      child: BlurBackground(
        blur: busy,
        child: Surface(
          shape: RoundedRectangleBorder(
            borderRadius: widget.borderRadius as BorderRadiusGeometry,
          ),
          builder:
              (context) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  spacing: 16.0,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            spacing: 8.0,
                            children: [
                              FlowIcon(
                                category?.icon ??
                                    FlowIconData.icon(Symbols.category_rounded),
                              ),
                              Text(
                                category?.name ?? "category.none".t(context),
                              ),
                            ],
                          ),
                          MoneyText(
                            expense,
                            autoSize: true,
                            style: context.textTheme.displaySmall,
                          ),
                        ],
                      ),
                    ),
                    Icon(Symbols.chevron_right_rounded),
                  ],
                ),
              ),
        ),
      ),
    );
  }

  void fetch() async {
    setState(() {
      busy = true;
    });

    try {
      final FlowAnalytics<Category?> result = await ObjectBox()
          .flowByCategories(range: range);
      final String primaryCurrency = LocalPreferences().getPrimaryCurrency();
      final ExchangeRates? rates =
          ExchangeRatesService().getPrimaryCurrencyRates();

      Money? mostExpense;
      Category? mostExpensedCategory;

      for (final flow in result.flow.values) {
        final Money flowTotalExpense =
            rates == null
                ? flow.getExpenseByCurrency(primaryCurrency)
                : flow.getTotalExpense(rates, primaryCurrency);

        if (mostExpense == null ||
            flowTotalExpense.amount.abs() > mostExpense.amount.abs()) {
          mostExpense = flowTotalExpense;
          mostExpensedCategory = flow.associatedData;
        }
      }

      category = mostExpensedCategory;
      expense = mostExpense;
    } finally {
      busy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }
}
