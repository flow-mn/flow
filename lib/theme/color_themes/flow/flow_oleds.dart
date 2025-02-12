import "dart:ui";

import "package:flow/data/flow_icon.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/flow_theme_group.dart";
import "package:material_symbols_icons/symbols.dart";

final FlowColorScheme _defaultOledBase = FlowColorScheme(
  name: "defaultOledBase",
  isDark: true,
  surface: const Color(0xff000000),
  onSurface: const Color(0xfff5f6fa),
  primary: const Color(0xfff2c0ff),
  onPrimary: const Color(0xff000000),
  secondary: const Color(0xff101010),
  onSecondary: const Color(0xfff5f6fa),
  customColors: FlowCustomColors(
    income: Color(0xFF32CC70),
    expense: Color(0xFFFF4040),
    semi: Color(0xFF606060),
  ),
);

final FlowThemeGroup flowOleds = FlowThemeGroup(
  name: "Flow OLED",
  icon: FlowIconData.icon(Symbols.nights_stay_rounded),
  schemes: [
    _defaultOledBase.copyWith(
      name: "electricLavenderOled",
      iconName: "shadeOfViolet",
      primary: const Color(0xfff2c0ff),
    ),
    _defaultOledBase.copyWith(
      name: "pinkQuartzOled",
      iconName: "blissfulBerry",
      primary: const Color(0xffffc0f4),
    ),
    _defaultOledBase.copyWith(
      name: "cottonCandyOled",
      iconName: "cherryPlum",
      primary: const Color(0xffffc0dc),
    ),
    _defaultOledBase.copyWith(
      name: "pigletOled",
      iconName: "crispChristmasCranberries",
      primary: const Color(0xffffc0c5),
    ),
    _defaultOledBase.copyWith(
      name: "simplyDeliciousOled",
      iconName: "burntSienna",
      primary: const Color(0xffffd2c0),
    ),
    _defaultOledBase.copyWith(
      name: "creamyApricotOled",
      iconName: "soilOfAvagddu",
      primary: const Color(0xffffeac0),
    ),
    _defaultOledBase.copyWith(
      name: "yellYellowOled",
      iconName: "flagGreen",
      primary: const Color(0xfffcffc0),
    ),
    _defaultOledBase.copyWith(
      name: "fallGreenOled",
      iconName: "tropicana",
      primary: const Color(0xffe4ffc0),
    ),
    _defaultOledBase.copyWith(
      name: "frostedMintHillsOled",
      iconName: "toyCamouflage",
      primary: const Color(0xffcdffc0),
    ),
    _defaultOledBase.copyWith(
      name: "coastalTrimOled",
      iconName: "spreadsheetGreen",
      primary: const Color(0xffc0ffca),
    ),
    _defaultOledBase.copyWith(
      name: "seafairGreenOled",
      iconName: "tokiwaGreen",
      primary: const Color(0xffc0ffe2),
    ),
    _defaultOledBase.copyWith(
      name: "crushedIceOled",
      iconName: "hydraTurquoise",
      primary: const Color(0xffc0fff9),
    ),
    _defaultOledBase.copyWith(
      name: "iceEffectOled",
      iconName: "peacockBlue",
      primary: const Color(0xffc0ecff),
    ),
    _defaultOledBase.copyWith(
      name: "arcLightOled",
      iconName: "egyptianBlue",
      primary: const Color(0xffc0d4ff),
    ),
    _defaultOledBase.copyWith(
      name: "driedLilacOled",
      iconName: "bohemianBlue",
      primary: const Color(0xffc2c0ff),
    ),
    _defaultOledBase.copyWith(
      name: "neonBoneyardOled",
      iconName: "spaceBattleBlue",
      primary: const Color(0xffdac0ff),
    ),
  ],
);
