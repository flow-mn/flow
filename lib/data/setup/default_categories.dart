import 'package:flow/data/flow_icon.dart';
import 'package:flow/entity/category.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:material_symbols_icons/symbols.dart';

List<Category> getCategoryPresets() {
  return [
    Category.preset(
      uuid: "f38b4e03-2ce6-4605-aeb9-a5e5fa6d01f5",
      name: "setup.categories.preset.eatingOut".tr(),
      iconCode: const IconFlowIcon(Symbols.restaurant_rounded).toString(),
    ),
    Category.preset(
      uuid: "9ee43092-34bb-4647-ba43-59b23ba69afe",
      name: "setup.categories.preset.groceries".tr(),
      iconCode: const IconFlowIcon(Symbols.grocery_rounded).toString(),
    ),
    Category.preset(
      uuid: "fea4be2c-96cd-4844-a953-022a966985ee",
      name: "setup.categories.preset.drinks".tr(),
      iconCode: const IconFlowIcon(Symbols.local_cafe_rounded).toString(),
    ),
    Category.preset(
      uuid: "dd3aacb3-35a9-4b04-b1f3-9fb3f58f1332",
      name: "setup.categories.preset.education".tr(),
      iconCode: const IconFlowIcon(Symbols.school_rounded).toString(),
    ),
    Category.preset(
      uuid: "39bfdc73-4cba-4980-ba0d-c200f903cc97",
      name: "setup.categories.preset.health".tr(),
      iconCode:
          const IconFlowIcon(Symbols.health_and_safety_rounded).toString(),
    ),
    Category.preset(
      uuid: "1a67735a-561a-48c0-bf86-f19dab4b95b5",
      name: "setup.categories.preset.transport".tr(),
      iconCode: const IconFlowIcon(Symbols.train_rounded).toString(),
    ),
    Category.preset(
      uuid: "92e5e684-0bbf-4456-b731-2ad945d5773b",
      name: "setup.categories.preset.petrol".tr(),
      iconCode:
          const IconFlowIcon(Symbols.local_gas_station_rounded).toString(),
    ),
    Category.preset(
      uuid: "c04b893b-bea8-4df3-804c-8b14e3e65c6d",
      name: "setup.categories.preset.shopping".tr(),
      iconCode: const IconFlowIcon(Symbols.shopping_cart_rounded).toString(),
    ),
    Category.preset(
      uuid: "4c75d6c4-aed2-4f60-9d28-4b3ae55b4498",
      name: "setup.categories.preset.entertainment".tr(),
      iconCode:
          const IconFlowIcon(Symbols.sports_basketball_rounded).toString(),
    ),
    Category.preset(
      uuid: "9555eecf-7570-4118-89b0-e7343ece6572",
      name: "setup.categories.preset.onlineServices".tr(),
      iconCode: const IconFlowIcon(Symbols.cloud_circle_rounded).toString(),
    ),
    Category.preset(
      uuid: "e8cf1c76-cdf7-41e1-9343-923b86cd9ea2",
      name: "setup.categories.preset.gifts".tr(),
      iconCode: const IconFlowIcon(Symbols.featured_seasonal_and_gifts_rounded)
          .toString(),
    ),
    Category.preset(
      uuid: "f442d114-b8c0-4f7e-befd-70844ad16fb4",
      name: "setup.categories.preset.rent".tr(),
      iconCode: const IconFlowIcon(Symbols.request_quote_rounded).toString(),
    ),
    Category.preset(
      uuid: "a535e3ac-2103-40d6-acb7-0c664eb3bf6e",
      name: "setup.categories.preset.utils".tr(),
      iconCode: const IconFlowIcon(Symbols.valve_rounded).toString(),
    ),
    Category.preset(
      uuid: "4213e196-8974-41d4-8eb9-b4debf3118aa",
      name: "setup.categories.preset.taxes".tr(),
      iconCode: const IconFlowIcon(Symbols.account_balance_rounded).toString(),
    ),
    Category.preset(
      uuid: "8bec1ea1-726f-4228-9d14-d210e86a9586",
      name: "setup.categories.preset.paychecks".tr(),
      iconCode: const IconFlowIcon(Symbols.wallet_rounded).toString(),
    ),
  ];
}
