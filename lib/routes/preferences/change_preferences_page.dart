import "package:flow/constants.dart";
import "package:flow/data/money.dart";
import "package:flow/data/prefs/change_visuals.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/trend.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:material_symbols_icons/symbols.dart";

class ChangeVisualsPreferencesPage extends StatefulWidget {
  const ChangeVisualsPreferencesPage({super.key});

  @override
  State<ChangeVisualsPreferencesPage> createState() =>
      _ChangeVisualsPreferencesPageState();
}

class _ChangeVisualsPreferencesPageState
    extends State<ChangeVisualsPreferencesPage> {
  @override
  Widget build(BuildContext context) {
    final ChangeVisuals changeVisuals = UserPreferencesService().changeVisuals;

    final double size = IconTheme.of(context).size ?? 24.0;

    return Scaffold(
      appBar: AppBar(title: Text("preferences.changeVisuals".t(context))),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListHeader("preferences.changeVisuals.incomeIncrease".t(context)),
              const SizedBox(height: 8.0),
              Frame(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 600.0),
                  child: Row(
                    spacing: 12.0,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            update(
                              changeVisuals.copyWith(
                                incomeIncreaseUpArrow:
                                    !changeVisuals.incomeIncreaseUpArrow,
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: context.colorScheme.surfaceContainer,
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Icon(
                                  changeVisuals.incomeIncreaseUpArrow
                                      ? Symbols.stat_1_rounded
                                      : Symbols.stat_minus_1_rounded,
                                  size: size,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            update(
                              changeVisuals.copyWith(
                                incomeIncreaseGreen:
                                    !changeVisuals.incomeIncreaseGreen,
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: context.colorScheme.surfaceContainer,
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Container(
                                  width: size,
                                  height: size,
                                  decoration: BoxDecoration(
                                    color: changeVisuals.incomeIncreaseGreen
                                        ? context.flowColors.income
                                        : context.flowColors.expense,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              ListHeader(
                "preferences.changeVisuals.expenseIncrease".t(context),
              ),
              const SizedBox(height: 8.0),
              Frame(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 600.0),
                  child: Row(
                    spacing: 12.0,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            update(
                              changeVisuals.copyWith(
                                expenseIncreaseUpArrow:
                                    !changeVisuals.expenseIncreaseUpArrow,
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: context.colorScheme.surfaceContainer,
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Icon(
                                  changeVisuals.expenseIncreaseUpArrow
                                      ? Symbols.stat_1_rounded
                                      : Symbols.stat_minus_1_rounded,
                                  size: size,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            update(
                              changeVisuals.copyWith(
                                expenseIncreaseRed:
                                    !changeVisuals.expenseIncreaseRed,
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: context.colorScheme.surfaceContainer,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: Container(
                                  width: size,
                                  height: size,
                                  decoration: BoxDecoration(
                                    color: changeVisuals.expenseIncreaseRed
                                        ? context.flowColors.expense
                                        : context.flowColors.income,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Frame.standalone(
                child: InfoText(
                  child: Text(
                    "preferences.changeVisuals.clickToChange".t(context),
                  ),
                ),
              ),
              if (flowDebugMode || kDebugMode) ...[
                const SizedBox(height: 24.0),
                ListHeader("Debug"),
                const SizedBox(height: 8.0),
                Frame(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 12.0,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(changeVisuals.serialize()),
                      ListHeader("Income Increase"),
                      Trend.fromMoney(
                        previous: Money(100, "USD"),
                        current: Money(200, "USD"),
                      ),
                      ListHeader("Income Decrease"),
                      Trend.fromMoney(
                        previous: Money(100, "USD"),
                        current: Money(50, "USD"),
                      ),
                      ListHeader("Expense Increase"),
                      Trend.fromMoney(
                        previous: Money(-100, "USD"),
                        current: Money(-200, "USD"),
                      ),
                      ListHeader("Expense Decrease"),
                      Trend.fromMoney(
                        previous: Money(-100, "USD"),
                        current: Money(-50, "USD"),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void update(ChangeVisuals newVisuals) {
    UserPreferencesService().changeVisuals = newVisuals;
    if (LocalPreferences().enableHapticFeedback.value == true) {
      HapticFeedback.lightImpact();
    }
    setState(() {});
  }
}
