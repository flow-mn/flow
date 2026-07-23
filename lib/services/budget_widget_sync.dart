import "dart:convert";
import "dart:io";

import "package:flow/constants.dart";
import "package:flow/data/budget_progress.dart";
import "package:flow/data/exchange_rates.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/services/budget.dart";
import "package:flow/services/exchange_rates.dart";
import "package:home_widget/home_widget.dart";
import "package:intl/intl.dart";
import "package:logging/logging.dart";
import "package:moment_dart/moment_dart.dart";

final Logger _log = Logger("BudgetWidgetSync");

/// Publishes budget state to the iOS and Android home-screen widgets.
///
/// A widget extension runs in its own process. It cannot reach ObjectBox, call
/// Flutter localization, or format money — so everything it renders has to be
/// computed here and handed over as **display-ready strings**. That includes
/// localization: the labels below are resolved in the app's locale at sync
/// time, because the extension has no access to Flow's translations.
///
/// Both amounts and percentages are always published. Whether a given widget
/// shows amounts is a per-widget setting the user picks on the platform side
/// (see `hideAmounts` in each widget's configuration), so the decision — and
/// the state — belongs there, not here.
///
/// Note this is shoulder-surfing privacy, not security: the amounts still sit
/// in the shared app-group container regardless of the toggle.
class BudgetWidgetSync {
  /// Single JSON blob rather than a flat key per field.
  ///
  /// The widgets render a variable-length list of budgets (the pinned widget
  /// has to resolve an arbitrary id, and its configuration screen enumerates
  /// them all), which flat `saveWidgetData` keys can't express without
  /// inventing an index convention on both platforms.
  static const String payloadKey = "budgetsPayload";

  /// Bumped when the payload's shape changes.
  ///
  /// A widget extension is updated by the App Store independently of the app
  /// process that writes this, so an old extension can and will read a new
  /// payload. It checks this and falls back to its placeholder rather than
  /// mis-rendering fields it doesn't understand.
  static const int payloadVersion = 1;

  /// Builds the payload without touching any platform channel.
  ///
  /// Split out from [sync] so the contract two native widget implementations
  /// depend on can actually be tested. A shape regression here is otherwise
  /// invisible from Dart — it surfaces as a widget rendering "---" on a user's
  /// home screen, with nothing failing anywhere in this codebase.
  static Future<Map<String, dynamic>> buildPayload({
    ExchangeRates? rates,
    DateTime? asOf,
  }) async {
    final List<BudgetProgress> progresses =
        (await BudgetService().computeAllProgressAsync(
          rates: rates,
          asOf: asOf,
        )).where((progress) => progress.isCurrent).toList();

    final BudgetsSummary summary = BudgetService().computeSummary(progresses);

    return {
      "version": payloadVersion,
      "updatedAt": (asOf ?? DateTime.now()).toUtc().toIso8601String(),
      "summary": {
        "budgetCount": summary.budgetCount,
        "overCount": summary.overCount,
        "warningCount": summary.warningCount,
        "hasMissingData": summary.hasMissingData,
        "worstId": summary.worst?.budget.id,
      },
      "budgets": progresses.map(_budgetJson).toList(),
      "labels": _labels(summary),
    };
  }

  static Future<void> sync() async {
    try {
      final ExchangeRates? rates = ExchangeRatesService()
          .getPrimaryCurrencyRates();

      final Map<String, dynamic> payload = await buildPayload(rates: rates);

      if (Platform.isIOS) {
        await HomeWidget.setAppGroupId(iOSAppGroupId);
      }

      await HomeWidget.saveWidgetData(payloadKey, jsonEncode(payload));

      await HomeWidget.updateWidget(
        name: "FlowBudgetRollupWidget",
        iOSName: "FlowBudgetRollupWidget",
        androidName: "BudgetRollupReceiver",
        qualifiedAndroidName: "mn.flow.flow.glance.BudgetRollupReceiver",
      );
      await HomeWidget.updateWidget(
        name: "FlowBudgetPinnedWidget",
        iOSName: "FlowBudgetPinnedWidget",
        androidName: "BudgetPinnedReceiver",
        qualifiedAndroidName: "mn.flow.flow.glance.BudgetPinnedReceiver",
      );

      _log.finest(
        "Synced ${(payload["budgets"] as List).length} budget(s) to home "
        "widgets",
      );
    } catch (e, stackTrace) {
      // A widget that fails to update keeps showing stale data, which is a far
      // better outcome than taking down whatever triggered the sync.
      _log.warning("Failed to sync budget widgets", e, stackTrace);
    }
  }

