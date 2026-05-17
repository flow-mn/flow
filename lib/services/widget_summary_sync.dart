import "dart:io";

import "package:flow/constants.dart";
import "package:flow/data/exchange_rates.dart";
import "package:flow/data/flow_analytics.dart";
import "package:flow/data/multi_currency_flow.dart";
import "package:flow/data/single_currency_flow.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/color_themes/registry.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:home_widget/home_widget.dart";
import "package:logging/logging.dart";
import "package:moment_dart/moment_dart.dart";

final Logger _log = Logger("WidgetSummarySync");

class WidgetSummarySync {
  static Future<void> sync() async {
    try {
      final String primaryCurrency =
          UserPreferencesService().primaryCurrency;
      final ExchangeRates? rates =
          ExchangeRatesService().getPrimaryCurrencyRates();

      final TimeRange range = TimeRange.thisMonth();

      final List<Transaction> transactions = await ObjectBox()
          .transcationsByRange(range, includeTransfers: false);

      final now = DateTime.now();

      final SingleCurrencyFlow flow =
          SingleCurrencyFlow(currency: primaryCurrency)
            ..addAll(
              transactions
                  .where((t) => !t.transactionDate.isAfter(now))
                  .where((t) => t.isPending != true)
                  .map((t) => t.money),
              rates,
            );

      final String formattedIncome =
          flow.totalIncome.formatMoney(compact: true);
      final String formattedExpense =
          flow.totalExpense.abs().formatMoney(compact: true);

      final String incomeLabel = TransactionType.income.localizedName;
      final String expenseLabel = TransactionType.expense.localizedName;
      final String rangeLabel = "account.thisMonth".tr();

      if (Platform.isIOS) {
        await HomeWidget.setAppGroupId(iOSAppGroupId);
      }

      await HomeWidget.saveWidgetData("summaryIncome", formattedIncome);
      await HomeWidget.saveWidgetData("summaryExpense", formattedExpense);
      await HomeWidget.saveWidgetData("summaryIncomeLabel", incomeLabel);
      await HomeWidget.saveWidgetData("summaryExpenseLabel", expenseLabel);
      await HomeWidget.saveWidgetData("summaryRangeLabel", rangeLabel);

      await HomeWidget.updateWidget(
        name: "FlowSummaryWidget",
        iOSName: "FlowSummaryWidget",
        androidName: "SummaryReceiver",
        qualifiedAndroidName: "mn.flow.flow.glance.SummaryReceiver",
      );

      _log.finest(
        "Synced summary widget: income=$formattedIncome, expense=$formattedExpense",
      );
    } catch (e) {
      _log.warning("Failed to sync summary widget: $e");
    }
  }

