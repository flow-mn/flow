import "package:flow/entity/category.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/widgets/add_category_card.dart";
import "package:flow/widgets/categories/no_categories.dart";
import "package:flow/widgets/category_card.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flutter/material.dart";

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late bool usesSingleCurrency;

  QueryBuilder<Category> qb() =>
      ObjectBox().box<Category>().query().order(Category_.createdDate);

  @override
  void initState() {
    super.initState();
    TransitiveLocalPreferences().transitiveUsesSingleCurrency.addListener(
      _updateUsesSingleCurrency,
    );
    _updateUsesSingleCurrency();

    if (!usesSingleCurrency) {
      ExchangeRatesService().getPrimaryCurrencyRates();
    }
  }

  @override
  void dispose() {
    TransitiveLocalPreferences().transitiveUsesSingleCurrency.removeListener(
      _updateUsesSingleCurrency,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("categories".t(context))),
      body: SafeArea(
        child: StreamBuilder<List<Category>>(
          stream: qb()
              .watch(triggerImmediately: true)
              .map((event) => event.find()),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Spinner.center();
            }

            final categories = snapshot.requireData;

            return switch (categories.length) {
              0 => const NoCategories(),
              _ => ValueListenableBuilder(
                valueListenable: ExchangeRatesService().exchangeRatesCache,
                builder: (context, exchangeRatesCache, _) {
                  return ValueListenableBuilder(
                    valueListenable: UserPreferencesService().valueNotiifer,
                    builder: (context, userPreferences, child) {
                      final bool excludeTransfersInTotal =
                          userPreferences.excludeTransfersFromFlow;
                      final String primaryCurrency =
                          LocalPreferences().getPrimaryCurrency();

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 16.0),
                              child: AddCategoryCard(),
                            ),
                            ...categories.map(
                              (category) => Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: CategoryCard(
                                  category: category,
                                  excludeTransfersInTotal:
                                      excludeTransfersInTotal,
                                  rates: exchangeRatesCache?.get(
                                    primaryCurrency,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            };
          },
        ),
      ),
    );
  }

  void _updateUsesSingleCurrency() {
    setState(() {
      usesSingleCurrency =
          TransitiveLocalPreferences().transitiveUsesSingleCurrency.get();
    });
  }
}
