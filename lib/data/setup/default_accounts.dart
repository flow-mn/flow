import 'package:flow/data/flow_icon.dart';
import 'package:flow/entity/account.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:material_symbols_icons/symbols.dart';

List<Account> getAccountPresets(String currency) {
  return [
    Account(
      id: -1,
      name: "setup.accounts.preset.main".tr(),
      currency: currency,
      iconCode: FlowIconData.icon(Symbols.credit_card_rounded).toString(),
    ),
    Account(
      id: -1,
      name: "setup.accounts.preset.cash".tr(),
      currency: currency,
      iconCode: FlowIconData.icon(Symbols.payments_rounded).toString(),
    ),
    Account(
      id: -1,
      name: "setup.accounts.preset.savings".tr(),
      currency: currency,
      iconCode: FlowIconData.icon(Symbols.savings_rounded).toString(),
    ),
  ];
}
