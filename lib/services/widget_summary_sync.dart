import "dart:io";

import "package:flow/constants.dart";
import "package:flow/data/exchange_rates.dart";
import "package:flow/data/single_currency_flow.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/user_preferences.dart";
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
}