  /// Syncs the YNAB-style category analytics widget.
  ///
  /// Reads pinned category UUIDs from [LocalPreferences], queries
  /// month-to-date spending per category via [ObjectBox.flowByCategories],
  /// and sends flat primitive strings to the Android widget via [HomeWidget].
  static Future<void> syncYnabWidget() async {
    try {
      final String primaryCurrency =
          UserPreferencesService().primaryCurrency;
      final ExchangeRates? rates =
          ExchangeRatesService().getPrimaryCurrencyRates();

      // Read pinned category UUIDs (comma-separated string, null-safe)
      final String? rawUuids =
          LocalPreferences().ynabWidgetCategoryUuids.value;
      final List<String> pinnedUuids = (rawUuids == null || rawUuids.isEmpty)
          ? <String>[]
          : rawUuids.split(",").where((s) => s.isNotEmpty).toList();

      if (Platform.isIOS) {
        await HomeWidget.setAppGroupId(iOSAppGroupId);
      }

      // If no categories are pinned, show all categories
      final TimeRange range = TimeRange.thisMonth();
      final FlowAnalytics<Category?> analytics =
          await ObjectBox().flowByCategories(range: range);

      // Determine which UUIDs to display
      List<String> displayUuids;
      if (pinnedUuids.isEmpty) {
        // Show all categories with activity this month (scrollable)
        displayUuids = analytics.flow.keys.toList();
      } else {
        displayUuids = pinnedUuids.toList();
      }

      final int count = displayUuids.length;
      await HomeWidget.saveWidgetData("ynab_count", count.toString());

      for (int i = 0; i < count; i++) {
        final String uuid = displayUuids[i];
        final MultiCurrencyFlow<Category?>? categoryFlow =
            analytics.flow[uuid];

        final String categoryName =
            categoryFlow?.associatedData?.name ?? "category.none".tr();

        // Merge multi-currency flow into primary currency
        final SingleCurrencyFlow merged = categoryFlow?.merge(
              primaryCurrency,
              rates,
            ) ??
            SingleCurrencyFlow(currency: primaryCurrency);

        // Total flow = income + expense (expense is negative)
        final double totalFlow = merged.flow;
        final String spentRaw = totalFlow.toStringAsFixed(2);
        final String spentFormatted =
            merged.totalFlow.abs().formatMoney(compact: true);

        // Raw display: signed numbers, no currency symbol (for YNAB AMOLED style)
        // Negative for expenses (e.g. "-5500"), positive for income (e.g. "250")
        final String rawFormatted = totalFlow.abs() < 0.01
            ? "0"
            : totalFlow >= 100 || totalFlow <= -100
                ? totalFlow.toStringAsFixed(0)
                : totalFlow.toStringAsFixed(2);

        await HomeWidget.saveWidgetData("ynab_${i}_name", categoryName);
        await HomeWidget.saveWidgetData("ynab_${i}_spent", spentRaw);
        await HomeWidget.saveWidgetData("ynab_${i}_display", spentFormatted);
        await HomeWidget.saveWidgetData("ynab_${i}_raw_display", rawFormatted);
      }

      // Clear stale slots (in case we previously had more categories)
      for (int i = count; i < 20; i++) {
        await HomeWidget.saveWidgetData("ynab_${i}_name", null);
        await HomeWidget.saveWidgetData("ynab_${i}_spent", null);
        await HomeWidget.saveWidgetData("ynab_${i}_display", null);
        await HomeWidget.saveWidgetData("ynab_${i}_raw_display", null);
      }

      // Send style preference to native widget
      final String? style = LocalPreferences().ynabWidgetStyle.value;
      await HomeWidget.saveWidgetData("ynab_style", style ?? "flow");

      // Bridge theme colors from the app's theme system to the widget
      // This allows the Flow-style widget to match the app's selected theme
      final String currentThemeName = UserPreferencesService().themeName;
      final FlowColorScheme scheme = getTheme(currentThemeName);

      await HomeWidget.saveWidgetData(
        "theme_surface",
        scheme.surface.toARGB32().toString(),
      );
      await HomeWidget.saveWidgetData(
        "theme_onSurface",
        scheme.onSurface.toARGB32().toString(),
      );
      await HomeWidget.saveWidgetData(
        "theme_primary",
        scheme.primary.toARGB32().toString(),
      );
      await HomeWidget.saveWidgetData(
        "theme_secondary",
        scheme.secondary.toARGB32().toString(),
      );
      await HomeWidget.saveWidgetData(
        "theme_onSecondary",
        (scheme.onSecondary ?? scheme.onSurface).toARGB32().toString(),
      );
      await HomeWidget.saveWidgetData(
        "theme_income",
        scheme.customColors.income.toARGB32().toString(),
      );
      await HomeWidget.saveWidgetData(
        "theme_expense",
        scheme.customColors.expense.toARGB32().toString(),
      );
      await HomeWidget.saveWidgetData(
        "theme_semi",
        scheme.customColors.semi.toARGB32().toString(),
      );
      await HomeWidget.saveWidgetData(
        "theme_isDark",
        scheme.isDark.toString(),
      );

      await HomeWidget.updateWidget(
        name: "FlowYnabBudgetWidget",
        androidName: "YnabBudgetReceiver",
        qualifiedAndroidName: "mn.flow.flow.glance.YnabBudgetReceiver",
      );

      _log.finest(
        "Synced YNAB widget: count=$count",
      );
    } catch (e) {
      _log.warning("Failed to sync YNAB widget: $e");
    }
  }
}
