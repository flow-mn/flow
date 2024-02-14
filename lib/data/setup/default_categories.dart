import 'package:flow/data/flow_icon.dart';
import 'package:flow/entity/category.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:material_symbols_icons/symbols.dart';

List<Category> getCategoryPresets() {
  return [
    Category(
      id: -1,
      name: "setup.categories.preset.eatingOut".tr(),
      iconCode: const IconFlowIcon(Symbols.restaurant_rounded).toString(),
    ),
    Category(
      id: -1,
      name: "setup.categories.preset.groceries".tr(),
      iconCode: const IconFlowIcon(Symbols.grocery_rounded).toString(),
    ),
    Category(
      id: -1,
      name: "setup.categories.preset.drinks".tr(),
      iconCode: const IconFlowIcon(Symbols.local_cafe_rounded).toString(),
    ),
    Category(
      id: -1,
      name: "setup.categories.preset.education".tr(),
      iconCode: const IconFlowIcon(Symbols.school_rounded).toString(),
    ),
    Category(
      id: -1,
      name: "setup.categories.preset.health".tr(),
      iconCode:
          const IconFlowIcon(Symbols.health_and_safety_rounded).toString(),
    ),
    Category(
      id: -1,
      name: "setup.categories.preset.transport".tr(),
      iconCode: const IconFlowIcon(Symbols.train_rounded).toString(),
    ),
    Category(
      id: -1,
      name: "setup.categories.preset.petrol".tr(),
      iconCode:
          const IconFlowIcon(Symbols.local_gas_station_rounded).toString(),
    ),
    Category(
      id: -1,
      name: "setup.categories.preset.shopping".tr(),
      iconCode: const IconFlowIcon(Symbols.shopping_cart_rounded).toString(),
    ),
    Category(
      id: -1,
      name: "setup.categories.preset.entertainment".tr(),
      iconCode:
          const IconFlowIcon(Symbols.sports_basketball_rounded).toString(),
    ),
    Category(
      id: -1,
      name: "setup.categories.preset.rent".tr(),
      iconCode: const IconFlowIcon(Symbols.request_quote_rounded).toString(),
    ),
    Category(
      id: -1,
      name: "setup.categories.preset.utils".tr(),
      iconCode: const IconFlowIcon(Symbols.valve_rounded).toString(),
    ),
    Category(
      id: -1,
      name: "setup.categories.preset.taxes".tr(),
      iconCode: const IconFlowIcon(Symbols.account_balance_rounded).toString(),
    ),
    Category(
      id: -1,
      name: "setup.categories.preset.paychecks".tr(),
      iconCode: const IconFlowIcon(Symbols.wallet_rounded).toString(),
    ),
  ];
}
