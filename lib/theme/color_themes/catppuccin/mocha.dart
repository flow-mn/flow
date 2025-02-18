import "dart:ui";

import "package:flow/data/flow_icon.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/flow_theme_group.dart";

final FlowColorScheme _catppuccinMochaBase = FlowColorScheme(
  name: "catppuccinMochaBase",
  isDark: true,
  surface: const Color(0xff1e1e2e),
  onSurface: const Color(0xffcdd6f4),
  primary: const Color(0xfff2cdcd),
  onPrimary: const Color(0xff11111b),
  secondary: const Color(0xff11111b),
  onSecondary: const Color(0xffcdd6f4),
  customColors: FlowCustomColors(
    income: Color(0xffa6e3a1),
    expense: Color(0xfff38ba8),
    semi: Color(0xff9399b2),
  ),
);

final FlowThemeGroup catppuccinMocha = FlowThemeGroup(
  name: "Catppuccin Mocha",
  icon: FlowIconData.emoji("🌿"),
  schemes: [
    _catppuccinMochaBase.copyWith(
      name: "catppuccinFlamingoMocha",
      primary: Color(0xfff2cdcd),
    ),
    _catppuccinMochaBase.copyWith(
      name: "catppuccinRosewaterMocha",
      primary: Color(0xfff5e0dc),
    ),
    _catppuccinMochaBase.copyWith(
      name: "catppuccinMauveMocha",
      primary: Color(0xffcba6f7),
    ),
    _catppuccinMochaBase.copyWith(
      name: "catppuccinPinkMocha",
      primary: Color(0xfff5c2e7),
    ),
    _catppuccinMochaBase.copyWith(
      name: "catppuccinRedMocha",
      primary: Color(0xfff38ba8),
    ),
    _catppuccinMochaBase.copyWith(
      name: "catppuccinMaroonMocha",
      primary: Color(0xffeba0ac),
    ),
    _catppuccinMochaBase.copyWith(
      name: "catppuccinPeachMocha",
      primary: Color(0xfffab387),
    ),
    _catppuccinMochaBase.copyWith(
      name: "catppuccinYellowMocha",
      primary: Color(0xfff9e2af),
    ),
    _catppuccinMochaBase.copyWith(
      name: "catppuccinGreenMocha",
      primary: Color(0xffa6e3a1),
    ),
    _catppuccinMochaBase.copyWith(
      name: "catppuccinTealMocha",
      primary: Color(0xff94e2d5),
    ),
    _catppuccinMochaBase.copyWith(
      name: "catppuccinSkyMocha",
      primary: Color(0xff89dceb),
    ),
    _catppuccinMochaBase.copyWith(
      name: "catppuccinSapphireMocha",
      primary: Color(0xff74c7ec),
    ),
    _catppuccinMochaBase.copyWith(
      name: "catppuccinBlueMocha",
      primary: Color(0xff89b4fa),
    ),
    _catppuccinMochaBase.copyWith(
      name: "catppuccinLavenderMocha",
      primary: Color(0xffb4befe),
    ),
  ],
);