  static Map<String, dynamic> _budgetJson(BudgetProgress progress) => {
    "id": progress.budget.id,
    "name": progress.budget.name,
    // Pre-formatted and compacted: the extension has no access to the user's
    // currency formatting, and "₮420K" is what fits a 155pt-wide widget.
    "spent": progress.spent.formatMoney(compact: true),
    "limit": progress.limit.formatMoney(compact: true),
    "remaining": progress.remaining.formatMoney(compact: true),
    "overBy": progress.overBy.formatMoney(compact: true),
    // The amount-free rendering runs entirely off these.
    "percent": progress.percent,
    // Formatted here, in the *app's* locale, for the same reason the money
    // fields are. A widget extension formatting it itself would use the
    // *device* locale, so a phone set to a different language than Flow would
    // render digits in one style beside payload strings in another.
    "percentLabel": _formatPercent(progress.percent),
    "ratio": progress.ratio,
    "status": progress.status.name,
    // The status as a word. `status` alone is a machine value, and colour
    // can't carry it: iOS 18 tinted rendering flattens every hue to one, and
    // Android themed icons do the same. Without this, "over" and "nearing"
    // differ only by icon shape.
    ...?_optionalLabel("statusLabel", _statusLabel(progress.status)),
    "daysLeft": progress.daysLeft,
    // Resolved here rather than shipped as a template: plural selection is
    // language-specific and the extension has no plural rules to apply.
    ...?_optionalLabel(
      "daysLeftLabel",
      progress.isCurrent
          ? "budget.detail.daysLeft".tr(progress.daysLeft)
          : "budget.detail.periodEnded".tr(),
    ),
    "periodLabel": _periodLabel(progress.range),
    "hasMissingData": progress.hasMissingData,
  };

  /// A sync can fire before `FlowLocalizations` has loaded — the transaction
  /// listener is wired in `main` ahead of `runApp` — and an unloaded lookup
  /// returns an empty string.
  ///
  /// Publishing `""` would paint a blank where a label belongs and look like a
  /// rendering bug. Omitting the key instead lets the widget fall back to its
  /// own default, which is at least a real word. The next sync, once
  /// translations are loaded, fills it in properly.
  static Map<String, String>? _optionalLabel(String key, String value) =>
      value.isEmpty ? null : {key: value};

  static String _statusLabel(BudgetStatus status) => switch (status) {
    BudgetStatus.over => "budget.status.over".tr(),
    BudgetStatus.warning => "budget.status.nearing".tr(),
    BudgetStatus.healthy => "budget.status.onTrack".tr(),
  };

  /// `84` -> `"84%"`, in the app's locale.
  ///
  /// Takes the already-rounded integer rather than [BudgetProgress.ratio], so
  /// the number here can never disagree with the `percent` field beside it.
  static String _formatPercent(int percent) =>
      NumberFormat.percentPattern(Intl.defaultLocale).format(percent / 100);

  static Map<String, String> _labels(BudgetsSummary summary) => {
    ...?_optionalLabel("title", "budgets".tr()),
    ...?_optionalLabel("empty", "tabs.stats.analytics.budgets.empty".tr()),
    ...?_optionalLabel("onTrack", "tabs.stats.analytics.budgets.onTrack".tr()),
    ...?_optionalLabel(
      "over",
      "tabs.stats.analytics.budgets.overCount".tr(summary.overCount),
    ),
    ...?_optionalLabel(
      "nearing",
      "tabs.stats.analytics.budgets.nearingCount".tr(summary.warningCount),
    ),
    ...?_optionalLabel(
      "tracked",
      "tabs.stats.analytics.budgets.tracked".tr(summary.budgetCount),
    ),
    // Shown by the pinned widget when its budget has since been deleted.
    ...?_optionalLabel("missingBudget", "budget.overview.empty".tr()),
  };

  static String _periodLabel(TimeRange range) => switch (range) {
    MonthTimeRange month => month.from.format(
      payload: month.from.isAtSameYearAs(DateTime.now()) ? "MMMM" : "MMMM YYYY",
    ),
    YearTimeRange year => year.year.toString(),
    _ => "${range.from.toMoment().ll} -> ${range.to.toMoment().ll}",
  };
}
