import 'package:flow/entity/account.dart';
import 'package:flow/entity/icon/parser.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

List<Account> getAccountPresets(BuildContext context, String currency) {
  return [
    Account(
      name: "setup.account.preset.main".t(context),
      currency: currency,
      iconCode: IconCode.fromMaterialSymbols(Symbols.credit_card_rounded),
    ),
    Account(
      name: "setup.account.preset.cash".t(context),
      currency: currency,
      iconCode: IconCode.fromMaterialSymbols(Symbols.payments_rounded),
    ),
    Account(
      name: "setup.account.preset.savings".t(context),
      currency: currency,
      iconCode: IconCode.fromMaterialSymbols(Symbols.savings_rounded),
    ),
  ];
}
