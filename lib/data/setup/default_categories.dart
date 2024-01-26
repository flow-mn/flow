import 'package:flow/entity/category.dart';
import 'package:flow/entity/icon/parser.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

List<Category> getCategoryPresets(BuildContext context) {
  return [
    Category(
      name: "setup.category.preset.eatingOut".t(context),
      iconCode: IconCode.fromMaterialSymbols(Symbols.restaurant_rounded),
    ),
    Category(
      name: "setup.category.preset.groceries".t(context),
      iconCode: IconCode.fromMaterialSymbols(Symbols.grocery_rounded),
    ),
    Category(
      name: "setup.category.preset.drinks".t(context),
      iconCode: IconCode.fromMaterialSymbols(Symbols.local_cafe_rounded),
    ),
    Category(
      name: "setup.category.preset.education".t(context),
      iconCode: IconCode.fromMaterialSymbols(Symbols.school_rounded),
    ),
    Category(
      name: "setup.category.preset.health".t(context),
      iconCode: IconCode.fromMaterialSymbols(Symbols.health_and_safety_rounded),
    ),
    Category(
      name: "setup.category.preset.transport".t(context),
      iconCode: IconCode.fromMaterialSymbols(Symbols.train_rounded),
    ),
    Category(
      name: "setup.category.preset.petrol".t(context),
      iconCode: IconCode.fromMaterialSymbols(Symbols.local_gas_station_rounded),
    ),
    Category(
      name: "setup.category.preset.shopping".t(context),
      iconCode: IconCode.fromMaterialSymbols(Symbols.shopping_cart_rounded),
    ),
    Category(
      name: "setup.category.preset.entertainment".t(context),
      iconCode: IconCode.fromMaterialSymbols(Symbols.sports_basketball_rounded),
    ),
    Category(
      name: "setup.category.preset.rent",
      iconCode: IconCode.fromMaterialSymbols(Symbols.request_quote_rounded),
    ),
    Category(
      name: "setup.category.preset.utils",
      iconCode: IconCode.fromMaterialSymbols(Symbols.valve_rounded),
    ),
    Category(
      name: "setup.category.preset.taxes",
      iconCode: IconCode.fromMaterialSymbols(Symbols.account_balance_rounded),
    ),
    Category(
      name: "setup.category.preset.paychecks",
      iconCode: IconCode.fromMaterialSymbols(Symbols.sports_basketball_rounded),
    ),
    Category(
      name: "setup.category.preset.misc".t(context),
      iconCode: IconCode.fromMaterialSymbols(Symbols.paid_rounded),
    ),
  ];
}
