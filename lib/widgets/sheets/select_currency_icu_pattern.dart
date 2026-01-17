import "package:flow/data/money.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/utils/optional.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flow/widgets/general/wavy_divider.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// Pops with a [Optional] ICU pattern number formatter, or [Optional] null
/// from a pre-defined list of patterns.
class SelectCurrencyIcuPattern extends StatefulWidget {
  static const List<String?> patterns = [
    null,
    "¤#,##0.00",
    "¤#,##0",
    "¤ #,##0.00",
    "#,##0.00 ¤",
    "#,##0.00¤",
    "¤#,##0.00;(¤#,##0.00)",
    "¤#,##0.00;-¤#,##0.00",
    "¤ ##,##,##0.00",
    "¤##0.00",
    "¤#,##0.00 CR;¤#,##0.00 DR",
  ];

  const SelectCurrencyIcuPattern({super.key});

  @override
  State<SelectCurrencyIcuPattern> createState() =>
      _SelectCurrencyIcuPatternState();
}

class _SelectCurrencyIcuPatternState extends State<SelectCurrencyIcuPattern> {
  Optional<String?>? selectedPattern;

  @override
  void initState() {
    super.initState();
    selectedPattern =
        UserPreferencesService().icuCurrencyFormattingPattern == null
        ? null
        : Optional(UserPreferencesService().icuCurrencyFormattingPattern);
  }

  @override
  Widget build(BuildContext context) {
    final String primaryCurrency = UserPreferencesService().primaryCurrency;

    return ModalSheet.scrollable(
      title: Text("preferences.moneyFormatting.setICUPattern".t(context)),
      leading: DefaultTextStyle(
        style: context.textTheme.displaySmall!,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: .center,
          spacing: 8.0,
          children: [
            Text(
              Money(
                1425627.09,
                primaryCurrency,
              ).formatMoney(customIcuPattern: selectedPattern),
            ),
            Text(
              Money(
                314.0,
                primaryCurrency,
              ).formatMoney(customIcuPattern: selectedPattern),
            ),
            Text(
              Money(
                -601.5,
                primaryCurrency,
              ).formatMoney(customIcuPattern: selectedPattern),
            ),
            WavyDivider(),
          ],
        ),
      ),
      trailing: ModalOverflowBar(
        alignment: .end,
        children: [
          TextButton.icon(
            onPressed: pop,
            icon: const Icon(Symbols.check_rounded),
            label: Text("general.done".t(context)),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: RadioGroup(
          groupValue: selectedPattern?.value,
          onChanged: (value) {
            setState(() {
              selectedPattern = Optional(value);
            });
          },
          child: Column(
            children: SelectCurrencyIcuPattern.patterns
                .map(
                  (pattern) => RadioListTile<String?>(
                    title: Text(
                      Money(123456.78, primaryCurrency).formatMoney(
                        customIcuPattern: pattern == null
                            ? Optional<String?>(null)
                            : Optional(pattern),
                      ),
                    ),
                    subtitle: pattern == null
                        ? Text(
                            "preferences.moneyFormatting.setICUPattern.default"
                                .t(context),
                          )
                        : null,
                    value: pattern,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  void pop() {
    context.pop<Optional<String?>>(selectedPattern);
  }
}
