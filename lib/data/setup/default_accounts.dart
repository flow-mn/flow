import "package:flow/data/flow_icon.dart";
import "package:flow/entity/account.dart";
import "package:flow/l10n/extensions.dart";
import "package:material_symbols_icons/symbols.dart";

List<Account> getAccountPresets(String currency) {
  return [
    Account.preset(
      name: "setup.accounts.preset.main".tr(),
      currency: currency,
      iconCode: FlowIconData.icon(Symbols.credit_card_rounded).toString(),
      uuid: "864df1dc-fe59-47e0-8423-98d8f86453b6",
    ),
    Account.preset(
      name: "setup.accounts.preset.cash".tr(),
      currency: currency,
      iconCode: FlowIconData.icon(Symbols.payments_rounded).toString(),
      uuid: "d7ef9672-256b-4097-a55a-27a58c6f5ba5",
    ),
    Account.preset(
      name: "setup.accounts.preset.savings".tr(),
      currency: currency,
      iconCode: FlowIconData.icon(Symbols.savings_rounded).toString(),
      excludeFromTotalBalance: true,
      uuid: "c04e1cdd-842f-48c1-9c6c-d07fb2b09193",
    ),
  ];
}
