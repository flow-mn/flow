import 'package:flow/data/flow_icon.dart';
import 'package:flow/entity/category.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

List<Category> getCategoryPresets(BuildContext context) {
  return [
    Category(
      name: "setup.category.preset.eatingOut".t(context),
      iconCode: const IconFlowIcon(Symbols.restaurant_rounded).toString(),
    ),
    Category(
      name: "setup.category.preset.groceries".t(context),
      iconCode: const IconFlowIcon(Symbols.grocery_rounded).toString(),
    ),
    Category(
      name: "setup.category.preset.drinks".t(context),
      iconCode: const IconFlowIcon(Symbols.local_cafe_rounded).toString(),
    ),
    Category(
      name: "setup.category.preset.education".t(context),
      iconCode: const IconFlowIcon(Symbols.school_rounded).toString(),
    ),
    Category(
      name: "setup.category.preset.health".t(context),
      iconCode:
          const IconFlowIcon(Symbols.health_and_safety_rounded).toString(),
    ),
    Category(
      name: "setup.category.preset.transport".t(context),
      iconCode: const IconFlowIcon(Symbols.train_rounded).toString(),
    ),
    Category(
      name: "setup.category.preset.petrol".t(context),
      iconCode:
          const IconFlowIcon(Symbols.local_gas_station_rounded).toString(),
    ),
    Category(
      name: "setup.category.preset.shopping".t(context),
      iconCode: const IconFlowIcon(Symbols.shopping_cart_rounded).toString(),
    ),
    Category(
      name: "setup.category.preset.entertainment".t(context),
      iconCode:
          const IconFlowIcon(Symbols.sports_basketball_rounded).toString(),
    ),
    Category(
      name: "setup.category.preset.rent",
      iconCode: const IconFlowIcon(Symbols.request_quote_rounded).toString(),
    ),
    Category(
      name: "setup.category.preset.utils",
      iconCode: const IconFlowIcon(Symbols.valve_rounded).toString(),
    ),
    Category(
      name: "setup.category.preset.taxes",
      iconCode: const IconFlowIcon(Symbols.account_balance_rounded).toString(),
    ),
    Category(
      name: "setup.category.preset.paychecks",
      iconCode:
          const IconFlowIcon(Symbols.sports_basketball_rounded).toString(),
    ),
    Category(
      name: "setup.category.preset.misc".t(context),
      iconCode: const IconFlowIcon(Symbols.paid_rounded).toString(),
    ),
  ];
}
