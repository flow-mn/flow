import "package:flow/data/flow_icon.dart";
import "package:flow/theme/flow_theme_group.dart";

import "dart:ui";

import "package:flow/theme/flow_color_scheme.dart";
import "package:material_symbols_icons/symbols.dart";

final FlowColorScheme _defaultDarkBase = FlowColorScheme(
  name: "defaultDarkBase",
  isDark: true,
  surface: const Color(0xff141414),
  onSurface: const Color(0xfff5f6fa),
  primary: const Color(0xfff2c0ff),
  onPrimary: const Color(0xff141414),
  secondary: const Color(0xff050505),
  onSecondary: const Color(0xfff5f6fa),
  customColors: FlowCustomColors(
    income: Color(0xFF32CC70),
    expense: Color(0xFFFF4040),
    semi: Color(0xFF97919B),
  ),
);

final FlowThemeGroup flowDarks = FlowThemeGroup(
  name: "Flow Dark",
  icon: FlowIconData.icon(Symbols.dark_mode_rounded),
  schemes: [
    _defaultDarkBase.copyWith(
      name: "electricLavender",
      iconName: "shadeOfViolet",
      primary: const Color(0xfff2c0ff),
    ),
    _defaultDarkBase.copyWith(
      name: "pinkQuartz",
      iconName: "blissfulBerry",
      primary: const Color(0xffffc0f4),
    ),
    _defaultDarkBase.copyWith(
      name: "cottonCandy",
      iconName: "cherryPlum",
      primary: const Color(0xffffc0dc),
    ),
    _defaultDarkBase.copyWith(
      name: "piglet",
      iconName: "crispChristmasCranberries",
      primary: const Color(0xffffc0c5),
    ),
    _defaultDarkBase.copyWith(
      name: "simplyDelicious",
      iconName: "burntSienna",
      primary: const Color(0xffffd2c0),
    ),
    _defaultDarkBase.copyWith(
      name: "creamyApricot",
      iconName: "soilOfAvagddu",
      primary: const Color(0xffffeac0),
    ),
    _defaultDarkBase.copyWith(
      name: "yellYellow",
      iconName: "flagGreen",
      primary: const Color(0xfffcffc0),
    ),
    _defaultDarkBase.copyWith(
      name: "fallGreen",
      iconName: "tropicana",
      primary: const Color(0xffe4ffc0),
    ),
    _defaultDarkBase.copyWith(
      name: "frostedMintHills",
      iconName: "toyCamouflage",
      primary: const Color(0xffcdffc0),
    ),
    _defaultDarkBase.copyWith(
      name: "coastalTrim",
      iconName: "spreadsheetGreen",
      primary: const Color(0xffc0ffca),
    ),
    _defaultDarkBase.copyWith(
      name: "seafairGreen",
      iconName: "tokiwaGreen",
      primary: const Color(0xffc0ffe2),
    ),
    _defaultDarkBase.copyWith(
      name: "crushedIce",
      iconName: "hydraTurquoise",
      primary: const Color(0xffc0fff9),
    ),
    _defaultDarkBase.copyWith(
      name: "iceEffect",
      iconName: "peacockBlue",
      primary: const Color(0xffc0ecff),
    ),
    _defaultDarkBase.copyWith(
      name: "arcLight",
      iconName: "egyptianBlue",
      primary: const Color(0xffc0d4ff),
    ),
    _defaultDarkBase.copyWith(
      name: "driedLilac",
      iconName: "bohemianBlue",
      primary: const Color(0xffc2c0ff),
    ),
    _defaultDarkBase.copyWith(
      name: "neonBoneyard",
      iconName: "spaceBattleBlue",
      primary: const Color(0xffdac0ff),
    ),
  ],
);
